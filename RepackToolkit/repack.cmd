@echo off
REM ═══════════════════════════════════════════════════════════════
REM Power Apps Canvas Source Repacker (Batch Version)
REM Cross-Divisional Project Database
REM ═══════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

REM Configuration
set "OUTPUT_NAME=CrossDivProjectDB.msapp"
set "SOURCE_FOLDER=%~dp0..\CanvasSource"
set "OUTPUT_FOLDER=%~dp0..\CanvasApp"
set "OUTPUT_PATH=%OUTPUT_FOLDER%\%OUTPUT_NAME%"

REM Colors (Windows 10+ only)
set "COLOR_RESET=[0m"
set "COLOR_GREEN=[92m"
set "COLOR_RED=[91m"
set "COLOR_YELLOW=[93m"
set "COLOR_CYAN=[96m"
set "COLOR_GRAY=[90m"

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║   Power Apps Canvas Source Repacker                           ║
echo ║   Cross-Divisional Project Database                            ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM ─────────────────────────────────────────────────────────────────
REM Step 1: Check PAC CLI
REM ─────────────────────────────────────────────────────────────────

echo ═══════════════════════════════════════════════════════════════
echo  Step 1: Verifying Prerequisites
echo ═══════════════════════════════════════════════════════════════
echo.

where pac >nul 2>&1
if errorlevel 1 (
    echo %COLOR_RED%✗ Power Platform CLI ^(pac^) not found!%COLOR_RESET%
    echo.
    echo Please install PAC CLI first:
    echo   1. Install via PowerShell:
    echo      dotnet tool install --global Microsoft.PowerApps.CLI.Tool
    echo.
    echo   OR
    echo.
    echo   2. Download installer:
    echo      https://aka.ms/PowerAppsCLI
    echo.
    echo For more info: https://learn.microsoft.com/power-platform/developer/cli/introduction
    echo.
    pause
    exit /b 1
)

pac --version >nul 2>&1
if errorlevel 1 (
    echo %COLOR_RED%✗ PAC CLI found but not working correctly!%COLOR_RESET%
    echo.
    pause
    exit /b 1
)

echo %COLOR_GREEN%✓ Power Platform CLI found%COLOR_RESET%
for /f "tokens=*" %%i in ('pac --version 2^>^&1') do (
    echo   Version: %%i
    goto :version_done
)
:version_done
echo.

REM ─────────────────────────────────────────────────────────────────
REM Step 2: Validate Source Folder
REM ─────────────────────────────────────────────────────────────────

echo ═══════════════════════════════════════════════════════════════
echo  Step 2: Validating CanvasSource Structure
echo ═══════════════════════════════════════════════════════════════
echo.

if not exist "%SOURCE_FOLDER%" (
    echo %COLOR_RED%✗ CanvasSource folder not found!%COLOR_RESET%
    echo   Expected: %SOURCE_FOLDER%
    echo.
    echo Make sure you run this script from the package root directory.
    echo.
    pause
    exit /b 1
)

echo %COLOR_GREEN%✓ CanvasSource folder exists%COLOR_RESET%
echo   Path: %SOURCE_FOLDER%
echo.

REM Check required files
if not exist "%SOURCE_FOLDER%\Src\App.fx.yaml" (
    echo %COLOR_RED%✗ Missing: Src\App.fx.yaml%COLOR_RESET%
    pause
    exit /b 1
)

if not exist "%SOURCE_FOLDER%\Header.json" (
    echo %COLOR_RED%✗ Missing: Header.json%COLOR_RESET%
    pause
    exit /b 1
)

if not exist "%SOURCE_FOLDER%\Properties.json" (
    echo %COLOR_RED%✗ Missing: Properties.json%COLOR_RESET%
    pause
    exit /b 1
)

REM Count screens
set "SCREEN_COUNT=0"
for %%f in ("%SOURCE_FOLDER%\Src\*.fx.yaml") do (
    if /i not "%%~nxf"=="App.fx.yaml" (
        set /a SCREEN_COUNT+=1
    )
)

