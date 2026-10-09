---
name: pwsh7
description: Recover from an outdated PowerShell host when a task or tool requires modern PowerShell. Use when an agent or app fails because it is running under powershell.exe, when `$PSVersionTable.PSVersion` reports a version below 7.6, or when the user asks to switch the current workflow to `pwsh`.
license: MIT
compatibility: Windows with the Microsoft.PowerShell Appx package installed; recovery launches a new PowerShell process.
metadata:
  author: mynameistito
  version: "1.0.0"
---

# Recover to modern PowerShell

Use this skill to diagnose a PowerShell host version mismatch and continue work in PowerShell 7.6 or newer. The Appx-based launch path is Windows-specific.

## Workflow

1. **Check the active host.** Run:

   ```powershell
   $PSVersionTable.PSVersion
   ```

   Compare the result with the minimum version `7.6`. Continue in the current session only when `$PSVersionTable.PSVersion -ge [version]'7.6'`; otherwise launch the installed PowerShell package in step 2. A PowerShell 7.0–7.5 host does not meet the 7.6 requirement.

2. **Launch the installed PowerShell package when the active version is below 7.6.** Run the bundled shim. First resolve `<skill-dir>` to this skill's installed directory — global per-agent locations are listed in the repository README, and a project install lives under `./<agent-dir>/skills/pwsh7`. Then run:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File <skill-dir>/scripts/pwsh7.ps1 -NoProfile -Command '$PSVersionTable.PSVersion'
   ```

   Or for an interactive session with no arguments:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File <skill-dir>/scripts/pwsh7.ps1
   ```

   The shim picks the newest runtime at or above 7.6 from PATH, Appx, or MSI installations, forwards all arguments, and returns the child exit code.

   Equivalent legacy inline form (no argument forwarding, no exit-code preservation):

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

   Confirm `$PSVersionTable.PSVersion -ge [version]'7.6'`. If the new process is still below 7.6, the package was not found, or the executable failed to launch, report the blocker and ask the user to install or select PowerShell 7.6 or newer.

4. **Continue the task in the new session.** Re-run the needed commands there; do not claim the original host has changed.

**Complete when:** the active session is confirmed to be on the required PowerShell version and the user knows to continue in that new process, or the installation/launch blocker is clearly reported.
