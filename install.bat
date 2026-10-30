@echo off
setlocal
echo ==========================================================
echo Installing Android ROM Skills Suite for Antigravity IDE...
echo ==========================================================

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Installation finished successfully.
) else (
    echo.
    echo Installation encountered an error (code: %ERRORLEVEL%).
)
pause
