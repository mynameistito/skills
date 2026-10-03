---
name: powershell
description: Write, review, debug, and test PowerShell scripts and commands, including pipelines, functions, errors, paths, native-command boundaries, security, and cross-platform pwsh behavior. Also use for here-strings, multiline text, Bash heredoc conversions, and quoting or interpolation issues.
license: MIT
compatibility: PowerShell 5.1+; examples prefer modern pwsh where behavior differs.
metadata:
  author: mynameistito
  version: "1.1.0"
---

# PowerShell scripts that behave predictably

Use this skill to write PowerShell that is readable, predictable, and safe to run. It covers everyday scripts and commands as well as here-strings. PowerShell calls these **here-strings**, not heredocs; they are multiline string literals delimited by `@' ... '@` (literal) or `@" ... "@` (expandable).

Use this skill for PowerShell scripts, shell commands, automation, debugging, and review. Give the here-string guidance particular attention whenever multiline content crosses a PowerShell boundary: scripts, generated files, Markdown bodies, JSON/YAML, CLI bodies, native-command stdin, CI `run:` blocks, or Bash-to-PowerShell conversions.

## Workflow

1. **Establish the boundary.** Identify the PowerShell edition and version, operating system, execution context (interactive, `.ps1`, CI, or embedded command), and any downstream shell or native program. If a missing detail changes correctness, ask; otherwise state a safe assumption.
2. **Choose the simplest PowerShell construct.** Prefer built-in cmdlets and objects, explicit functions for reusable behavior, and direct file or stdin interfaces over nested command strings.
3. **Make behavior explicit.** Handle inputs, paths, errors, side effects, and native exit codes at the boundary where they occur. Use here-string rules below whenever multiline text is involved.
4. **Verify without unnecessary side effects.** Parse modified scripts before execution; run focused tests or a safe sample when available. Clearly separate validation from commands that change files, systems, or remote resources.

Done means the requested behavior is implemented, important failure paths are handled, and the relevant syntax or focused verification has passed (or any blocker is reported).

## Everyday PowerShell

### Objects and pipelines

PowerShell pipelines pass objects, not merely lines of text. Keep data structured through cmdlets and property access; format only at the presentation boundary.

~~~powershell
$services = Get-Service |
    Where-Object Status -eq 'Running' |
    Sort-Object Name

$services | Select-Object Name, Status
~~~

Use `ForEach-Object` for pipeline streaming. Use `foreach` when working with an existing collection or when clearer control flow matters. Avoid parsing human-formatted table output when an object or structured format is available.

### Variables, types, and functions

- Use descriptive variable and parameter names; initialize values before branching when that makes state clear.
- Let PowerShell infer common types. Add type annotations where they document a function contract or prevent ambiguity; validate untrusted input rather than assuming a cast makes it valid.
- Give reusable functions approved verbs, explicit parameters, and a single responsibility. Emit results as pipeline output; reserve `Write-Host` for deliberate interactive display.
- Use `$()` to embed an expression in an expandable string, and `${name}` when a variable's name boundary is ambiguous. Prefer formatting or interpolation over repeated string concatenation.

~~~powershell
function Get-ConfigValue {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    Get-Content -LiteralPath $Path -Raw
}
~~~

### Errors and native commands

PowerShell cmdlets can report non-terminating errors. Use `-ErrorAction Stop` at boundaries where a failure must enter `catch`, and keep `try`/`catch` close to the operation whose failure you can handle. In `catch`, preserve useful context and rethrow when recovery is not possible.

~~~powershell
try {
    $content = Get-Content -LiteralPath $path -Raw -ErrorAction Stop
} catch {
    throw "Could not read '$path': $($_.Exception.Message)"
}
~~~

Native executables have separate argument, stream, and exit-code behavior. Pass arguments as distinct values rather than constructing a command string, but also follow the target program's option rules: an argument array does not guarantee safety from the target interpreting a value as an option or from its own command-line parser. Validate or constrain untrusted values, use the target's end-of-options marker when supported, and test on every supported runtime. On Windows, batch files are a special boundary; avoid sending them untrusted input as raw command-line text.

PowerShell 7.3 introduced `$PSNativeCommandArgumentPassing` with `Legacy`, `Standard`, and `Windows` modes; defaults vary by platform and `Windows` mode preserves legacy behavior for selected executables and script extensions. Windows PowerShell 5.1 uses legacy behavior. Capture/check `$LASTEXITCODE` immediately after a native command and interpret it using that program's documented contract; nonzero does not automatically mean failure for every tool, and native stderr alone does not establish failure. A nonzero exit does not normally enter `catch`; `$PSNativeCommandUseErrorActionPreference` became stable in PowerShell 7.4 and changes that behavior when enabled.

For byte-exact native input/output, account for version boundaries: PowerShell 7.4 made native byte-stream preservation mainstream for native stdout redirection to a file and byte data piped to native stdin. Older versions may convert native output through text. Prefer a program's explicit file/binary interface when available, or verify the exact behavior on the target runtime.

### Paths, files, and side effects

