# PROJECT KNOWLEDGE BASE

**Generated:** 2026-10-06 | **Commit:** 7258a19 | **Branch:** docs/repository-agents-index

## OVERVIEW
Repository of reusable agent skills. Each package is centered on `SKILL.md`; the collection has no application runtime or repository-wide build/test pipeline.

## STRUCTURE
```text
./
├── LICENSE
├── README.md            # catalog, installation guidance, and package map
└── skills/              # self-contained skill packages; see skills/AGENTS.md
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Find or install a skill | `README.md` | Catalog and supported install paths |
| Change a skill workflow | `skills/<name>/SKILL.md` | Primary instructions and invocation rules |
| Change skill discovery metadata | `skills/<name>/metadata.json` | Package-specific metadata |
| Change model-specific agent guidance | `skills/<name>/agents/` | Only for packages that provide it |
| Change supporting material | `skills/<name>/references/` | Load only when the skill workflow calls for it |
| Update index-knowledge documentation | `skills/index-knowledge/` | Includes a skill README as well as `SKILL.md` |

## CODE MAP
This repository is documentation/configuration rather than executable application code; navigate through skill entrypoints instead of searching for runtime symbols.

| Domain | Location | Role |
|--------|----------|------|
| GitHub and PR workflows | `skills/github/`, `skills/pr/`, `skills/babysit-pr/` | CLI use, PR drafting, and one-PR review/fix cycle |
| Writing | `skills/humanise/` | Draft audit with a focused reference |
| PowerShell | `skills/powershell/` | Scripting practices and focused references |
| Testing | `skills/testing/` | TypeScript and Effect testing guidance |
| Knowledge indexing | `skills/index-knowledge/` | Hierarchical `AGENTS.md` generation |
| X lookup | `skills/x-lookup/` | Read-only public X content access |

## CONVENTIONS
- Keep each skill self-contained; its `SKILL.md` is the workflow authority.
- Put optional supporting detail in package-local `references/` and link it from the workflow at the condition that needs it.
- Keep package metadata and agent-specific configuration local to the relevant skill.
- When editing a package, follow its own instructions; do not apply another skill's subject-specific workflow as repository-wide policy.

## ANTI-PATTERNS (THIS PROJECT)
- Do not invent repository-wide build, test, lint, or release commands; none are defined at the root.
- Do not duplicate full skill workflows in this index. Keep the README as the human-facing catalog and `SKILL.md` as the agent-facing entrypoint.
- Do not assume every package has `agents/`, `references/`, or identical supporting files; inspect its directory first.
- Do not treat example commands inside a skill as repository validation commands.

## UNIQUE STYLES
- Skill packages are independent and selectively include metadata, agent configs, references, and credits.
- The README documents installation and purpose; detailed operational instructions belong to each package.

## COMMANDS
No repository-wide command is defined for build, test, or lint. Use the relevant package's documented workflow when changing skill content; validate edits by checking links, paths, and instructions against the repository files.

## NOTES
- Supporting references are intentionally conditional; follow the trigger in the owning `SKILL.md` before loading them.
- The root README is the maintained catalog. Update it when adding or removing a skill package.