echo %COLOR_GREEN%✓ Found !SCREEN_COUNT! screen files%COLOR_RESET%
echo.

REM ─────────────────────────────────────────────────────────────────
REM Step 3: Prepare Output Directory
REM ─────────────────────────────────────────────────────────────────

echo ═══════════════════════════════════════════════════════════════
echo  Step 3: Preparing Output Directory
echo ═══════════════════════════════════════════════════════════════
echo.

if not exist "%OUTPUT_FOLDER%" (
    mkdir "%OUTPUT_FOLDER%"
    echo %COLOR_GREEN%✓ Created CanvasApp folder%COLOR_RESET%
) else (
    echo %COLOR_GREEN%✓ CanvasApp folder exists%COLOR_RESET%
)

REM Remove old .msapp if exists
if exist "%OUTPUT_PATH%" (
    echo   Removing existing .msapp file...
    del /f /q "%OUTPUT_PATH%"
    echo %COLOR_GREEN%✓ Cleaned up old file%COLOR_RESET%
)

echo   Output: %OUTPUT_PATH%
echo.

REM ─────────────────────────────────────────────────────────────────
REM Step 4: Pack Canvas Source
REM ─────────────────────────────────────────────────────────────────

echo ═══════════════════════════════════════════════════════════════
echo  Step 4: Packing Canvas Source to .msapp
echo ═══════════════════════════════════════════════════════════════
echo.

echo   Running PAC CLI canvas pack...
echo   This may take 30-60 seconds...
echo.

pac canvas pack --msapp "%OUTPUT_PATH%" --sources "%SOURCE_FOLDER%"

if errorlevel 1 (
    echo.
    echo %COLOR_RED%✗ PAC canvas pack failed!%COLOR_RESET%
    echo   Check the error messages above.
    echo.
    pause
    exit /b 1
)

echo.
echo %COLOR_GREEN%✓ Canvas pack completed successfully%COLOR_RESET%
echo.

REM ─────────────────────────────────────────────────────────────────
REM Step 5: Verify Output
REM ─────────────────────────────────────────────────────────────────

echo ═══════════════════════════════════════════════════════════════
echo  Step 5: Verifying Output
echo ═══════════════════════════════════════════════════════════════
echo.

if not exist "%OUTPUT_PATH%" (
    echo %COLOR_RED%✗ .msapp file was not created!%COLOR_RESET%
    echo   Expected: %OUTPUT_PATH%
    echo.
    pause
    exit /b 1
)

REM Check file size
for %%f in ("%OUTPUT_PATH%") do set "FILE_SIZE=%%~zf"
if !FILE_SIZE! equ 0 (
    echo %COLOR_RED%✗ .msapp file is 0 bytes ^(invalid^)!%COLOR_RESET%
    echo   This indicates a packing error.
    echo.
    pause
    exit /b 1
)

set /a FILE_SIZE_KB=!FILE_SIZE! / 1024
set /a FILE_SIZE_MB=!FILE_SIZE! / 1048576

echo %COLOR_GREEN%✓ .msapp file created successfully%COLOR_RESET%
echo   File: %OUTPUT_PATH%
echo   Size: !FILE_SIZE_KB! KB ^(!FILE_SIZE_MB! MB^)
echo.

REM ═══════════════════════════════════════════════════════════════
REM COMPLETION
REM ═══════════════════════════════════════════════════════════════

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║   ✓ REPACK COMPLETED SUCCESSFULLY                              ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo Next Steps:
echo   1. Import the .msapp into Power Apps:
echo      - Go to https://make.powerapps.com
echo      - Apps → Import canvas app
echo      - Upload: %OUTPUT_NAME%
echo.
echo   2. After import, follow the POST_IMPORT_CHECKLIST.md
echo      to configure Dataverse connections and placeholders.
echo.

echo Documentation:
echo   - POST_IMPORT_CHECKLIST.md  ^(Setup steps^)
echo   - DATAVERSE_SCHEMA.md        ^(Table creation^)
echo   - THEME_DOCUMENTATION.md     ^(UI customization^)
echo.

echo ═══════════════════════════════════════════════════════════════
echo.

pause
