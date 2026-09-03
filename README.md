# skills

> Personal agent skills for Codex and other skill-aware coding agents.

This repository collects reusable skills under `skills/`. Each skill is a self-contained folder with its own `SKILL.md` and any supporting metadata, references, scripts, or assets it needs.

## Available Skills

| Skill | Purpose |
|-------|---------|
| `index-knowledge` | Generate hierarchical `AGENTS.md` knowledge bases for codebases. |
| `humanise` | Audit drafts for AI-sounding patterns and rewrite them to feel more natural while preserving meaning and tone. |
| `x-lookup` | Read public X content through the hosted API as Markdown or JSON. |
| `faster-gh-cli-skill` | Use GitHub CLI reliably for PRs, issues, Actions, API requests, secrets, and repositories. |
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
npx skills add mynameistito/skills/faster-gh-cli-skill
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
npx skills add mynameistito/skills/faster-gh-cli-skill -a codex
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

### `faster-gh-cli-skill`

Guides agents through reliable GitHub CLI workflows: establishing repository context, reading structured output, sending Markdown through body files, inspecting branches before creating PRs, handling typed `gh api` fields, and diagnosing permission or request-shape failures. Adapted from [zeke/faster-gh-cli-skill](https://github.com/zeke/faster-gh-cli-skill) with portable PowerShell and POSIX guidance.

See `skills/faster-gh-cli-skill/SKILL.md` for the workflow.

### `testing`

Guides agents through meaningful TypeScript and Effect testing: choosing unit, integration, or regression coverage; testing typed failures through Effect Layers; selecting honest test doubles; isolating time and state; covering Cloudflare boundaries; and running focused verification.

See `skills/testing/SKILL.md` for the workflow.

## Repository Layout

```text
skills/
├── LICENSE
├── README.md
└── skills/
    ├── faster-gh-cli-skill/
    │   ├── SKILL.md
    │   ├── LICENSE
    │   ├── agents/openai.yaml
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
