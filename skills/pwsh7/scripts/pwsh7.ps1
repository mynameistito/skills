#Requires -Version 3.0
<#
.SYNOPSIS
  Shim to launch Store-installed PowerShell 7 (Microsoft.PowerShell) from Windows PowerShell 5.1.
.DESCRIPTION
  Resolves pwsh.exe in order:
    1. pwsh.exe already on PATH (App Execution Alias or MSI install)
    2. Newest Get-AppxPackage -Name Microsoft.PowerShell -> <InstallLocation>\pwsh.exe
    3. Well-known MSI / per-user locations
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

function Find-StorePwsh {
    # Newest version wins if side-by-side Appx installs exist.
    $pkg = Get-AppxPackage -Name Microsoft.PowerShell -ErrorAction SilentlyContinue |
        Sort-Object -Property Version -Descending |
        Select-Object -First 1
    if ($null -ne $pkg -and $pkg.InstallLocation) {
        $candidate = Join-Path $pkg.InstallLocation 'pwsh.exe'
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }
    return $null
}

function Find-Pwsh {
    # 1. Anything already resolvable (App Execution Alias, MSI on PATH, scoop, etc.)
    $cmd = Get-Command pwsh.exe -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -ne $cmd -and $cmd.Source -and (Test-Path -LiteralPath $cmd.Source)) {
        return $cmd.Source
    }

    # 2. Store Appx, bypassing PATH.
    $store = Find-StorePwsh
    if ($store) { return $store }

    # 3. Well-known MSI / per-user spots (covers machine without Store alias).
    $candidates = @(
        (Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'PowerShell\7\pwsh.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\PowerShell\7\pwsh.exe')
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path -LiteralPath $c)) {
            return $c
        }
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
