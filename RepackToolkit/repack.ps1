<#
.SYNOPSIS
    Repack Power Apps Canvas Source to .msapp binary using Template Baseline method

.DESCRIPTION
    This script uses Power Platform CLI (pac) to pack the CanvasSource folder
    into a compiled .msapp file. It uses a "template baseline" approach:
    1. Unpack a template .msapp to get proper structure (including CanvasManifest.json)
    2. Overlay/merge current CanvasSource content onto the baseline
    3. Pack the merged folder to generate a valid .msapp

    This approach is required for PAC CLI 1.51+ which requires CanvasManifest.json.

    IMPORTANT: Empty metadata files (like Connections.json with just {}) are NOT
    copied to avoid PAC ArgumentNullException crashes. Template versions are preserved.

.PARAMETER TemplateMsappPath
    Path to a template .msapp file. If not provided, looks for:
    1. $env:REPACK_TEMPLATE_MSAPP environment variable
    2. RepackToolkit/template/BlankApp.msapp (bundled template)

.PARAMETER OutputName
    Output .msapp file name (default: CrossDivProjectDB.msapp)

.PARAMETER KeepTempFolders
    Keep temporary folders after completion (useful for debugging)

.NOTES
    Prerequisites:
    - Power Platform CLI must be installed (pac canvas pack/unpack)
    - A template .msapp file from Power Apps (or use bundled template)
    - Run from the package root directory (where CanvasSource folder exists)

.EXAMPLE
    .\RepackToolkit\repack.ps1
    .\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"
    .\RepackToolkit\repack.ps1 -KeepTempFolders
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, HelpMessage="Path to template .msapp file")]
    [string]$TemplateMsappPath = "",

    [Parameter(HelpMessage="Output .msapp file name")]
    [string]$OutputName = "CrossDivProjectDB.msapp",

    [Parameter(HelpMessage="Keep temporary folders after completion")]
    [switch]$KeepTempFolders
)

# ===================================================================
# CONFIGURATION
# ===================================================================

$ErrorActionPreference = "Stop"

# Resolve to absolute paths (handles spaces correctly)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $ScriptDir ".."))
$SourceFolder = Join-Path $RepoRoot "CanvasSource"
$OutputFolder = Join-Path $RepoRoot "CanvasApp"
$OutputPath = Join-Path $OutputFolder $OutputName

# Bundled template location
$BundledTemplate = Join-Path $ScriptDir "template\BlankApp.msapp"

# Temp folder for merge operations
$TempRoot = Join-Path $ScriptDir ".repack_temp"
$TempUnpackTemplate = Join-Path $TempRoot "template_unpacked"
$TempMerged = Join-Path $TempRoot "merged"

# ===================================================================
# HELPER FUNCTIONS
# ===================================================================

function Write-StepHeader {
    param([string]$Message)
    Write-Host ""
    Write-Host "==================================================================="  -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Cyan
    Write-Host "==================================================================="  -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Label, [string]$Value)
    Write-Host "  $Label " -NoNewline -ForegroundColor Gray
    Write-Host $Value -ForegroundColor White
}

function Write-Cmd {
    param([string]$Command)
    Write-Host "  > $Command" -ForegroundColor DarkGray
}

