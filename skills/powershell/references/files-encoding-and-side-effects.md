# Files, encoding, and side effects

## Encoding

- Windows PowerShell 5.1 and PowerShell 6+ have different defaults. Windows PowerShell cmdlets use several inconsistent defaults; PowerShell 6+ commonly writes UTF-8 without a BOM.
- Defaults can vary by cmdlet, operation, append behavior, and BOM detection. Specify an encoding when interoperability matters instead of assuming one default applies everywhere.

## Side effects

- `[CmdletBinding(SupportsShouldProcess)]` adds `-WhatIf` and `-Confirm` support to a function, but does not guard effects by itself.
- Run each protected state-changing operation only when `$PSCmdlet.ShouldProcess(...)` returns `$true`.

## Sources

- [about_Character_Encoding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- [about_Functions_CmdletBindingAttribute](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute)
