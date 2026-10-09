@echo off
REM Thin wrapper so bare `pwsh7` resolves from cmd.exe and PowerShell 5.1 via PATH/PATHEXT.
REM Logic lives in pwsh7.ps1 next to this file. Exit code is forwarded.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0pwsh7.ps1" %*
