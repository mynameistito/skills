@echo off
REM Thin wrapper so bare `pwsh7` resolves from cmd.exe and PowerShell 5.1 via PATH/PATHEXT.
REM Logic lives in pwsh7.ps1 next to this file. Exit code is forwarded.
REM NOTE: arguments pass through raw cmd.exe parsing here (%*), so a value
REM containing quotes plus a command separator could be reinterpreted as
REM syntax. Feed this wrapper trusted input only; invoke pwsh7.ps1 directly
REM for anything untrusted.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0pwsh7.ps1" %*
exit /b %ERRORLEVEL%
