---
name: powershell-here-strings
description: Write, review, convert, and debug PowerShell here-strings and multiline text safely. Use for @'...'@ / @"..."@ syntax, Bash heredoc conversions, parser errors involving string terminators, Markdown/JSON/YAML/code payloads, or preventing accidental interpolation in pwsh.
license: MIT
compatibility: PowerShell 5.1+; examples prefer modern pwsh where behavior differs.
metadata:
  author: mynameistito
  version: "1.0.0"
---

# PowerShell here-strings without parser traps

PowerShell calls these **here-strings**, not heredocs. They are multiline string literals delimited by `@' ... '@` (literal) or `@" ... "@` (expandable).

Use this skill whenever multiline content crosses a PowerShell boundary: scripts, generated files, Markdown bodies, JSON/YAML, GitHub CLI bodies, native-command stdin, CI `run:` blocks, or Bash-to-PowerShell conversions.

## Default decision

Use the representation with the fewest parsing layers:

1. Prefer an agent-native file write/edit tool when the goal is to create or modify a file.
2. Prefer a CLI file/stdin option such as `--body-file`, `--input`, or stdin when supported.
3. Use a single-quoted here-string for literal multiline text.
4. Use a double-quoted here-string only when PowerShell expansion is intentionally required.

Do not reach for a here-string merely because the input is multiline.

## Non-negotiable syntax rules

A here-string opener is `@'` or `@"`. The opener must be followed by a newline. Do not place payload text after the opener.

Correct:

~~~powershell
$text = @'
literal content
'@
~~~

~~~powershell
$text = @"
expanded content
"@
~~~

Wrong:

~~~powershell
$text = @'literal content
'@
~~~

Use the matching closer: `'@` for `@'`, and `"@` for `@"`.

For maximum parser reliability, put the closing marker on its own physical line with no indentation and no trailing characters:

~~~powershell
if ($enabled) {
    $text = @'
This line is content.
'@
}
~~~

Do not indent the closing marker merely to match the surrounding block. Payload indentation is data; leading spaces inside the body are preserved.

## Literal vs expandable

### Prefer single-quoted here-strings for payloads

`@' ... '@` is verbatim. PowerShell does not expand variables or subexpressions inside it.

~~~powershell
$body = @'
# Release notes

$schema stays literal.
$(Get-Date) stays literal.
"Quotes" and 'quotes' do not need escaping.
Markdown `code` stays literal.
'@
~~~

Default to this form for Markdown, JSON fixtures, YAML, source code, shell snippets, regular expressions, and text containing `$`, `$()`, or backticks.

### Use double-quoted here-strings only for intentional expansion

`@" ... "@` is expandable. Variables, subexpressions, and PowerShell escape sequences are interpreted.

~~~powershell
$body = @"
Release: $version
Commit: $($commit.Sha)
Generated: $(Get-Date -Format o)
"@
~~~

Before using an expandable here-string, inspect the payload for literal `$`, `$()`, and backticks. JSON containing `$schema`, Markdown showing `$env:PATH`, or embedded source code can be silently changed.

If only a few values must be inserted into mostly literal text, prefer a literal template plus explicit replacement:

~~~powershell
$template = @'
Release: __VERSION__
Commit: __COMMIT__
'@

$body = $template.
    Replace('__VERSION__', $version).
    Replace('__COMMIT__', $commitSha)
~~~

## Structured data: serialize it

Do not hand-build JSON with an expandable here-string when the content represents data.

~~~powershell
$payload = [ordered]@{
    version = $version
    commit  = $commitSha
    enabled = $true
} | ConvertTo-Json -Depth 10
~~~

Use a literal here-string only for an exact fixture/example that must remain textual.

## Markdown and CLI bodies: prefer files

If a CLI supports an input/body file, use it. For GitHub CLI:

~~~powershell
gh pr create --repo owner/repo --title "feat: example" --body-file $bodyPath
gh issue create --repo owner/repo --title "bug: example" --body-file $bodyPath
gh pr comment 123 --repo owner/repo --body-file $bodyPath
~~~

Create `$bodyPath` with the environment's file-writing tool where possible. If PowerShell itself must create the file, hold the content in a literal here-string and write it once.

Do not place a large Markdown body directly inside an inline `--body "..."` argument when it contains multiple lines, backticks, `$`, or nested quotes.

## Bash heredoc conversion

Do not paste Bash heredoc syntax into PowerShell.

Bash literal heredoc:

~~~sh
cat <<'EOF' > body.md
$HOME stays literal
EOF
~~~

PowerShell equivalent:

~~~powershell
$body = @'
$HOME stays literal
'@

Set-Content -LiteralPath 'body.md' -Value $body -Encoding utf8
~~~

