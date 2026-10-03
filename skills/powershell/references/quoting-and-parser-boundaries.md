# Quoting and parser boundaries

## Quoting and here-strings

- Single-quoted strings are literal; double-quoted strings expand variables, subexpressions, and PowerShell escape sequences.
- Use `${name}` when the end of a variable name is ambiguous in an expandable string.
- A here-string opener (`@'` or `@"`) must be followed by a newline. Its matching closing marker must be alone on a line. This skill recommends a column-one closer for broad parser compatibility; verify indentation behavior against the target PowerShell version.
- Single-quoted here-strings preserve `$`, `$()`, and backticks. Double-quoted here-strings expand them.

## Parsing and special characters

- PowerShell parses expressions and command arguments differently. Prefer direct invocation with distinct argument values over constructing a command string, and validate untrusted values for the target program's option syntax.
- PowerShell 7.3 introduced `$PSNativeCommandArgumentPassing` modes (`Legacy`, `Standard`, and `Windows`). Defaults and compatibility behavior vary by platform and executable; Windows PowerShell 5.1 uses legacy behavior.
- The backtick introduces PowerShell escape sequences in expandable strings. The `--` token only stops parameter parsing for PowerShell commands; native invocations receive it as an argument. The Windows-only `--%` token stops parsing at a native-command boundary and is not a general quoting fix.
- Each embedding layer (such as YAML, JSON, or another shell) can transform the script before PowerShell parses it. Validate the final PowerShell text, not just its outer representation.

## Sources

- [about_Quoting_Rules](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_quoting_rules)
- [about_Parsing](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parsing)
- [about_Special_Characters](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_special_characters)
