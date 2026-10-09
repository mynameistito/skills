#Requires -Version 3.0
<#
.SYNOPSIS
  Shim to launch Store-installed PowerShell 7 (Microsoft.PowerShell) from Windows PowerShell 5.1.
.DESCRIPTION
  Resolves the newest suitable pwsh.exe (minimum 7.6) in order:
    1. pwsh.exe already on PATH (App Execution Alias or MSI install)
    2. Newest Get-AppxPackage -Name Microsoft.PowerShell -> <InstallLocation>\pwsh.exe
    3. Well-known MSI / per-user locations
  Falls back to the newest available runtime with a stderr warning when none meets 7.6.
  Forwards all arguments untouched and preserves the child exit code.
  Declares no parameters: with no param block, every token lands in $args
  verbatim — including names like -Verbose that the binder would otherwise
  consume as a common parameter instead of forwarding.
  Works in Windows PowerShell 5.1 and PowerShell 7+.
.EXAMPLE
  pwsh7.ps1 -NoProfile -Command '$PSVersionTable.PSVersion'
.EXAMPLE
  pwsh7.ps1 -File .\script.ps1 -Arg 'with spaces'
#>
# No param block by design: with no declared parameters, every token lands in
# $args verbatim — including names like -Verbose that the binder would
# otherwise consume as a common parameter instead of forwarding.

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$MinimumVersion = [version]'7.6'

function Get-PwshVersion {
    param([string]$Path)
    try {
        $out = & $Path -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null |
            Select-Object -First 1
        if ($out) { return [version]$out }
    } catch { }
    return $null
}

function Find-Pwsh {
    # Candidates in priority order. Each is version-checked: the first
    # meeting $MinimumVersion wins; otherwise the newest probed runtime is
    # returned as a last resort (the skill verifies the host in its step 3).
    $candidates = @()

    # 1. Anything already resolvable (App Execution Alias, MSI on PATH, scoop, etc.)
    $cmd = Get-Command pwsh.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -ne $cmd -and $cmd.Source -and (Test-Path -LiteralPath $cmd.Source)) {
        $candidates += $cmd.Source
    }

    # 2. Store Appx, bypassing PATH (newest install wins).
    $pkg = Get-AppxPackage -Name Microsoft.PowerShell -ErrorAction SilentlyContinue |
        Sort-Object -Property Version -Descending |
        Select-Object -First 1
    if ($null -ne $pkg -and $pkg.InstallLocation) {
        $candidates += Join-Path $pkg.InstallLocation 'pwsh.exe'
    }

    # 3. Well-known MSI / per-user spots (covers machines without the Store alias).
    $candidates += Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
    $candidates += Join-Path ${env:ProgramFiles(x86)} 'PowerShell\7\pwsh.exe'
    $candidates += Join-Path $env:LOCALAPPDATA 'Microsoft\PowerShell\7\pwsh.exe'

    $fallback = $null
    $fallbackVersion = $null
    foreach ($c in $candidates) {
        if (-not $c -or -not (Test-Path -LiteralPath $c)) { continue }
        $v = Get-PwshVersion $c
        if ($null -ne $v -and $v -ge $MinimumVersion) { return $c }
        if ($null -ne $v -and ($null -eq $fallbackVersion -or $v -gt $fallbackVersion)) {
            $fallback = $c
            $fallbackVersion = $v
        }
    }

    if ($fallback) {
        [Console]::Error.WriteLine("pwsh7: warning: no PowerShell >= $MinimumVersion found; using $fallback ($fallbackVersion).")
        return $fallback
    }

    return $null
}

$pwsh = Find-Pwsh
if (-not $pwsh) {
    [Console]::Error.WriteLine('pwsh7: Microsoft.PowerShell is not installed for this user (no pwsh.exe on PATH, no Appx package, no MSI fallback).')
    exit 1
}

# Splatting @args preserves arguments containing spaces ($args is always an
# array, never $null, so no coercion is needed).
& $pwsh @args
exit $LASTEXITCODE
