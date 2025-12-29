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

.PARAMETER TemplateMsappPath
    Path to a template .msapp file (required). This file provides the correct
    unpack format including CanvasManifest.json. You can export any canvas app
    from Power Apps Studio to use as a template.

.PARAMETER OutputName
    Output .msapp file name (default: CrossDivProjectDB.msapp)

.PARAMETER KeepTempFolders
    Keep temporary folders after completion (useful for debugging)

.NOTES
    Prerequisites:
    - Power Platform CLI must be installed (pac canvas pack/unpack)
    - A template .msapp file from Power Apps
    - Run from the package root directory (where CanvasSource folder exists)

.EXAMPLE
    .\RepackToolkit\repack.ps1 -TemplateMsappPath "C:\Templates\BlankApp.msapp"
    .\RepackToolkit\repack.ps1 -TemplateMsappPath ".\template.msapp" -OutputName "MyApp.msapp"
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

# Temp folder for merge operations
$TempRoot = Join-Path $RepoRoot "RepackToolkit\.repack_temp"
$TempUnpackTemplate = Join-Path $TempRoot "template_unpacked"
$TempMerged = Join-Path $TempRoot "merged"

# ===================================================================
# FUNCTIONS
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
    Write-Host "[!] $Message" -ForegroundColor Yellow
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

function Copy-FolderContents {
    param(
        [string]$Source,
        [string]$Destination,
        [string[]]$ExcludeFiles = @()
    )

    if (-not (Test-Path $Destination)) {
        New-Item -Path $Destination -ItemType Directory -Force | Out-Null
    }

    Get-ChildItem -Path $Source -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($Source.Length + 1)
        $targetPath = Join-Path $Destination $relativePath

        # Check exclusions
        $excluded = $false
        foreach ($exclude in $ExcludeFiles) {
            if ($relativePath -like $exclude) {
                $excluded = $true
                break
            }
        }

        if (-not $excluded) {
            if ($_.PSIsContainer) {
                if (-not (Test-Path $targetPath)) {
                    New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
                }
            } else {
                $targetDir = Split-Path -Parent $targetPath
                if (-not (Test-Path $targetDir)) {
                    New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
                }
                Copy-Item -Path $_.FullName -Destination $targetPath -Force
            }
        }
    }
}

# ===================================================================
# MAIN SCRIPT
# ===================================================================

Write-Host ""
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host "|   Power Apps Canvas Source Repacker (Template Baseline)          |" -ForegroundColor Magenta
Write-Host "|   Cross-Divisional Project Database                              |" -ForegroundColor Magenta
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Magenta
Write-Host ""

# -------------------------------------------------------------------
# Step 0: Check Template Parameter
# -------------------------------------------------------------------

Write-StepHeader "Step 0: Checking Template .msapp"

# Check environment variable fallback
if ([string]::IsNullOrWhiteSpace($TemplateMsappPath)) {
    $TemplateMsappPath = $env:REPACK_TEMPLATE_MSAPP
}

