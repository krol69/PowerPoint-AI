<#
.SYNOPSIS
    Repack Power Apps Canvas Source to .msapp binary

.DESCRIPTION
    This script uses Power Platform CLI (pac) to pack the CanvasSource folder
    into a compiled .msapp file that can be imported into Power Apps.

.NOTES
    Prerequisites:
    - Power Platform CLI must be installed
    - Run from the package root directory (where CanvasSource folder exists)

.EXAMPLE
    .\RepackToolkit\repack.ps1
    .\RepackToolkit\repack.ps1 -Verbose
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Output .msapp file name")]
    [string]$OutputName = "CrossDivProjectDB.msapp",

    [Parameter(HelpMessage="Skip PAC CLI version check")]
    [switch]$SkipVersionCheck
)

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

$ErrorActionPreference = "Stop"
$SourceFolder = Join-Path $PSScriptRoot "..\CanvasSource"
$OutputFolder = Join-Path $PSScriptRoot "..\CanvasApp"
$OutputPath = Join-Path $OutputFolder $OutputName

# ═══════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════

function Write-StepHeader {
    param([string]$Message)
    Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-InfoItem {
    param([string]$Label, [string]$Value)
    Write-Host "  $Label " -NoNewline -ForegroundColor Gray
    Write-Host $Value -ForegroundColor White
}

function Test-PacCli {
    try {
        $pacVersion = & pac --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            return $false
        }
        return $true
    } catch {
        return $false
    }
}

# ═══════════════════════════════════════════════════════════════
# MAIN SCRIPT
# ═══════════════════════════════════════════════════════════════

Write-Host "`n"
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   Power Apps Canvas Source Repacker                           ║" -ForegroundColor Magenta
Write-Host "║   Cross-Divisional Project Database                            ║" -ForegroundColor Magenta
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host "`n"

# ─────────────────────────────────────────────────────────────────
# Step 1: Verify PAC CLI Installation
# ─────────────────────────────────────────────────────────────────

Write-StepHeader "Step 1: Verifying Prerequisites"

if (-not (Test-PacCli)) {
    Write-Host "✗ Power Platform CLI (pac) not found!" -ForegroundColor Red
    Write-Host "`nPlease install PAC CLI first:" -ForegroundColor Yellow
    Write-Host "  1. Install via PowerShell:" -ForegroundColor White
    Write-Host "     dotnet tool install --global Microsoft.PowerApps.CLI.Tool" -ForegroundColor Cyan
    Write-Host "`n  OR" -ForegroundColor Yellow
    Write-Host "`n  2. Download installer:" -ForegroundColor White
    Write-Host "     https://aka.ms/PowerAppsCLI" -ForegroundColor Cyan
    Write-Host "`nFor more info: https://learn.microsoft.com/power-platform/developer/cli/introduction`n" -ForegroundColor Gray
    exit 1
}

$pacVersionOutput = & pac --version 2>&1 | Out-String
Write-Success "Power Platform CLI found"
Write-InfoItem "Version:" ($pacVersionOutput -split "`n")[0].Trim()

# ─────────────────────────────────────────────────────────────────
# Step 2: Validate Source Folder
# ─────────────────────────────────────────────────────────────────

Write-StepHeader "Step 2: Validating CanvasSource Structure"

if (-not (Test-Path $SourceFolder)) {
    Write-Host "✗ CanvasSource folder not found at: $SourceFolder" -ForegroundColor Red
    Write-Host "`nMake sure you run this script from the package root directory.`n" -ForegroundColor Yellow
    exit 1
}

Write-Success "CanvasSource folder exists"
Write-InfoItem "Path:" $SourceFolder

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
    Write-Host "`n✗ Missing required files:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
    Write-Host "`nThe CanvasSource folder structure is invalid.`n" -ForegroundColor Red
    exit 1
}

# Count screens
$screenFiles = Get-ChildItem -Path (Join-Path $SourceFolder "Src") -Filter "*.fx.yaml" | Where-Object { $_.Name -ne "App.fx.yaml" }
Write-Success "Found $($screenFiles.Count) screen files"
Write-InfoItem "Screens:" ($screenFiles.Name -join ", ")

