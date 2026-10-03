# Pipelines, errors, and native exit codes

## Pipelines

- PowerShell cmdlet pipelines pass objects. Parameters can accept pipeline input by value or by property name; use `Get-Help` and `Get-Member` to inspect the contract.
- A native process's stdin/stdout is a separate boundary from the PowerShell object pipeline. PowerShell 7.4 added byte-preserving behavior for native stdout redirection to files and byte data piped to native stdin; verify exact behavior on older runtimes and when combining stderr with stdout.

## Errors and exit codes

- Non-terminating errors do not enter `catch` by default. Use `-ErrorAction Stop` when a cmdlet failure must be handled there.
- Native process status is reported through `$LASTEXITCODE`; capture or check it immediately after the relevant command and interpret it according to that program's contract. A nonzero code does not always mean failure, and stderr output alone does not establish failure.
- A native nonzero exit does not normally enter `catch`. `$PSNativeCommandUseErrorActionPreference` became stable in PowerShell 7.4 and can change this behavior when enabled.

## Sources

- [about_Pipelines](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_pipelines)
- [about_Error_Handling](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_error_handling)
