@echo off
REM ===================================================================
REM Power Apps Canvas Source Repacker (Batch Version)
REM Cross-Divisional Project Database
REM ===================================================================
REM
REM This script uses ASCII-only output for maximum compatibility.
REM For best results, run from Command Prompt (cmd.exe).
REM
REM ===================================================================

setlocal enabledelayedexpansion

REM Configuration
set "OUTPUT_NAME=CrossDivProjectDB.msapp"
set "SOURCE_FOLDER=%~dp0..\CanvasSource"
set "OUTPUT_FOLDER=%~dp0..\CanvasApp"
set "OUTPUT_PATH=%OUTPUT_FOLDER%\%OUTPUT_NAME%"

echo.
echo +------------------------------------------------------------------+
echo ^|   Power Apps Canvas Source Repacker                              ^|
echo ^|   Cross-Divisional Project Database                              ^|
echo +------------------------------------------------------------------+
echo.

REM -------------------------------------------------------------------
REM Step 1: Check PAC CLI
REM -------------------------------------------------------------------

echo ===================================================================
echo  Step 1: Verifying Prerequisites
echo ===================================================================
echo.

where pac >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Power Platform CLI ^(pac^) not found!
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
    echo [FAIL] PAC CLI found but not working correctly!
    echo.
    pause
    exit /b 1
)

echo [OK] Power Platform CLI found
for /f "tokens=*" %%i in ('pac --version 2^>^&1') do (
    echo   Version: %%i
    goto :version_done
)
:version_done
echo.

REM -------------------------------------------------------------------
REM Step 2: Validate Source Folder
REM -------------------------------------------------------------------

echo ===================================================================
echo  Step 2: Validating CanvasSource Structure
echo ===================================================================
echo.

if not exist "%SOURCE_FOLDER%" (
    echo [FAIL] CanvasSource folder not found!
    echo   Expected: %SOURCE_FOLDER%
    echo.
    echo Make sure you run this script from the package root directory.
    echo.
    pause
    exit /b 1
)

echo [OK] CanvasSource folder exists
echo   Path: %SOURCE_FOLDER%
echo.

REM Check required files
if not exist "%SOURCE_FOLDER%\Src\App.fx.yaml" (
    echo [FAIL] Missing: Src\App.fx.yaml
    pause
    exit /b 1
)

if not exist "%SOURCE_FOLDER%\Header.json" (
    echo [FAIL] Missing: Header.json
    pause
    exit /b 1
)

if not exist "%SOURCE_FOLDER%\Properties.json" (
    echo [FAIL] Missing: Properties.json
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

echo [OK] Found !SCREEN_COUNT! screen files
echo.

REM -------------------------------------------------------------------
REM Step 3: Prepare Output Directory
REM -------------------------------------------------------------------

echo ===================================================================
echo  Step 3: Preparing Output Directory
echo ===================================================================
echo.

if not exist "%OUTPUT_FOLDER%" (
    mkdir "%OUTPUT_FOLDER%"
    echo [OK] Created CanvasApp folder
) else (
    echo [OK] CanvasApp folder exists
)

REM Remove old .msapp if exists
if exist "%OUTPUT_PATH%" (
    echo   Removing existing .msapp file...
    del /f /q "%OUTPUT_PATH%"
    echo [OK] Cleaned up old file
)

echo   Output: %OUTPUT_PATH%
echo.

REM -------------------------------------------------------------------
REM Step 4: Pack Canvas Source
REM -------------------------------------------------------------------

echo ===================================================================
echo  Step 4: Packing Canvas Source to .msapp
echo ===================================================================
echo.

echo   Running PAC CLI canvas pack...
echo   This may take 30-60 seconds...
echo.

pac canvas pack --msapp "%OUTPUT_PATH%" --sources "%SOURCE_FOLDER%"

if errorlevel 1 (
    echo.
    echo [FAIL] PAC canvas pack failed!
    echo   Check the error messages above.
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Canvas pack completed successfully
echo.

REM -------------------------------------------------------------------
REM Step 5: Verify Output
REM -------------------------------------------------------------------

echo ===================================================================
echo  Step 5: Verifying Output
echo ===================================================================
echo.

if not exist "%OUTPUT_PATH%" (
    echo [FAIL] .msapp file was not created!
    echo   Expected: %OUTPUT_PATH%
    echo.
    pause
    exit /b 1
)

REM Check file size
for %%f in ("%OUTPUT_PATH%") do set "FILE_SIZE=%%~zf"
if !FILE_SIZE! equ 0 (
    echo [FAIL] .msapp file is 0 bytes ^(invalid^)!
    echo   This indicates a packing error.
    echo.
    pause
    exit /b 1
)

set /a FILE_SIZE_KB=!FILE_SIZE! / 1024
set /a FILE_SIZE_MB=!FILE_SIZE! / 1048576

echo [OK] .msapp file created successfully
echo   File: %OUTPUT_PATH%
echo   Size: !FILE_SIZE_KB! KB ^(!FILE_SIZE_MB! MB^)
echo.

REM ===================================================================
REM COMPLETION
REM ===================================================================

echo.
echo +------------------------------------------------------------------+
echo ^|   [OK] REPACK COMPLETED SUCCESSFULLY                             ^|
echo +------------------------------------------------------------------+
echo.

echo Next Steps:
echo   1. Import the .msapp into Power Apps:
echo      - Go to https://make.powerapps.com
echo      - Apps -^> Import canvas app
echo      - Upload: %OUTPUT_NAME%
echo.
echo   2. After import, follow the POST_IMPORT_CHECKLIST.md
echo      to configure Dataverse connections and placeholders.
echo.

echo Documentation:
echo   - POST_IMPORT_CHECKLIST.md  ^(Setup steps^)
echo   - DATAVERSE_SCHEMA.md       ^(Table creation^)
echo   - THEME_DOCUMENTATION.md    ^(UI customization^)
echo.

echo ===================================================================
echo.

pause
