---
name: index-knowledge
description: Create or improve a codebase's AGENTS.md knowledge map. Use when asked to index, map, or document a repository for coding agents, or to add project-specific agent guidance during onboarding.
license: MIT
metadata:
  author: mynameistito, dmmulroy
  version: "1.1.0"
---

# index-knowledge

Create a concise root `AGENTS.md` and add nested `AGENTS.md` files only where a directory needs distinct, local guidance. Document verified project facts and non-obvious conventions; do not generate generic coding advice.

## Workflow

1. **Inspect the repository.** Establish its root, inspect the root listing and relevant config, and find existing `AGENTS.md` files. Follow any existing instructions that apply to the task. Use available file tools first; use other discovery tools only when available and useful. Respect the requested `--max-depth=N` (default: 5).
   - Exclude dependency, generated, cache, vendored, and build-output trees from broad scans and scoring. Common examples: `.git`, `node_modules`, `.next`, `dist`, `build`, `coverage`, `target`, `vendor`, `.venv`, and `__pycache__`.
   - Read existing guidance before changing it. Treat user-authored content as authoritative; preserve useful content and do not replace or delete a file wholesale just because `--create-new` was requested. If its ownership or intent is unclear and a safe merge is not possible, ask before replacing it.
   - If the repository is cleanly too small or has no useful code/project structure to map, explain that and avoid manufacturing documentation.
   **Done when:** the repository shape, relevant existing guidance, and likely project-specific conventions are understood well enough to cite their source files.

2. **Choose locations.** Always consider a root `AGENTS.md`. Add a nested file only when that directory has substantial complexity, a distinct domain, or local instructions that would not apply repository-wide. Base the choice on observed structure and conventions, not a numeric score alone. Prefer fewer, useful files over coverage of every directory. Honor `--max-depth`.
   - A child file should add guidance specific to its subtree, not restate the root or ancestor file. Account for which guidance is inherited by tools that support nested `AGENTS.md` files.
   - `--create-new` means regenerate the knowledge while preserving hand-authored instructions and unrelated files; it does not authorize deleting all existing guidance.
   **Done when:** every proposed file has a clear reason to exist and no proposed child merely duplicates its parent.

3. **Write the root first, then any justified children.** Use concise, specific, verifiable facts. Prefer links/paths to exhaustive inventories. Omit sections that have no useful evidence rather than filling them with boilerplate.
   - Root sections, as useful: `OVERVIEW`, `STRUCTURE`, `WHERE TO LOOK`, `CONVENTIONS`, `COMMANDS`, `NOTES`, and project-specific `ANTI-PATTERNS`.
   - Child sections, as useful: `OVERVIEW`, `WHERE TO LOOK`, and local `CONVENTIONS`, `COMMANDS`, `NOTES`, or project-specific `ANTI-PATTERNS`.
   - Include exact commands only when verified in repository files or tool output. Mark inferred commands as inferred or omit them. Keep examples portable; label OS-specific commands.
   - Include a symbol/code map only when it helps locate important entry points or central abstractions. Verify symbols and references from source/tool output; omit speculative counts and exhaustive symbol dumps.
   - Keep each file short enough to scan (usually under 150 lines); there is no minimum length. Use paths relative to the repository root unless an absolute path is necessary.
   **Done when:** each statement is useful for an agent working in that scope and is supported by repository evidence or clearly labeled as an inference.

4. **Review the result.** Check all changed guidance for accuracy, duplication, stale claims, unsafe commands, and generic advice. Confirm nested docs add local value and requested depth was respected. Re-read existing files to ensure their useful hand-authored content remains.
   **Done when:** every changed file passes these checks and its contents match the inspected repository.

5. **Report completion.** List files created/updated, summarize the hierarchy, and mention any skipped or preserved files and unresolved uncertainty. Do not claim checks or tool-assisted analysis that were not performed.
   **Done when:** the user can tell what changed and what remains unresolved.

## Tooling and collaboration

- Use the host's available file listing, search, and read tools for discovery. If a safe subprocess tool and `rg` are available, `rg --files` and `rg` searches can speed up large scans; retain a native-tool fallback and respect ignore/exclude rules. Treat paths as opaque values and use runtime path handling when available.
- Use LSP, AST, or symbol tools only when available and relevant. Verify important findings against source. Missing tools are not blockers.
- Delegate only when the host provides subagents and the repository is large or has genuinely independent areas to inspect. Keep delegation bounded to the selected scopes; consolidate and verify returned findings in the main session. Otherwise work directly with available tools. Parallelize independent reads when supported; do not create agents to satisfy a quota.
- Track phases with a task tool only when one is available and useful; a checklist is sufficient for this workflow.

## Safety and scope

- Update mode is the default: make the smallest merge that improves agent orientation.
- Preserve user-authored guidance and unrelated files.
- Do not delete files as part of regeneration. If replacing existing content is necessary, preserve custom guidance and ask first when intent is ambiguous.
- Do not invent project conventions, forbidden patterns, test/build commands, commit metadata, or claims about tools and workflows. Omit unsupported details.
- Do not add generic advice that belongs in global agent instructions rather than this repository's map.