if ([string]::IsNullOrWhiteSpace($TemplateMsappPath)) {
    Write-Failure "Template .msapp path is required!"
    Write-Host ""
    Write-Host "  The template baseline method requires a template .msapp file." -ForegroundColor Yellow
    Write-Host "  This file provides CanvasManifest.json (required by PAC CLI 1.51+)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Usage:" -ForegroundColor Cyan
    Write-Host "    .\repack.ps1 -TemplateMsappPath `"C:\path\to\template.msapp`"" -ForegroundColor White
    Write-Host ""
    Write-Host "  Or set environment variable:" -ForegroundColor Cyan
    Write-Host "    `$env:REPACK_TEMPLATE_MSAPP = `"C:\path\to\template.msapp`"" -ForegroundColor White
    Write-Host ""
    Write-Host "  How to get a template .msapp:" -ForegroundColor Cyan
    Write-Host "    1. Create a blank canvas app in Power Apps Studio" -ForegroundColor Gray
    Write-Host "    2. Save and export it as .msapp (File > Save As > This computer)" -ForegroundColor Gray
    Write-Host "    3. Use that .msapp as your template" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  See REPACK_RUNBOOK.md for detailed instructions." -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Resolve to absolute path
$TemplateMsappPath = [System.IO.Path]::GetFullPath($TemplateMsappPath)

if (-not (Test-Path $TemplateMsappPath)) {
    Write-Failure "Template .msapp not found: $TemplateMsappPath"
    Write-Host ""
    Write-Host "  Make sure the file exists and the path is correct." -ForegroundColor Yellow
    Write-Host ""
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
    Write-Host "Please install PAC CLI first:" -ForegroundColor Yellow
    Write-Host "  1. Install via PowerShell:" -ForegroundColor White
    Write-Host "     dotnet tool install --global Microsoft.PowerApps.CLI.Tool" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  OR" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  2. Download installer:" -ForegroundColor White
    Write-Host "     https://aka.ms/PowerAppsCLI" -ForegroundColor Cyan
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
$screenFiles = Get-ChildItem -Path (Join-Path $SourceFolder "Src") -Filter "*.fx.yaml" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "App.fx.yaml" }
$screenCount = if ($screenFiles) { $screenFiles.Count } else { 0 }
Write-Success "Found $screenCount screen files"
if ($screenFiles) {
    Write-Info "Screens:" ($screenFiles.Name -join ", ")
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

    if ($unpackOutput) {
        $unpackOutput | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Failure "Failed to unpack template .msapp (Exit code: $LASTEXITCODE)"
        Write-Host "  The template may be corrupted or incompatible." -ForegroundColor Yellow
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

Write-Host "  Overlaying CanvasSource content (preserving manifest)..." -ForegroundColor Gray

# Overlay CanvasSource content, but DO NOT overwrite CanvasManifest.json
# We need to copy: Src/, Header.json, Properties.json, Entropy/, Connections/, pkgs/

# Copy Src folder (screens and App.fx.yaml)
$srcSource = Join-Path $SourceFolder "Src"
$srcDest = Join-Path $TempMerged "Src"
if (Test-Path $srcSource) {
    if (Test-Path $srcDest) { Remove-Item -Path $srcDest -Recurse -Force }
    Copy-Item -Path $srcSource -Destination $srcDest -Recurse -Force
    Write-Success "Copied Src/ (screens and App.fx.yaml)"
}

# Copy Header.json
$headerSource = Join-Path $SourceFolder "Header.json"
$headerDest = Join-Path $TempMerged "Header.json"
if (Test-Path $headerSource) {
    Copy-Item -Path $headerSource -Destination $headerDest -Force
    Write-Success "Copied Header.json"
}

# Copy Properties.json
$propsSource = Join-Path $SourceFolder "Properties.json"
$propsDest = Join-Path $TempMerged "Properties.json"
if (Test-Path $propsSource) {
    Copy-Item -Path $propsSource -Destination $propsDest -Force
    Write-Success "Copied Properties.json"
}

# Copy Entropy folder
$entropySource = Join-Path $SourceFolder "Entropy"
$entropyDest = Join-Path $TempMerged "Entropy"
if (Test-Path $entropySource) {
    if (Test-Path $entropyDest) { Remove-Item -Path $entropyDest -Recurse -Force }
    Copy-Item -Path $entropySource -Destination $entropyDest -Recurse -Force
    Write-Success "Copied Entropy/"
}

# Copy Connections folder
$connSource = Join-Path $SourceFolder "Connections"
$connDest = Join-Path $TempMerged "Connections"
if (Test-Path $connSource) {
    if (Test-Path $connDest) { Remove-Item -Path $connDest -Recurse -Force }
    Copy-Item -Path $connSource -Destination $connDest -Recurse -Force
    Write-Success "Copied Connections/"
}

# Copy pkgs folder
$pkgsSource = Join-Path $SourceFolder "pkgs"
$pkgsDest = Join-Path $TempMerged "pkgs"
if (Test-Path $pkgsSource) {
    if (Test-Path $pkgsDest) { Remove-Item -Path $pkgsDest -Recurse -Force }
    Copy-Item -Path $pkgsSource -Destination $pkgsDest -Recurse -Force
    Write-Success "Copied pkgs/"
}

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

try {
    $packOutput = & pac canvas pack --msapp "$OutputPath" --sources "$TempMerged" 2>&1

    if ($packOutput) {
        Write-Host "  PAC Output:" -ForegroundColor DarkGray
        $packOutput | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        Write-Host ""
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Failure "PAC canvas pack failed! (Exit code: $LASTEXITCODE)"

        # Check for common errors
        $packOutputStr = $packOutput -join "`n"
        if ($packOutputStr -match "PAS002") {
            Write-Host ""
            Write-Host "  Error PAS002 indicates CanvasManifest.json is still missing." -ForegroundColor Yellow
            Write-Host "  This should not happen with template baseline method." -ForegroundColor Yellow
            Write-Host "  Check that your template .msapp is valid." -ForegroundColor Yellow
        }

        if (-not $KeepTempFolders) { Remove-TempFolders }
        exit 1
    }

    Write-Success "Canvas pack completed successfully"

} catch {
    Write-Failure "Error during packing: $_"
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

    if (-not $KeepTempFolders) { Remove-TempFolders }
    exit 1
}

$fileInfo = Get-Item $OutputPath
if ($fileInfo.Length -eq 0) {
    Write-Failure ".msapp file is 0 bytes (invalid)!"
    Write-Host "  This indicates a packing error." -ForegroundColor Yellow
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
    Write-Warn "Could not validate .msapp internal structure"
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
Write-Host "  - REPACK_RUNBOOK.md         (How the pipeline works)" -ForegroundColor Gray
Write-Host "  - REPACK_QA.md              (Validation checklist)" -ForegroundColor Gray
Write-Host "  - POST_IMPORT_CHECKLIST.md  (Setup steps)" -ForegroundColor Gray
Write-Host "  - DATAVERSE_SCHEMA.md       (Table creation)" -ForegroundColor Gray
Write-Host ""

Write-Host "==================================================================="  -ForegroundColor Cyan
Write-Host ""