# ─────────────────────────────────────────────────────────────────
# Step 3: Create Output Directory
# ─────────────────────────────────────────────────────────────────

Write-StepHeader "Step 3: Preparing Output Directory"

if (-not (Test-Path $OutputFolder)) {
    New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null
    Write-Success "Created CanvasApp folder"
} else {
    Write-Success "CanvasApp folder exists"
}

# Remove old .msapp if exists
if (Test-Path $OutputPath) {
    Write-Host "  Removing existing .msapp file..." -ForegroundColor Yellow
    Remove-Item $OutputPath -Force
    Write-Success "Cleaned up old file"
}

Write-InfoItem "Output:" $OutputPath

# ─────────────────────────────────────────────────────────────────
# Step 4: Pack Canvas Source
# ─────────────────────────────────────────────────────────────────

Write-StepHeader "Step 4: Packing Canvas Source to .msapp"

Write-Host "  Running PAC CLI canvas pack..." -ForegroundColor Gray
Write-Host "  This may take 30-60 seconds...`n" -ForegroundColor Gray

try {
    $packOutput = & pac canvas pack `
        --msapp $OutputPath `
        --sources $SourceFolder `
        2>&1 | Out-String

    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ PAC canvas pack failed!" -ForegroundColor Red
        Write-Host "`nOutput:" -ForegroundColor Yellow
        Write-Host $packOutput
        exit 1
    }

    Write-Success "Canvas pack completed successfully"

} catch {
    Write-Host "✗ Error during packing: $_" -ForegroundColor Red
    exit 1
}

# ─────────────────────────────────────────────────────────────────
# Step 5: Verify Output
# ─────────────────────────────────────────────────────────────────

Write-StepHeader "Step 5: Verifying Output"

if (-not (Test-Path $OutputPath)) {
    Write-Host "✗ .msapp file was not created!" -ForegroundColor Red
    Write-Host "  Expected: $OutputPath`n" -ForegroundColor Yellow
    exit 1
}

$fileInfo = Get-Item $OutputPath
if ($fileInfo.Length -eq 0) {
    Write-Host "✗ .msapp file is 0 bytes (invalid)!" -ForegroundColor Red
    Write-Host "  This indicates a packing error.`n" -ForegroundColor Yellow
    exit 1
}

$fileSizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
$fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)

Write-Success ".msapp file created successfully"
Write-InfoItem "File:" $OutputPath
Write-InfoItem "Size:" "$fileSizeKB KB ($fileSizeMB MB)"
Write-InfoItem "Modified:" $fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")

# Optional: Verify internal structure by checking if it's a valid ZIP
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($OutputPath)
    $entryCount = $zip.Entries.Count
    $zip.Dispose()

    Write-Success "Internal structure validated ($entryCount files)"
} catch {
    Write-Host "⚠ Warning: Could not validate .msapp internal structure" -ForegroundColor Yellow
}

# ═══════════════════════════════════════════════════════════════
# COMPLETION
# ═══════════════════════════════════════════════════════════════

Write-Host "`n"
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✓ REPACK COMPLETED SUCCESSFULLY                              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n"

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Import the .msapp into Power Apps:" -ForegroundColor White
Write-Host "     - Go to https://make.powerapps.com" -ForegroundColor Gray
Write-Host "     - Apps → Import canvas app" -ForegroundColor Gray
Write-Host "     - Upload: $OutputName" -ForegroundColor Gray
Write-Host "`n  2. After import, follow the POST_IMPORT_CHECKLIST.md" -ForegroundColor White
Write-Host "     to configure Dataverse connections and placeholders.`n" -ForegroundColor Gray

Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  - POST_IMPORT_CHECKLIST.md  (Setup steps)" -ForegroundColor Gray
Write-Host "  - DATAVERSE_SCHEMA.md        (Table creation)" -ForegroundColor Gray
Write-Host "  - THEME_DOCUMENTATION.md     (UI customization)`n" -ForegroundColor Gray

Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
