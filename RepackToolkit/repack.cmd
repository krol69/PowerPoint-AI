@echo off
REM ===================================================================
REM Power Apps Canvas Source Repacker (Batch Wrapper)
REM Cross-Divisional Project Database
REM ===================================================================
REM
REM This is a thin wrapper that calls the PowerShell script.
REM For full functionality, use the PowerShell script directly.
REM
REM Usage:
REM   repack.cmd "C:\path\to\template.msapp"
REM   repack.cmd "C:\path\to\template.msapp" "CustomOutput.msapp"
REM
REM ===================================================================

setlocal enabledelayedexpansion

echo.
echo +------------------------------------------------------------------+
echo ^|   Power Apps Canvas Source Repacker (CMD Wrapper)                ^|
echo ^|   Cross-Divisional Project Database                              ^|
echo +------------------------------------------------------------------+
echo.

REM Check if template path was provided
if "%~1"=="" (
    echo [FAIL] Template .msapp path is required!
    echo.
    echo Usage:
    echo   repack.cmd "C:\path\to\template.msapp"
    echo   repack.cmd "C:\path\to\template.msapp" "CustomOutput.msapp"
    echo.
    echo Or set environment variable:
    echo   set REPACK_TEMPLATE_MSAPP=C:\path\to\template.msapp
    echo   repack.cmd
    echo.
    echo How to get a template .msapp:
    echo   1. Create a blank canvas app in Power Apps Studio
    echo   2. Save and export it as .msapp (File ^> Save As ^> This computer)
    echo   3. Use that .msapp as your template
    echo.
    echo See REPACK_RUNBOOK.md for detailed instructions.
    echo.
    pause
    exit /b 1
)

set "TEMPLATE_PATH=%~1"
set "OUTPUT_NAME=%~2"

REM Check if PowerShell is available
where powershell >nul 2>&1
if errorlevel 1 (
    echo [FAIL] PowerShell not found!
    echo.
    echo This wrapper requires PowerShell to be available.
    echo PowerShell is included with Windows 7 SP1 and later.
    echo.
    pause
    exit /b 1
)

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Build the PowerShell command
if "%OUTPUT_NAME%"=="" (
    set "PS_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_DIR%repack.ps1\" -TemplateMsappPath \"%TEMPLATE_PATH%\""
) else (
    set "PS_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_DIR%repack.ps1\" -TemplateMsappPath \"%TEMPLATE_PATH%\" -OutputName \"%OUTPUT_NAME%\""
)

echo Calling PowerShell script...
echo   Command: !PS_CMD!
echo.

REM Execute PowerShell script
%PS_CMD%

REM Capture exit code
set "EXIT_CODE=%ERRORLEVEL%"

if %EXIT_CODE% neq 0 (
    echo.
    echo [FAIL] Repack failed with exit code: %EXIT_CODE%
    echo.
    pause
    exit /b %EXIT_CODE%
)

echo.
echo ===================================================================
echo.

pause
exit /b 0
