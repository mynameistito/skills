---
name: index-knowledge
description: Generate or refresh a hierarchical AGENTS.md knowledge base for a codebase. Use when a user asks to index, map, document, or orient an unfamiliar repository, onboard agents to it, regenerate its AGENTS.md files, or limit the indexing depth. Also use when existing agent instructions need a structure-aware, non-destructive refresh.
license: MIT
metadata:
  author: mynameistito, dmmulroy
  version: "1.1.0"
---

# index-knowledge

Generate a useful hierarchy of concise `AGENTS.md` files: one root map and child maps only where complexity or domain boundaries justify them. The output is repository-specific orientation, not generic coding advice.

## Invocation And Modes

This is a model-invoked skill. Reach it for repository indexing, mapping, onboarding, knowledge-base generation, or an explicit AGENTS refresh. A user may also invoke it by name.

Parse these optional arguments before discovery:

```text
--create-new   Read existing context, then regenerate generated knowledge from scratch.
--max-depth=N  Do not score or create docs below depth N. Default: 5.
```

Default to update mode. If the request is ambiguous about the target, ask for the repository path before changing files. Display relative paths in generated documents, but use absolute paths for tool calls.

## Operating Rules

- Use agent-native `glob`, `grep`, and `read` tools first. Use an available safe `rg` process only as an optimization; keep the native fallback.
- Treat paths as opaque values and use the host runtime's path handling. Do not require a shell or assume `/`, `\`, `bash`, `sh`, `cmd`, or PowerShell.
- Exclude `.git`, dependencies, vendored code, caches, virtual environments, generated output, and build artifacts from analysis unless the user explicitly includes them. Common examples: `node_modules`, `dist`, `build`, `out`, `coverage`, `target`, `vendor`, `bin`, `obj`, `.next`, `.nuxt`, `.turbo`, `.cache`, `__pycache__`, `.pytest_cache`, `.venv`, `venv`, `.gradle`.
- Read every existing `AGENTS.md` and `CLAUDE.md` found before deciding what to write. Preserve specific, hand-authored guidance and report conflicts rather than silently replacing it.
- Prefer repository-declared commands and conventions over remembered defaults. Mark an inferred command as inferred or omit it.
- Keep root and child documents under 150 physical lines. A small repository may produce a shorter root document; never pad it to meet a minimum.

## Workflow

Track these phases in TodoWrite when available; otherwise keep this checklist in working notes and report its final state:

```text
discovery -> scoring -> generation -> review -> bridges -> report
```

### 1. Discover

Establish the target root and mode. Then inspect the root listing and, using discovered directories rather than assumed names, build a bounded tree up to `max-depth`.

Run independent reads/searches in parallel when the host supports it:

- Existing `AGENTS.md` and `CLAUDE.md` files.
- Repository manifests and configuration: package/build files, workspace definitions, formatter/linter/test config, CI, editor settings, and language toolchain files.
- Source files by detected extension, with counts by directory.
- Entry points, tests, public interfaces, module boundaries, and cross-cutting utilities.
- Project-specific warnings and constraints such as `DO NOT`, `NEVER`, `DEPRECATED`, or documented gotchas.

Use explore subagents in one parallel dispatch when available. Give each a narrow question and require evidence paths in its result. Useful questions are structure, entry points, conventions, tests, CI/build, and anti-patterns. Add focused exploration only when evidence shows a real branch: a monorepo package, a deep module, a second language, or a large hotspot. Do not spawn agents solely to satisfy a fixed count.

Use LSP symbols/references when available for entry points and central exports. If LSP is unavailable, use content search or AST tools. A code map is optional for repositories too small to benefit from one.

**Discovery is complete when** the target, mode, depth limit, exclusions, existing instruction files, project commands, major domains, and evidence for each likely hotspot are recorded. Do not begin scoring from a root listing alone.

### 2. Score And Choose Locations

Score only analyzed, non-excluded directories. Use the matrix as a consistent heuristic, not as a claim of mathematical precision:

| Factor | Weight | Strong signal |
|---|---:|---|
| Source file count | 3 | More than 20 |
| Child directory count | 2 | More than 5 |
| Code concentration | 2 | More than 70% source |
| Local configuration or distinct patterns | 1 | Own config or conventions |
| Module boundary | 2 | Package entry point, `index`, `__init__`, or equivalent |
| Symbol density | 2 | More than 30 meaningful symbols |
| Export surface | 2 | More than 10 exports |
| Reference centrality | 3 | More than 20 meaningful references |

Apply these decisions:

- Always create or maintain the root `AGENTS.md`.
- Score above 15: create a child document when the findings are concrete.
- Score 8-15: create one only when it is a distinct domain or has local conventions an agent must know.
- Below 8: let the nearest parent cover it.
- Never create both a parent and child merely because both exceed a threshold. Prefer the smallest set of documents that gives each domain one clear home.
- Respect `max-depth`; the root remains required even when the limit is zero.

Record each selected location, score, evidence, and reason before generation. This makes pruning and the final report auditable.

**Scoring is complete when** every analyzed directory has either a documented keep/skip decision, every selected child has a domain-specific reason, and no excluded or shallow directory was selected by noise alone.

### 3. Generate Root And Children

Generate the root first so child documents can link upward without repeating it. Generate independent child documents in parallel when supported.

#### Root `AGENTS.md`

Use only sections supported by findings. The usual order is:

```markdown
# PROJECT KNOWLEDGE BASE
**Generated:** {timestamp}
**Commit:** {short sha, if available}
**Branch:** {branch, if available}

## OVERVIEW
## STRUCTURE
## WHERE TO LOOK
## CODE MAP
## CONVENTIONS
## ANTI-PATTERNS (THIS PROJECT)
## COMMANDS
## NOTES
```

Include the stack and purpose, non-obvious directory roles, task-to-location routes, important symbols and their roles, project-specific deviations, explicit prohibitions, verified commands, and actionable gotchas. Omit empty sections and facts visible from filenames. `CODE MAP` may be omitted when the repository is too small or symbol evidence is unavailable.

#### Child `AGENTS.md`

Use a lean document with an opening scope statement, local structure when useful, `WHERE TO LOOK`, local conventions, anti-patterns, and links to parent context where appropriate. Include only information that is new at that boundary. A child must not restate the root overview, global commands, global conventions, or sibling domains.

#### Update And Create-New Safety

- Update mode merges with existing files. Preserve hand-authored sections and project-specific facts unless evidence proves them stale.
- Remove stale generated boilerplate and parent duplicates when they can be identified safely.
- In `--create-new`, read all existing files first, preserve useful hand-authored context, and regenerate the generated portions. Do not delete a clearly hand-authored file without explicit permission.
- If generated and hand-authored guidance conflicts, keep the hand-authored instruction and report the conflict.

**Generation is complete when** every selected location has a written or safely updated `AGENTS.md`, each file has a single clear scope, and no child duplicates parent material.

### 4. Review And Prune

Review the hierarchy as a set, not just file by file:

- Verify every claim and command against repository evidence.
- Remove generic advice, obvious file listings, stale boilerplate, and duplicated parent content.
- Check that every child earns its place through a distinct domain or local complexity.
- Check that commands are repository-declared, cross-platform, or explicitly labeled by OS.
- Check that excluded/generated directories did not influence locations or code maps.
- Check line counts and links, and ensure the root tells an agent where to start for common tasks.
- Keep one authoritative home for each fact. If a fact belongs to a child, point to it rather than copying it into the root.

Treat each line as a maintenance cost. Prefer a concrete route or constraint over a description of what the directory name already says. Delete a sentence that changes no agent behavior.

**Review is complete when** all generated files pass the size, scope, evidence, deduplication, command, exclusion, and usefulness checks, and the selected-location list matches the files actually present.

### 5. Maintain `CLAUDE.md` Bridges

For every directory with an `AGENTS.md`, maintain a companion `CLAUDE.md` containing exactly:

```markdown
This project uses AGENTS.md files for AI context. Read AGENTS.md in this directory for relevant instructions and knowledge.
```

Read an existing bridge first. Overwrite only an empty file or one that exactly matches this template. Leave any other content untouched and report that it was skipped. After generation, find bridge files with the exact template whose directory is no longer selected and remove those orphaned bridges; never remove user-authored `CLAUDE.md` content.

**Bridge maintenance is complete when** every selected location has a safe bridge, every stale generated bridge has been removed, and every non-template bridge is preserved.

## Output Contract

Report the result in a compact form:

```text
=== index-knowledge Complete ===
Mode: {update | create-new}
Root: ./AGENTS.md ({N} lines)
Children: {created/updated/skipped count}
Bridges: {created/updated/skipped/removed count}
Dirs analyzed: {N}
Hierarchy:
  ./AGENTS.md
  └── ./path/to/domain/AGENTS.md
Notes: {conflicts, inferred commands, unavailable tools, or none}
```

List every changed path and its action when the result is more than the root. State explicitly when LSP, subagents, or a requested depth could not be used.

## Quality Bar

- The root is a useful first stop within seconds, not a dump of the repository.
- Each child answers questions specific to its domain and adds no parent duplicate.
- Every non-obvious instruction has a repository evidence path or is clearly labeled as an inference.
- Generated files remain concise, factual, and easy to update.
- Existing user-authored instructions and bridges survive unless the user explicitly authorizes replacement.
