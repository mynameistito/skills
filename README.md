# skills

> Personal agent skills for Codex and other skill-aware coding agents.

This repository collects reusable skills under `skills/`. Each skill is a self-contained folder with its own `SKILL.md` and any supporting metadata, references, scripts, or assets it needs.

## Available Skills

| Skill | Purpose |
|-------|---------|
| `index-knowledge` | Generate hierarchical `AGENTS.md` knowledge bases for codebases. |
| `humanise` | Audit drafts for AI-sounding patterns and rewrite them to feel more natural while preserving meaning and tone. |
| `x-lookup` | Read public X content through the hosted API as Markdown or JSON. |
| `github` | Use GitHub CLI reliably for PRs, issues, Actions, API requests, secrets, and repositories. |
| `pr` | Draft template-aware, evidence-backed pull request bodies with concise visuals and merge-risk context. |
| `powershell` | Write, review, debug, and test PowerShell scripts, including safe here-string and multiline payload handling. |
| `pwsh7` | Recover any agent session from an outdated Windows PowerShell host by launching the installed PowerShell 7.6+ runtime. |
| `babysit-pr` | Review one named PR, fix clear feedback, verify CI, and reply with signed updates. |
| `testing` | Apply testing standards for TypeScript and Effect projects using Bun and Vitest. |

## Installation

### Using `npx skills add`

List the skills available from this repository:

```bash
npx skills add mynameistito/skills --list
```

Install a specific skill:

```bash
npx skills add mynameistito/skills/index-knowledge
npx skills add mynameistito/skills/humanise
npx skills add mynameistito/skills/x-lookup
npx skills add mynameistito/skills/github
npx skills add mynameistito/skills/pr
npx skills add mynameistito/skills/powershell
npx skills add mynameistito/skills/pwsh7
npx skills add mynameistito/skills/babysit-pr
npx skills add mynameistito/skills/testing
```

Install globally:

```bash
npx skills add mynameistito/skills/humanise -g
```

Target a specific agent:

```bash
npx skills add mynameistito/skills/humanise -a codex
npx skills add mynameistito/skills/index-knowledge -a claude-code
npx skills add mynameistito/skills/x-lookup -a codex
npx skills add mynameistito/skills/github -a codex
npx skills add mynameistito/skills/pr -a codex
npx skills add mynameistito/skills/powershell -a codex
npx skills add mynameistito/skills/pwsh7 -a codex
npx skills add mynameistito/skills/babysit-pr -a codex
npx skills add mynameistito/skills/testing -a codex
```

### Manual Installation

Copy the desired skill folder into your agent's skills directory:

| Agent | Project Location | Global Location |
|-------|------------------|-----------------|
| OpenCode | `./.opencode/skill/` | `~/.config/opencode/skill/` |
| Claude Code | `./.claude/skills/` | `~/.claude/skills/` |
| Codex | `./.codex/skills/` | `~/.codex/skills/` |
| Cursor | `./.cursor/skills/` | `~/.cursor/skills/` |

## Skill Notes

### `index-knowledge`

Generates concise, hierarchical `AGENTS.md` files for a codebase. It scans project structure, scores directories by complexity and domain distinctness, writes a root knowledge file, and creates targeted subdirectory docs where they are useful.

