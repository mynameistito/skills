# SKILL PACKAGE MAP

## OVERVIEW
This directory contains independent agent-skill packages; each package defines its own workflow in `SKILL.md`.

## STRUCTURE
```text
skills/
├── <skill>/SKILL.md
├── <skill>/metadata.json       # present for most packages
├── <skill>/agents/             # optional agent-specific configuration
└── <skill>/references/         # optional conditional reference material
```

## WHERE TO LOOK
| Need | Location |
|------|----------|
| GitHub CLI practices | `github/SKILL.md` |
| Draft a pull request | `pr/SKILL.md` and `pr/references/` |
| Work through one PR's feedback and CI | `babysit-pr/SKILL.md` |
| Review writing for AI-sounding patterns | `humanise/SKILL.md` and `humanise/references/` |
| PowerShell scripting | `powershell/SKILL.md` and `powershell/references/` |
| TypeScript/Effect testing | `testing/SKILL.md` |
| Generate codebase knowledge files | `index-knowledge/SKILL.md` and `index-knowledge/README.md` |
| Read public X content | `x-lookup/SKILL.md` |

## CONVENTIONS
- Treat `SKILL.md` as the authoritative execution flow; keep descriptions, examples, and linked references consistent with it.
- Put branch-specific details in references and make the entrypoint state exactly when to load them.
- Keep `metadata.json` and `agents/` configuration aligned with the package name and purpose.
- Check `../README.md` when adding/removing a package or changing its user-facing purpose.

## ANTI-PATTERNS
- Avoid adding `AGENTS.md` inside individual skill packages when it would restate that package's `SKILL.md`.
- Do not copy one skill's subject-specific rules into sibling packages; shared repository guidance belongs at the root.
- Do not assume package layouts are uniform; inspect the target package before editing or describing its files.
