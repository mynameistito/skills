# Index Knowledge

Generate a concise, hierarchical `AGENTS.md` knowledge map for a codebase. Add nested files only where observed complexity or local conventions justify them. Use the host's available discovery tools; no specific shell is required.

## Platform Support

Prefer the host's file listing, search, and read tools. Optional tools such as `rg` and LSP can help when available, but are never required. The workflow does not assume a particular shell or operating system.

## Structure

- `SKILL.md` - Skill definition with frontmatter metadata and full workflow instructions
- `metadata.json` - Document metadata (version, organization, abstract)

## What It Does

1. **Inspect** - Understand repository structure, existing guidance, and verified conventions
2. **Choose** - Create a root map and only justified, non-duplicative nested maps
3. **Write** - Record concise project-specific orientation and verified commands
4. **Review** - Check accuracy, preservation, scope, and duplication

## Usage

```text
# Default: update mode (modify existing + create new where warranted)
index-knowledge

# Regenerate knowledge while preserving hand-authored guidance
index-knowledge --create-new

# Limit directory depth
index-knowledge --max-depth=2
```

## Choosing locations

Consider a nested file when a directory has substantial complexity, a distinct domain, or local conventions that would not apply repository-wide. Decide from observed structure and useful local guidance, rather than a numeric score. Omit generated, dependency, cache, vendored, and build-output trees.

## AGENTS.md Output Format

Root files may include, as useful: `OVERVIEW`, `STRUCTURE`, `WHERE TO LOOK`, `CODE MAP`, `CONVENTIONS`, `ANTI-PATTERNS`, `COMMANDS`, and `NOTES`. Include a `CODE MAP` only when it helps locate important entry points or abstractions, and include `ANTI-PATTERNS` only for project-specific rules.

Subdirectory files are leaner and may include, as useful: `OVERVIEW`, `WHERE TO LOOK`, `CONVENTIONS`, `COMMANDS`, `NOTES`, or project-specific `ANTI-PATTERNS`. Never repeat parent content.

Keep files concise (usually under 150 lines; no minimum). Preserve hand-authored guidance, avoid generic advice, and include only useful, supported details.

## Contributing

When modifying the skill:

1. Edit `SKILL.md` for workflow changes
2. Update `metadata.json` version for releases
3. Preserve the safe-update behavior and conditional use of optional tools
4. Keep each instruction actionable and project-specific; avoid fixed quotas or unsupported scoring
5. Do not assume a particular shell, platform, or agent tool is available
