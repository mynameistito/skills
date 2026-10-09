---
name: pwsh-runtime
description: Recover from Windows PowerShell 5.1 when a task or tool requires modern PowerShell. Use when T3 Code or another app fails because it is running under powershell.exe, when `$PSVersionTable.PSVersion` reports a version below 7, or when the user asks to switch the current workflow to `pwsh`.
license: MIT
compatibility: Windows with the Microsoft.PowerShell Appx package installed; recovery launches a new PowerShell process.
metadata:
  author: mynameistito
  version: "1.0.0"
---

# Recover to modern PowerShell

Use this skill to diagnose a PowerShell host version mismatch and continue work in PowerShell 7 or newer. The Appx-based launch path is Windows-specific.

## Workflow

1. **Check the active host.** Run:

   ```powershell
   $PSVersionTable.PSVersion
   ```

   If the major version is 7 or newer, report the version and continue in the current session.

2. **Launch the installed PowerShell package when the major version is below 7.** Run:

   ```powershell
   $package = Get-AppxPackage -Name Microsoft.PowerShell

   if ($package) {
       & (Join-Path $package.InstallLocation 'pwsh.exe')
   } else {
       Write-Error 'Microsoft.PowerShell is not installed for this user.'
   }
   ```

   This opens a new PowerShell process. It does not replace the current process or migrate its variables and command history.

3. **Check the new host.** In the newly opened PowerShell prompt, run:

   ```powershell
   $PSVersionTable.PSVersion
   ```

   Confirm the major version is 7 or newer. If the requirement is specifically PowerShell 7.6+, confirm the minor version is at least 6 when the major version is 7. If the package was not found, the executable failed to launch, or the version is still too old, report the blocker and ask the user to install or select the required PowerShell version.

4. **Continue the task in the new session.** Re-run the needed commands there; do not claim the original host has changed.

**Complete when:** the active session is confirmed to be on the required PowerShell version and the user knows to continue in that new process, or the installation/launch blocker is clearly reported.