The original version was found in [@dmmulroy](https://github.com/dmmulroy/)'s [.dotfiles](https://github.com/dmmulroy/.dotfiles) repository. This fork extends it with an OS-agnostic workflow that uses agent-native tools instead of platform-specific shell commands.

See `skills/index-knowledge/README.md` and `skills/index-knowledge/SKILL.md` for the full workflow.

### `humanise`

Reviews user-provided drafts for AI-sounding writing patterns, using Wikipedia's [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) as a heuristic reference. It rewrites text to sound more natural, personal, and context-aware while preserving the original meaning and tone, then explains the main changes.

See `skills/humanise/SKILL.md` for the workflow and `skills/humanise/references/signs-of-ai-writing.md` for the compact reference.

### `x-lookup`

Reads public X statuses, conversations, profiles, search results, followers, and following through the hosted, read-only `x-lookup.mynameistito.com` API. It does not require an X login, cookies, API key, or local repository checkout. Markdown is the default response format; request JSON when structured content, pagination cursors, warnings, or provider details are needed.

See `skills/x-lookup/SKILL.md` for endpoint examples and limits.

### `github`

Guides agents through reliable GitHub CLI workflows: establishing repository context, reading structured output, sending Markdown through body files, inspecting branches before creating PRs, handling typed `gh api` fields, and diagnosing permission or request-shape failures. Adapted from [zeke/faster-gh-cli-skill](https://github.com/zeke/faster-gh-cli-skill) with portable PowerShell and POSIX guidance.

See `skills/github/SKILL.md` for the workflow.

### `pr`

Drafts a pull request body from the current change. It prefers the repository's actual PR template unless explicitly overridden by the user, gathers targeted evidence, chooses a concise visual summary when useful, and uses an evidence-based 1–10 Merge Danger rating in the no-template fallback or an existing repository risk section.

Adapted with credit to [Matt Pocock's reference `pr` skill](https://github.com/mattpocock/skills/tree/main/skills/engineering/pr) and [Dex Horthy and HumanLayer's `show-me` skill](https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md). See `skills/pr/CREDITS.md`.

### `powershell`

Guides agents through reliable PowerShell scripting: object pipelines, functions, errors, paths, native-command boundaries, side-effect safety, and cross-platform/version differences. Its detailed here-string reference covers literal versus expandable forms, parser-safe delimiters, Bash heredoc conversion, nested YAML/shell parsing, safer file/stdin workflows, structured JSON generation, and syntax validation without execution.

See `skills/powershell/SKILL.md` for the workflow and here-string reference.

### `pwsh7`

Checks the current PowerShell host and, on any version below 7.6, launches the installed Microsoft.PowerShell Appx `pwsh.exe` in a new process. It verifies the new host and explains that work must continue in that session.

See `skills/pwsh7/SKILL.md` for the recovery workflow.

### `babysit-pr`

Works on one explicitly named PR and repeats review, fix, and CI-check cycles until required checks pass and no actionable review threads remain. It verifies the authenticated GitHub username for each run and uses it in every comment signature. It merges only when explicitly asked and after confirming the PR is open and mergeable, required checks pass, and actionable review threads are resolved.

See `skills/babysit-pr/SKILL.md` for the workflow.

### `testing`

Guides agents through meaningful TypeScript and Effect testing: choosing unit, integration, or regression coverage; testing typed failures through Effect Layers; selecting honest test doubles; isolating time and state; covering Cloudflare boundaries; and running focused verification.

See `skills/testing/SKILL.md` for the workflow.

## Repository Layout

```text
skills/
├── LICENSE
├── README.md
└── skills/
    ├── babysit-pr/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   └── metadata.json
    ├── github/
    │   ├── SKILL.md
    │   ├── LICENSE
    │   ├── agents/openai.yaml
    │   └── metadata.json
    ├── pr/
    │   ├── SKILL.md
    │   ├── CREDITS.md
    │   ├── agents/openai.yaml
    │   ├── references/fallback-format.md
    │   └── metadata.json
    ├── humanise/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   ├── metadata.json
    │   └── references/signs-of-ai-writing.md
    ├── index-knowledge/
    │   ├── SKILL.md
    │   ├── README.md
    │   └── metadata.json
    ├── powershell/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   └── metadata.json
    ├── pwsh7/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   ├── scripts/pwsh7.ps1
    │   ├── scripts/pwsh7.cmd
    │   └── metadata.json
    ├── testing/
    │   ├── SKILL.md
    │   ├── agents/openai.yaml
    │   └── metadata.json
    └── x-lookup/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── metadata.json
```

## License

MIT, see [LICENSE](./LICENSE).
