@echo off
REM ===================================================================
REM Power Apps Canvas Source Repacker (CMD Wrapper v3.1)
REM Cross-Divisional Project Database
REM ===================================================================
REM
REM This is a thin wrapper that calls the PowerShell script.
REM For full functionality and better error handling, use PowerShell directly.
REM
REM Usage:
REM   repack.cmd
REM   repack.cmd "C:\path\to\template.msapp"
REM   repack.cmd "C:\path\to\template.msapp" "CustomOutput.msapp"
REM
REM Template Resolution (in order):
REM   1. First argument to this script
REM   2. REPACK_TEMPLATE_MSAPP environment variable
REM   3. RepackToolkit\template\BlankApp.msapp (bundled)
REM
REM ===================================================================

setlocal enabledelayedexpansion

echo.
echo +------------------------------------------------------------------+
echo ^|   Power Apps Canvas Source Repacker (CMD Wrapper)                ^|
echo ^|   Cross-Divisional Project Database                              ^|
echo +------------------------------------------------------------------+
echo.

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

REM Build arguments for PowerShell
set "PS_ARGS="

REM Add template path if provided
if not "%~1"=="" (
    set "PS_ARGS=-TemplateMsappPath \"%~1\""
)

REM Add output name if provided
if not "%~2"=="" (
    set "PS_ARGS=!PS_ARGS! -OutputName \"%~2\""
)

REM Build full command
set "PS_CMD=powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_DIR%repack.ps1\" !PS_ARGS!"

echo Calling PowerShell script...
if defined PS_ARGS (
    echo   Arguments: !PS_ARGS!
)
echo.

REM Execute PowerShell script
%PS_CMD%

REM Capture exit code
set "EXIT_CODE=%ERRORLEVEL%"

if %EXIT_CODE% neq 0 (
    echo.
    echo ===================================================================
    echo [FAIL] Repack failed with exit code: %EXIT_CODE%
    echo ===================================================================
    echo.
    echo See output above for details.
    echo For troubleshooting, see TROUBLESHOOTING_REPACK.md
    echo.
    pause
    exit /b %EXIT_CODE%
)

echo.
pause
exit /b 0