function Test-PacCli {
    try {
        $null = & pac --version 2>&1
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Get-PacVersion {
    try {
        $output = & pac --version 2>&1 | Out-String
        return ($output -split "`n")[0].Trim()
    } catch {
        return "Unknown"
    }
}

function Remove-TempFolders {
    if (Test-Path $TempRoot) {
        Remove-Item -Path $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ===================================================================
# JSON VALIDATION FUNCTIONS
# ===================================================================

function Test-JsonFileHasContent {
    <#
    .SYNOPSIS
        Tests if a JSON file has meaningful content (not just {} or [])
    .DESCRIPTION
        Returns $true if:
        - File exists
        - File is valid JSON
        - Content is not empty object {} or empty array []
        - For objects: has at least one property with non-null value
    #>
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return $false
    }

    try {
        $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($content)) {
            return $false
        }

        # Remove whitespace and check for empty structures
        $trimmed = $content.Trim()
        if ($trimmed -eq "{}" -or $trimmed -eq "[]") {
            return $false
        }

        # Try to parse as JSON
        $json = $content | ConvertFrom-Json -ErrorAction Stop

        # Check if it's an empty object or array
        if ($null -eq $json) {
            return $false
        }

        # If it's an object, check if it has any properties with content
        if ($json -is [PSCustomObject]) {
            $props = $json.PSObject.Properties
            if ($props.Count -eq 0) {
                return $false
            }
            # Check if all properties are null/empty
            $hasContent = $false
            foreach ($prop in $props) {
                if ($null -ne $prop.Value) {
                    if ($prop.Value -is [string] -and [string]::IsNullOrWhiteSpace($prop.Value)) {
                        continue
                    }
                    if ($prop.Value -is [array] -and $prop.Value.Count -eq 0) {
                        continue
                    }
                    $hasContent = $true
                    break
                }
            }
            return $hasContent
        }

        # If it's an array, check if it has elements
        if ($json -is [array]) {
            return ($json.Count -gt 0)
        }

        return $true
    } catch {
        # If JSON parsing fails, consider it invalid/empty
        return $false
    }
}

function Test-FolderHasValidContent {
    <#
    .SYNOPSIS
        Tests if a folder contains any JSON files with meaningful content
    #>
    param([string]$FolderPath)

    if (-not (Test-Path $FolderPath)) {
        return $false
    }

    $jsonFiles = Get-ChildItem -Path $FolderPath -Filter "*.json" -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $jsonFiles) {
        if (Test-JsonFileHasContent -FilePath $file.FullName) {
            return $true
        }
    }
    return $false
}

# ===================================================================
# PAC ERROR DETECTION
# ===================================================================

function Test-PacOutputForErrors {
    <#
    .SYNOPSIS
        Checks PAC output for error indicators even if exit code is 0
    .DESCRIPTION
        PAC sometimes prints "completed successfully" but also shows exceptions.
        This function detects those cases.
    #>
    param([string[]]$Output)

    $errorPatterns = @(
        "Exception Type:",
        "System\.ArgumentNullException",
        "System\.NullReferenceException",
        "non-recoverable error",
        "Unhandled exception",
        "Fatal error",
        "Error PAS"
    )

    $outputStr = $Output -join "`n"
    foreach ($pattern in $errorPatterns) {
        if ($outputStr -match $pattern) {
            return $true
        }
    }
    return $false
}

function Get-PacLogPath {
    <#
    .SYNOPSIS
        Attempts to find the PAC CLI log file path
    #>
    $possiblePaths = @(
        "$env:LOCALAPPDATA\Microsoft\PowerAppsCli\logs",
        "$env:APPDATA\Microsoft\PowerAppsCli\logs",
        "$env:USERPROFILE\.pac\logs"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $latestLog = Get-ChildItem -Path $path -Filter "*.log" -ErrorAction SilentlyContinue |
                         Sort-Object LastWriteTime -Descending |
                         Select-Object -First 1
            if ($latestLog) {
                return $latestLog.FullName
            }
        }
    }
    return $null
}

function Show-PacLogTail {
    <#
    .SYNOPSIS
        Shows the last N lines of the PAC log file
    #>
    param([int]$Lines = 50)

    $logPath = Get-PacLogPath
    if ($logPath -and (Test-Path $logPath)) {
        Write-Host ""
        Write-Host "  PAC Log (last $Lines lines):" -ForegroundColor Yellow
        Write-Host "  Path: $logPath" -ForegroundColor Gray
        Write-Host "  ----------------------------------------" -ForegroundColor Gray
        Get-Content -Path $logPath -Tail $Lines -ErrorAction SilentlyContinue |
            ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        Write-Host "  ----------------------------------------" -ForegroundColor Gray
    } else {
        Write-Host "  PAC log file not found." -ForegroundColor Gray
    }
}

# ===================================================================
# SAFE COPY FUNCTIONS
# ===================================================================