- Prefer `-LiteralPath` for user-provided paths so wildcard characters are treated literally.
- Use `Join-Path` to compose paths and `Test-Path` when existence affects the next action; avoid assuming the current working directory.
- Choose text encoding explicitly when reading or writing files, especially when compatibility with Windows PowerShell 5.1 matters.
- Make destructive or remote effects visible, scoped, and confirmable. Reusable state-changing functions should declare `[CmdletBinding(SupportsShouldProcess)]` and run each effect only when `$PSCmdlet.ShouldProcess(...)` returns `$true`; adding the attribute alone does not protect the operation.
- Avoid `Invoke-Expression`; call commands directly with explicit arguments instead.

~~~powershell
function Remove-ExampleFile {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string] $Path)

    if ($PSCmdlet.ShouldProcess($Path, 'Remove file')) {
        Remove-Item -LiteralPath $Path -ErrorAction Stop
    }
}
~~~

### Cross-platform and version boundaries

Do not assume Windows PowerShell 5.1 and modern PowerShell (`pwsh`) behave identically. Check the target runtime when relying on newer syntax, native argument passing, default encodings, or platform-specific cmdlets. Prefer `$env:NAME` for environment variables and built-in path cmdlets over hard-coded separators. State Windows-only requirements when the task is not portable.

### Security and trust

Treat external input as data: validate it before using it in paths, queries, or command arguments, and pass arguments directly instead of composing executable command strings. Keep credentials out of source files, logs, and transcripts; use the host's secret store or CI secret mechanism. Review downloaded scripts and modules before running them. Execution policy helps prevent accidental execution but is not a security boundary.

### Verification

For a changed `.ps1` file, parse it before running it; parsing checks syntax without triggering the script's side effects. Then run the narrowest relevant test or a safe representative input. Reuse the repository's existing test framework (such as Pester when configured) rather than adding a dependency for a one-off check. Report what was parsed or tested and distinguish that from untested platform-specific behavior.

Keep function success output intentional: PowerShell sends uncaptured expressions and command results to the success stream, so incidental output can break callers that expect a specific object or shape. Assign or suppress incidental results and send diagnostics to an appropriate stream.

## Here-strings

The rest of this section is the detailed reference for multiline string syntax, payload boundaries, and parser diagnostics.

### Default decision

Use the representation with the fewest parsing layers:

1. Prefer an agent-native file write/edit tool when the goal is to create or modify a file.
2. Prefer a CLI file/stdin option such as `--body-file`, `--input`, or stdin when supported.
3. Use a single-quoted here-string for literal multiline text.
4. Use a double-quoted here-string only when PowerShell expansion is intentionally required.

Do not reach for a here-string merely because the input is multiline.

### Non-negotiable syntax rules

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

### Literal vs expandable

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

### Structured data: serialize it

Do not hand-build JSON with an expandable here-string when the content represents data.

~~~powershell
$payload = [ordered]@{
    version = $version
    commit  = $commitSha
    enabled = $true
} | ConvertTo-Json -Depth 10
~~~

Use a literal here-string only for an exact fixture/example that must remain textual.

### Markdown and CLI bodies: prefer files

If a CLI supports an input/body file, use it. For GitHub CLI:

~~~powershell
gh pr create --repo owner/repo --title "feat: example" --body-file $bodyPath
gh issue create --repo owner/repo --title "bug: example" --body-file $bodyPath
gh pr comment 123 --repo owner/repo --body-file $bodyPath
~~~

Create `$bodyPath` with the environment's file-writing tool where possible. If PowerShell itself must create the file, hold the content in a literal here-string and write it once.

Do not place a large Markdown body directly inside an inline `--body "..."` argument when it contains multiple lines, backticks, `$`, or nested quotes.

### Bash heredoc conversion

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

Encoding labels can differ by runtime: `utf8` writes a BOM in Windows PowerShell 5.1 but no BOM in PowerShell 6+. If exact bytes or cross-version interoperability matter, select and verify the required encoding explicitly; `utf8NoBOM` and `utf8BOM` are available in PowerShell 7.1+.

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

### CI and nested parser layers

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

### Delimiter collisions

A payload can contain text that looks like its closing delimiter.

Before choosing a here-string:

1. Search for a line that can become `'@` or `"@`.
2. Use the other quote style only if its interpolation semantics are also safe.
3. Otherwise use a file-writing API, serializer, or another representation.

Do not randomly escape the payload if the consumer needs exact text.

### Native commands

A here-string only creates a PowerShell string. It does not solve native-command argument parsing.

Prefer:

1. the native command's file/input option;
2. stdin when accepted;
3. distinct PowerShell argument values, after checking the target program's parsing and option conventions;
4. the Windows stop-parsing token `--%` only for narrow cases where PowerShell parsing itself is the problem.

Do not use `--%` as a general multiline-string solution.

### Common failure patterns

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

### Parse before executing

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

### Review checklist

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

## References

Use the local notes when a task touches the corresponding behavior. They summarize the relevant rules and link to Microsoft's versioned documentation; check the upstream page for the target runtime when behavior is version-sensitive.

- [Quoting and parser boundaries](references/quoting-and-parser-boundaries.md) for here-strings, interpolation, special characters, and native argument parsing.
- [Pipelines, errors, and native exit codes](references/pipelines-errors-and-exit-codes.md) for object pipelines, native byte streams, PowerShell errors, and exit codes.
- [Files, encoding, and side effects](references/files-encoding-and-side-effects.md) for encoding defaults and `SupportsShouldProcess`.
- [Security features](references/security-features.md) for execution policy and other PowerShell security features.

Do not infer Bash semantics from syntax that merely looks similar.
