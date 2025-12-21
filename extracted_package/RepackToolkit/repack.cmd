@echo off
REM ============================================================================
REM CrossDiv Project DB - Canvas App Repack Script (CMD Wrapper)
REM ============================================================================
REM This wrapper runs the PowerShell repack script.
REM
REM Prerequisites:
REM   1. PowerShell 5.1+ (included with Windows 10/11)
REM   2. Power Platform CLI installed
REM
REM Usage: Double-click this file or run from command prompt
REM ============================================================================

echo.
echo Starting Canvas App Repack...
echo.

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Run the PowerShell script
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%repack.ps1"

REM Check exit code
if %ERRORLEVEL% neq 0 (
    echo.
    echo Script completed with errors. See above for details.
    echo.
    pause
    exit /b %ERRORLEVEL%
)

echo.
pause