function Copy-SourceFileIfValid {
    <#
    .SYNOPSIS
        Copies a source file to destination only if it has valid content
    .DESCRIPTION
        If source file is empty/placeholder, keeps the template version
    #>
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$Description
    )

    if (-not (Test-Path $SourcePath)) {
        Write-Warn "Source not found, keeping template: $Description"
        return $false
    }

    if (Test-JsonFileHasContent -FilePath $SourcePath) {
        Copy-Item -Path $SourcePath -Destination $DestPath -Force
        Write-Success "Copied $Description"
        return $true
    } else {
        Write-Warn "Source is empty/placeholder, keeping template: $Description"
        return $false
    }
}

function Copy-SourceFolderIfValid {
    <#
    .SYNOPSIS
        Copies a source folder to destination only if it has valid content
    .DESCRIPTION
        If source folder has only empty JSON files, keeps the template version
    #>
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$Description
    )

    if (-not (Test-Path $SourcePath)) {
        Write-Warn "Source folder not found, keeping template: $Description"
        return $false
    }

    if (Test-FolderHasValidContent -FolderPath $SourcePath) {
        if (Test-Path $DestPath) { Remove-Item -Path $DestPath -Recurse -Force }
        Copy-Item -Path $SourcePath -Destination $DestPath -Recurse -Force
        Write-Success "Copied $Description"
        return $true
    } else {
        Write-Warn "Source folder has no valid content, keeping template: $Description"
        return $false
    }
}

# ===================================================================
# MAIN SCRIPT
# ===================================================================

Write-Host ""
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "|   Power Apps Canvas Source Repacker (Template Baseline v3.1)     |" -ForegroundColor Magenta
Write-Host "|   Cross-Divisional Project Database                              |" -ForegroundColor Magenta
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host ""

# -------------------------------------------------------------------
# Step 0: Resolve Template .msapp
# -------------------------------------------------------------------

Write-StepHeader "Step 0: Resolving Template .msapp"

# Priority: 1) Parameter, 2) Env var, 3) Bundled template
if ([string]::IsNullOrWhiteSpace($TemplateMsappPath)) {
    $TemplateMsappPath = $env:REPACK_TEMPLATE_MSAPP
}

if ([string]::IsNullOrWhiteSpace($TemplateMsappPath)) {
    if (Test-Path $BundledTemplate) {
        $TemplateMsappPath = $BundledTemplate
        Write-Info "Using bundled template:" $BundledTemplate
    }
}

