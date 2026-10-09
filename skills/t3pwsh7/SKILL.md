---
name: t3pwsh7
description: Recover T3 Code from running under Windows PowerShell 5.1 by launching the installed modern PowerShell runtime. Use when T3 Code is running under powershell.exe or `$PSVersionTable.PSVersion` reports a version below 7 and the user needs T3 Code to use `pwsh`.
license: MIT
compatibility: Windows with the Microsoft.PowerShell Appx package installed; recovery launches a new PowerShell process.
metadata:
  author: mynameistito
  version: "1.0.0"
---

# Run T3 Code with modern PowerShell

Use this skill specifically to recover T3 Code from a Windows PowerShell host version mismatch. The Appx-based launch path is Windows-specific.

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