Bash expandable heredoc:

~~~sh
cat <<EOF
Hello $USER
EOF
~~~

PowerShell equivalent when expansion is intentional:

~~~powershell
$body = @"
Hello $env:USERNAME
"@
~~~

Do not mechanically translate `$VAR`. Verify whether the PowerShell value is `$name`, `$env:NAME`, or an expression.

## CI and nested parser layers

When PowerShell is embedded in YAML, JSON, another shell, or a command string, reason about every parser layer.

For GitHub Actions:

~~~yaml
- name: Example
  shell: pwsh
  run: |
    $body = @'
    literal content
    '@
    Write-Output $body
~~~

YAML removes the block's common indentation before PowerShell receives the script. Judge the here-string based on the resulting PowerShell source, not only the visual indentation in YAML.

Avoid nesting a here-string inside `pwsh -Command "..."` when a `.ps1` file or direct script execution is available. Each extra command-string layer adds another round of quote and `$` interpretation.

Never use `Invoke-Expression` merely to compensate for quoting problems.

## Delimiter collisions

A payload can contain text that looks like its closing delimiter.

Before choosing a here-string:

1. Search for a line that can become `'@` or `"@`.
2. Use the other quote style only if its interpolation semantics are also safe.
3. Otherwise use a file-writing API, serializer, or another representation.

Do not randomly escape the payload if the consumer needs exact text.

## Native commands

A here-string only creates a PowerShell string. It does not solve native-command argument parsing.

Prefer:

1. the native command's file/input option;
2. stdin when accepted;
3. a normal PowerShell argument array;
4. the Windows stop-parsing token `--%` only for narrow cases where PowerShell parsing itself is the problem.

Do not use `--%` as a general multiline-string solution.

## Common failure patterns

### "The string is missing the terminator"

Check, in order:

1. opener and closer quote types match;
2. the opener is followed by a real newline;
3. the closer is isolated on its own physical line;
4. the closer was not indented in the script PowerShell actually receives;
5. an earlier quote/backtick did not change parsing;
6. YAML/shell/template processing did not transform the delimiter.

### Literal text was unexpectedly changed

You probably used `@" ... "@` for content that should have been literal. Switch to `@' ... '@`, or move substitutions outside the payload.

### `$schema`, `$env:*`, or `$(...)` disappeared or executed

The payload was expandable. Use a single-quoted here-string or a structured serializer.

### `<<EOF` fails in pwsh

That is Bash heredoc syntax, not PowerShell here-string syntax. Convert it instead of trying to escape it.

### It works interactively but fails in CI

Inspect the exact script after YAML/template interpolation. CI adds another parser layer and may change environment or line-ending behavior.

## Parse before executing

For generated or modified `.ps1` files, validate syntax without executing the script:

~~~powershell
$tokens = $null
$errors = $null

[System.Management.Automation.Language.Parser]::ParseFile(
    $path,
    [ref]$tokens,
    [ref]$errors
) | Out-Null

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_.Message }
    throw "PowerShell parse failed."
}
~~~

For an in-memory snippet, use `Parser.ParseInput(...)`.

## Review checklist

Before returning or committing PowerShell containing a here-string, verify:

- correct `@'` / `'@` or `@"` / `"@` pairing;
- newline immediately after the opener;
- closing marker isolated on its own line;
- no accidental closer indentation in the script PowerShell receives;
- literal vs expandable semantics are intentional;
- `$`, `$()`, and backticks inside expandable payloads were reviewed;
- a file/stdin option was considered first;
- JSON is serialized when it represents data;
- no unnecessary `Invoke-Expression`;
- nested YAML/shell/CLI parsing layers were accounted for;
- generated `.ps1` syntax was parsed before execution when practical.

## Anti-patterns

- Bash `<<EOF` / `<<'EOF'` syntax in `pwsh`.
- Double-quoted here-strings for arbitrary Markdown, JSON, YAML, or code.
- Indenting the closing marker for aesthetics.
- Escaping every quote inside a here-string even though quote characters are literal content.
- Building JSON manually when `ConvertTo-Json` can represent the data.
- Passing large multiline bodies as one inline CLI argument when a file option exists.
- Nesting here-strings through multiple command-string layers.
- Using `Invoke-Expression` to compensate for quoting mistakes.
- Repeatedly changing escapes without identifying which parser layer owns the error.

## Source of truth

When behavior is uncertain, prefer Microsoft's PowerShell documentation:

- `about_Quoting_Rules` for here-string and interpolation semantics.
- `about_Parsing` for argument parsing and native-command boundaries.
- `about_Special_Characters` for escaping and stop-parsing behavior.

Do not infer Bash semantics from syntax that merely looks similar.
