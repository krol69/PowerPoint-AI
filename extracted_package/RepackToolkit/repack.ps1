# ============================================================================
# CrossDiv Project DB - Canvas App Repack Script
# ============================================================================
# This script uses the Power Platform CLI (pac) to properly pack the
# Canvas App source files into a valid .msapp file.
#
# Prerequisites:
#   1. Install Power Platform CLI: https://aka.ms/PowerAppsCLI
#   2. Or via dotnet: dotnet tool install --global Microsoft.PowerApps.CLI.Tool
#
# Usage:
#   .\repack.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

# Paths (relative to script location)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$SourceDir = Join-Path $RootDir "CanvasSource"
$OutputDir = Join-Path $RootDir "CanvasApp"
$OutputFile = Join-Path $OutputDir "CrossDivProjectDB_REPACKED.msapp"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host " Cross-Div Project DB - Canvas App Repacker" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if pac is available
Write-Host "[1/5] Checking for Power Platform CLI (pac)..." -ForegroundColor Yellow
try {
    $pacVersion = pac --version 2>&1
    Write-Host "      Found: $pacVersion" -ForegroundColor Green
} catch {
    Write-Host "      ERROR: Power Platform CLI (pac) not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "      Install options:" -ForegroundColor Yellow
    Write-Host "        1. Download from: https://aka.ms/PowerAppsCLI" -ForegroundColor White
    Write-Host "        2. Or run: dotnet tool install --global Microsoft.PowerApps.CLI.Tool" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Verify source directory exists
Write-Host "[2/5] Verifying source directory..." -ForegroundColor Yellow
if (-not (Test-Path $SourceDir)) {
    Write-Host "      ERROR: Source directory not found: $SourceDir" -ForegroundColor Red
    exit 1
}
Write-Host "      Found: $SourceDir" -ForegroundColor Green

# Verify required files exist
Write-Host "[3/5] Checking required source files..." -ForegroundColor Yellow
$requiredFiles = @(
    "Header.json",
    "Properties.json",
    "Src\App.fx.yaml",
    "Src\scrHome.fx.yaml"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $SourceDir $file
    if (-not (Test-Path $filePath)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "      ERROR: Missing required files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "        - $file" -ForegroundColor Red
    }
    exit 1
}
Write-Host "      All required files present" -ForegroundColor Green

# Create output directory if needed
Write-Host "[4/5] Preparing output directory..." -ForegroundColor Yellow
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Remove existing output file if present
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile -Force
    Write-Host "      Removed existing .msapp file" -ForegroundColor Gray
}
Write-Host "      Output: $OutputFile" -ForegroundColor Green

# Pack the canvas app
Write-Host "[5/5] Packing Canvas App with pac canvas pack..." -ForegroundColor Yellow
Write-Host ""

try {
    # Run pac canvas pack
    $packResult = pac canvas pack --msapp $OutputFile --sources $SourceDir 2>&1
    
    # Check for success
    if (Test-Path $OutputFile) {
        $fileSize = (Get-Item $OutputFile).Length / 1KB
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Green
        Write-Host " SUCCESS! Canvas App packed successfully" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Green
        Write-Host ""
        Write-Host " Output file: $OutputFile" -ForegroundColor White
        Write-Host " File size:   $([math]::Round($fileSize, 2)) KB" -ForegroundColor White
        Write-Host ""
        Write-Host " Next steps:" -ForegroundColor Yellow
        Write-Host "   1. Go to make.powerapps.com" -ForegroundColor White
        Write-Host "   2. Click Apps > Import canvas app" -ForegroundColor White
        Write-Host "   3. Select the .msapp file" -ForegroundColor White
        Write-Host "   4. Follow POST_IMPORT_CHECKLIST.md" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "WARNING: Pack command completed but output file not found." -ForegroundColor Yellow
        Write-Host "Output from pac:" -ForegroundColor Gray
        Write-Host $packResult -ForegroundColor Gray
        Write-Host ""
        Write-Host "Try running manually:" -ForegroundColor Yellow
        Write-Host "  pac canvas pack --msapp `"$OutputFile`" --sources `"$SourceDir`"" -ForegroundColor White
    }
} catch {
    Write-Host ""
    Write-Host "ERROR during packing:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Try running manually:" -ForegroundColor Yellow
    Write-Host "  pac canvas pack --msapp `"$OutputFile`" --sources `"$SourceDir`"" -ForegroundColor White
    exit 1
}