if ([string]::IsNullOrWhiteSpace($TemplateMsappPath)) {
    Write-Failure "Template .msapp path is required!"
    Write-Host ""
    Write-Host "  The template baseline method requires a template .msapp file." -ForegroundColor Yellow
    Write-Host "  This file provides CanvasManifest.json (required by PAC CLI 1.51+)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Options:" -ForegroundColor Cyan
    Write-Host "    1. Provide via parameter:" -ForegroundColor White
    Write-Host "       .\repack.ps1 -TemplateMsappPath `"C:\path\to\template.msapp`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    2. Set environment variable:" -ForegroundColor White
    Write-Host "       `$env:REPACK_TEMPLATE_MSAPP = `"C:\path\to\template.msapp`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "    3. Place bundled template at:" -ForegroundColor White
    Write-Host "       $BundledTemplate" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  How to create a template .msapp:" -ForegroundColor Cyan
    Write-Host "    1. Go to make.powerapps.com" -ForegroundColor Gray
    Write-Host "    2. Create a blank canvas app (any layout)" -ForegroundColor Gray
    Write-Host "    3. File > Save As > This computer" -ForegroundColor Gray
    Write-Host "    4. Save as BlankApp.msapp" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  See TROUBLESHOOTING_REPACK.md for detailed instructions." -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Resolve to absolute path
$TemplateMsappPath = [System.IO.Path]::GetFullPath($TemplateMsappPath)

if (-not (Test-Path $TemplateMsappPath)) {
    Write-Failure "Template .msapp not found: $TemplateMsappPath"
    exit 1
}

if (-not $TemplateMsappPath.EndsWith(".msapp", [StringComparison]::OrdinalIgnoreCase)) {
    Write-Failure "Template file must be a .msapp file: $TemplateMsappPath"
    exit 1
}

$templateSize = (Get-Item $TemplateMsappPath).Length
if ($templateSize -eq 0) {
    Write-Failure "Template .msapp is 0 bytes (invalid): $TemplateMsappPath"
    exit 1
}

Write-Success "Template .msapp found"
Write-Info "Path:" $TemplateMsappPath
Write-Info "Size:" "$([math]::Round($templateSize / 1KB, 2)) KB"

# -------------------------------------------------------------------
# Step 1: Verify PAC CLI Installation
# -------------------------------------------------------------------

Write-StepHeader "Step 1: Verifying Prerequisites"

if (-not (Test-PacCli)) {
    Write-Failure "Power Platform CLI (pac) not found!"
    Write-Host ""
    Write-Host "Please install PAC CLI:" -ForegroundColor Yellow
    Write-Host "  dotnet tool install --global Microsoft.PowerApps.CLI.Tool" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or download from: https://aka.ms/PowerAppsCLI" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

$pacVersion = Get-PacVersion
Write-Success "Power Platform CLI found"
Write-Info "Version:" $pacVersion

# -------------------------------------------------------------------
# Step 2: Validate Source Folder
# -------------------------------------------------------------------

Write-StepHeader "Step 2: Validating CanvasSource Structure"

if (-not (Test-Path $SourceFolder)) {
    Write-Failure "CanvasSource folder not found at: $SourceFolder"
    Write-Host ""
    Write-Host "Make sure you run this script from the package root directory." -ForegroundColor Yellow
    exit 1
}

Write-Success "CanvasSource folder exists"
Write-Info "Path:" $SourceFolder

# Check required files
$requiredFiles = @(
    "Src\App.fx.yaml",
    "Header.json",
    "Properties.json"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $SourceFolder $file
    if (-not (Test-Path $fullPath)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Failure "Missing required files in CanvasSource:"
    $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    exit 1
}

# Count screens
$screenFiles = Get-ChildItem -Path (Join-Path $SourceFolder "Src") -Filter "*.fx.yaml" -ErrorAction SilentlyContinue |
               Where-Object { $_.Name -ne "App.fx.yaml" }
$screenCount = if ($screenFiles) { $screenFiles.Count } else { 0 }
Write-Success "Found $screenCount screen files"

# Pre-check for empty metadata files that could cause issues
Write-Host ""
Write-Host "  Checking source metadata files..." -ForegroundColor Gray

$connectionsFile = Join-Path $SourceFolder "Connections\Connections.json"
if (Test-Path $connectionsFile) {
    if (Test-JsonFileHasContent -FilePath $connectionsFile) {
        Write-Host "    Connections.json: Has content" -ForegroundColor DarkGray
    } else {
        Write-Warn "    Connections.json is empty - will use template version"
    }
}

# -------------------------------------------------------------------
# Step 3: Setup Temp Folders and Unpack Template
# -------------------------------------------------------------------

Write-StepHeader "Step 3: Unpacking Template .msapp"

# Clean up any previous temp folders
Remove-TempFolders
New-Item -Path $TempRoot -ItemType Directory -Force | Out-Null
New-Item -Path $TempUnpackTemplate -ItemType Directory -Force | Out-Null
New-Item -Path $TempMerged -ItemType Directory -Force | Out-Null

Write-Host "  Unpacking template to get baseline structure..." -ForegroundColor Gray
Write-Cmd "pac canvas unpack --msapp `"$TemplateMsappPath`" --sources `"$TempUnpackTemplate`""

try {
    $unpackOutput = & pac canvas unpack --msapp "$TemplateMsappPath" --sources "$TempUnpackTemplate" 2>&1
    $unpackExitCode = $LASTEXITCODE

    if ($unpackOutput) {
        $unpackOutput | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    }

    # Check for errors in output even if exit code is 0
    if ($unpackExitCode -ne 0 -or (Test-PacOutputForErrors -Output $unpackOutput)) {
        Write-Failure "Failed to unpack template .msapp"
        Write-Host "  The template may be corrupted or incompatible." -ForegroundColor Yellow
        Show-PacLogTail -Lines 30
        Remove-TempFolders
        exit 1
    }

    Write-Success "Template unpacked successfully"

} catch {
    Write-Failure "Error unpacking template: $_"
    Remove-TempFolders
    exit 1
}

# Verify CanvasManifest.json exists in unpacked template
$templateManifest = Join-Path $TempUnpackTemplate "CanvasManifest.json"
if (-not (Test-Path $templateManifest)) {
    Write-Failure "Template unpack did not produce CanvasManifest.json"
    Write-Host "  The template .msapp may be too old or incompatible." -ForegroundColor Yellow
    Write-Host "  Try using a fresh canvas app exported from Power Apps Studio." -ForegroundColor Yellow
    Remove-TempFolders
    exit 1
}

Write-Success "CanvasManifest.json found in template"

# List template root files for diagnostics
Write-Host ""
Write-Host "  Template baseline files:" -ForegroundColor Gray
Get-ChildItem -Path $TempUnpackTemplate -File | ForEach-Object { Write-Host "    - $($_.Name)" -ForegroundColor DarkGray }

# -------------------------------------------------------------------
# Step 4: Merge CanvasSource onto Template Baseline
# -------------------------------------------------------------------

Write-StepHeader "Step 4: Merging CanvasSource onto Baseline"

Write-Host "  Copying template baseline structure..." -ForegroundColor Gray

# Copy entire template structure to merged folder
Copy-Item -Path "$TempUnpackTemplate\*" -Destination $TempMerged -Recurse -Force

Write-Success "Baseline structure copied"

Write-Host ""
Write-Host "  Overlaying CanvasSource content..." -ForegroundColor Gray
Write-Host "  (Empty/placeholder files will be skipped to prevent PAC crashes)" -ForegroundColor Gray
Write-Host ""

# ---------------------------------------------------------------
# CRITICAL: Only copy source files/folders that have valid content
# Empty metadata files cause PAC ArgumentNullException crashes
# ---------------------------------------------------------------

# Always copy: Src folder (screens and App.fx.yaml) - this is our actual app logic
$srcSource = Join-Path $SourceFolder "Src"
$srcDest = Join-Path $TempMerged "Src"
if (Test-Path $srcSource) {
    if (Test-Path $srcDest) { Remove-Item -Path $srcDest -Recurse -Force }
    Copy-Item -Path $srcSource -Destination $srcDest -Recurse -Force
    Write-Success "Copied Src/ (screens and App.fx.yaml)"
}

# Copy Header.json (required, should always have content)
$headerSource = Join-Path $SourceFolder "Header.json"
$headerDest = Join-Path $TempMerged "Header.json"
Copy-SourceFileIfValid -SourcePath $headerSource -DestPath $headerDest -Description "Header.json"

# Copy Properties.json (required, should always have content)
$propsSource = Join-Path $SourceFolder "Properties.json"
$propsDest = Join-Path $TempMerged "Properties.json"
Copy-SourceFileIfValid -SourcePath $propsSource -DestPath $propsDest -Description "Properties.json"

# Copy Entropy folder (usually has content)
$entropySource = Join-Path $SourceFolder "Entropy"
$entropyDest = Join-Path $TempMerged "Entropy"
Copy-SourceFolderIfValid -SourcePath $entropySource -DestPath $entropyDest -Description "Entropy/"

# CRITICAL: Only copy Connections if it has valid content
# Empty {} causes ArgumentNullException in PAC
$connSource = Join-Path $SourceFolder "Connections"
$connDest = Join-Path $TempMerged "Connections"
Copy-SourceFolderIfValid -SourcePath $connSource -DestPath $connDest -Description "Connections/"

# Copy pkgs folder if it has content
$pkgsSource = Join-Path $SourceFolder "pkgs"
$pkgsDest = Join-Path $TempMerged "pkgs"
Copy-SourceFolderIfValid -SourcePath $pkgsSource -DestPath $pkgsDest -Description "pkgs/"

# DO NOT copy CanvasManifest.json from source - always use template's version
# This file must be compatible with the PAC CLI version

# Final check: CanvasManifest.json must still exist
$mergedManifest = Join-Path $TempMerged "CanvasManifest.json"
if (-not (Test-Path $mergedManifest)) {
    Write-Failure "CanvasManifest.json was accidentally removed during merge!"
    Remove-TempFolders
    exit 1
}

Write-Host ""
Write-Host "  Merged folder root files:" -ForegroundColor Gray
Get-ChildItem -Path $TempMerged -File | ForEach-Object { Write-Host "    - $($_.Name)" -ForegroundColor DarkGray }

# -------------------------------------------------------------------
# Step 5: Create Output Directory
# -------------------------------------------------------------------

Write-StepHeader "Step 5: Preparing Output Directory"

if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
    Write-Success "Created CanvasApp folder"
} else {
    Write-Success "CanvasApp folder exists"
}

# Remove old .msapp if exists
if (Test-Path $OutputPath) {
    Write-Warn "Removing existing .msapp file..."
    Remove-Item $OutputPath -Force
    Write-Success "Cleaned up old file"
}

Write-Info "Output:" $OutputPath

# -------------------------------------------------------------------
# Step 6: Pack Merged Source to .msapp
# -------------------------------------------------------------------

Write-StepHeader "Step 6: Packing Merged Source to .msapp"

Write-Host "  Running PAC CLI canvas pack..." -ForegroundColor Gray
Write-Host "  This may take 30-60 seconds..." -ForegroundColor Gray
Write-Host ""
Write-Cmd "pac canvas pack --msapp `"$OutputPath`" --sources `"$TempMerged`""
Write-Host ""

$packFailed = $false
$packOutput = @()

try {
    $packOutput = & pac canvas pack --msapp "$OutputPath" --sources "$TempMerged" 2>&1
    $packExitCode = $LASTEXITCODE

    if ($packOutput) {
        Write-Host "  PAC Output:" -ForegroundColor DarkGray
        $packOutput | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        Write-Host ""
    }

    # Check for PAC errors - exit code OR error patterns in output
    if ($packExitCode -ne 0) {
        Write-Failure "PAC canvas pack failed! (Exit code: $packExitCode)"
        $packFailed = $true
    }

    # CRITICAL: Also check for exceptions in output even if exit code is 0
    # PAC sometimes reports "completed successfully" but also shows exceptions
    if (Test-PacOutputForErrors -Output $packOutput) {
        Write-Failure "PAC canvas pack encountered an internal error!"
        Write-Host ""
        Write-Host "  PAC reported an exception during packing." -ForegroundColor Yellow
        Write-Host "  The pack may have appeared to succeed but output is likely missing/corrupt." -ForegroundColor Yellow
        $packFailed = $true
    }

    if ($packFailed) {
        $packOutputStr = $packOutput -join "`n"

        if ($packOutputStr -match "PAS002") {
            Write-Host ""
            Write-Host "  Error PAS002: CanvasManifest.json not found" -ForegroundColor Yellow
            Write-Host "  This indicates the template unpacking failed or was corrupted." -ForegroundColor Yellow
        }

        if ($packOutputStr -match "ArgumentNullException") {
            Write-Host ""
            Write-Host "  Error: ArgumentNullException" -ForegroundColor Yellow
            Write-Host "  This usually means a metadata file (Connections, DataSources) is empty." -ForegroundColor Yellow
            Write-Host "  The script should have skipped empty files - check the merge step output." -ForegroundColor Yellow
        }

        Show-PacLogTail -Lines 50
        if (-not $KeepTempFolders) { Remove-TempFolders }
        exit 1
    }

    Write-Success "Canvas pack completed successfully"

} catch {
    Write-Failure "Error during packing: $_"
    Show-PacLogTail -Lines 50
    if (-not $KeepTempFolders) { Remove-TempFolders }
    exit 1
}

# -------------------------------------------------------------------
# Step 7: Verify Output
# -------------------------------------------------------------------

Write-StepHeader "Step 7: Verifying Output"

if (-not (Test-Path $OutputPath)) {
    Write-Failure ".msapp file was not created!"
    Write-Info "Expected:" $OutputPath
    Write-Host ""
    Write-Host "  Diagnostic info:" -ForegroundColor Yellow
    Write-Info "  Output folder exists:" (Test-Path $OutputFolder)
    Write-Info "  Merged folder exists:" (Test-Path $TempMerged)

    if (Test-Path $OutputFolder) {
        $outputFiles = Get-ChildItem -Path $OutputFolder -ErrorAction SilentlyContinue
        if ($outputFiles) {
            Write-Host "  Files in output folder:" -ForegroundColor Gray
            $outputFiles | ForEach-Object { Write-Host "    - $($_.Name)" -ForegroundColor Gray }
        } else {
            Write-Host "  Output folder is empty" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "  This likely means PAC crashed during packing." -ForegroundColor Yellow
    Write-Host "  Check the PAC log for details:" -ForegroundColor Yellow
    Show-PacLogTail -Lines 50

    if (-not $KeepTempFolders) { Remove-TempFolders }
    exit 1
}

$fileInfo = Get-Item $OutputPath
if ($fileInfo.Length -eq 0) {
    Write-Failure ".msapp file is 0 bytes (invalid)!"
    Write-Host "  This indicates a packing error." -ForegroundColor Yellow
    Show-PacLogTail -Lines 50
    if (-not $KeepTempFolders) { Remove-TempFolders }
    exit 1
}

$fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
$fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)

Write-Success ".msapp file created successfully"
Write-Info "File:" $OutputPath
Write-Info "Size:" "$fileSizeKB KB ($fileSizeMB MB)"
Write-Info "Modified:" $fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")

# Verify internal structure by checking if it's a valid ZIP
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($OutputPath)
    $entryCount = $zip.Entries.Count
    $zip.Dispose()

    Write-Success "Internal structure validated ($entryCount files)"
} catch {
    Write-Warn "Could not validate .msapp internal structure: $_"
}

# -------------------------------------------------------------------
# Cleanup
# -------------------------------------------------------------------

if (-not $KeepTempFolders) {
    Write-Host ""
    Write-Host "  Cleaning up temporary folders..." -ForegroundColor Gray
    Remove-TempFolders
    Write-Success "Temp folders removed"
} else {
    Write-Warn "Temp folders kept at: $TempRoot"
    Write-Host "  Inspect merged folder for debugging: $TempMerged" -ForegroundColor Gray
}

# ===================================================================
# COMPLETION
# ===================================================================

Write-Host ""
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Green
Write-Host "|   [OK] REPACK COMPLETED SUCCESSFULLY                             |" -ForegroundColor Green
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Green
Write-Host ""

Write-Host "Output file:" -ForegroundColor Cyan
Write-Host "  $OutputPath" -ForegroundColor White
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Import the .msapp into Power Apps:" -ForegroundColor White
Write-Host "     - Go to https://make.powerapps.com" -ForegroundColor Gray
Write-Host "     - Apps -> Import canvas app" -ForegroundColor Gray
Write-Host "     - Upload: $OutputName" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. After import, follow the POST_IMPORT_CHECKLIST.md" -ForegroundColor White
Write-Host "     to configure Dataverse connections and placeholders." -ForegroundColor Gray
Write-Host ""

Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  - TROUBLESHOOTING_REPACK.md (Common issues and solutions)" -ForegroundColor Gray
Write-Host "  - REPACK_RUNBOOK.md         (How the pipeline works)" -ForegroundColor Gray
Write-Host "  - REPACK_QA.md              (Validation checklist)" -ForegroundColor Gray
Write-Host ""

Write-Host "==================================================================="  -ForegroundColor Cyan
Write-Host ""
