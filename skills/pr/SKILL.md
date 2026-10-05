---
name: pr
description: Use whenever the user asks to write, rewrite, or improve a pull request body. Prefer the repository's actual PR template unless the user explicitly requests another template or format; gather targeted evidence, add a useful visual when it clarifies the change, and include an evidence-based Merge Danger rating when the selected format has a risk section.
license: MIT
compatibility: Requires Git, GitHub CLI (`gh`), GitHub network access, and an authenticated `gh` session.
metadata:
  author: mynameistito
  version: "1.0.0"
---

# Draft a review-ready pull request body

Draft the body only. Use GitHub CLI for repository and pull-request context; never create or edit a remote PR. Return the copy-ready body first, followed by compact author notes.

## Workflow

### 1. Establish repository context and the change set

Run these read-only checks:

```sh
gh auth status
gh repo view --json nameWithOwner,defaultBranchRef
git status --short --branch
gh pr view --json number,title,url,state,headRefName,baseRefName,body,labels
```

Require an authenticated `gh` session. If the current branch has no PR, continue with a local draft and note that no remote PR was found. Use the existing PR base when available; otherwise use the repository default branch.

If `gh pr view` reports that no PR exists for the current branch, continue with a local draft. Treat authentication and network errors as blockers instead of interpreting them as an absent PR.

Inspect the committed branch diff against the base, then inspect staged, unstaged, and untracked files. Include working-tree changes only when they clearly belong to this change and identify them in author notes. Preserve unrelated local work. Stop and report what was inspected when no eligible change set exists.

**Complete when:** repository, branch, base, PR presence, and eligible changed files are known.

### 2. Resolve the output contract

Start with the user's request:

- A direct request to use, ignore, replace, or override a template wins over repository template preference.
- The request may name a template, provide a custom structure, request the fallback format despite an existing template, or ask to ignore all repository templates.
- Record the explicit override in author notes. Continue to apply repository terminology, verification requirements, and safety guidance unless the user gives a clear, in-scope alternative.

Regardless of format override, read applicable `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING` documentation, glossary, package guidance, and other local instructions for relevant terminology, verification requirements, and safety rules. An explicit format override changes the body contract, not which relevant repository guidance applies.

When the user has not explicitly overridden the format, inspect these body-template locations in order:

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/PULL_REQUEST_TEMPLATE/*.md`
3. Root-level `PULL_REQUEST_TEMPLATE.md`

Treat `.github/PULL_REQUEST_TEMPLATE/config.yml` as selector metadata, not body content. If repository guidance names another path, use it only when it clearly identifies the repository's intended PR body template. When the user explicitly names a repository template, inspect that template; when they request a custom structure, fallback format, or no repository template, follow that override without template discovery.

For multiple templates, infer the best fit from filenames, headings, branch or PR metadata, changed paths, and change type. Ask the author to choose when no candidate is defensible; use one template rather than silently combining them.

When a PR already has a human-written body, preserve meaningful context by mapping it into the selected format. Retain claims only when the diff or fresh evidence supports them.

**Complete when:** an explicit override, one repository template, or the no-template fallback has been selected.

### 3. Build an evidence record

Read the diff and the surrounding code needed to explain ownership, data movement, state changes, and user-visible behavior. Identify the smallest relevant verification commands from repository guidance and package scripts, inspect each command before running it, and run targeted checks such as the affected test, typecheck, lint, build, or focused integration test.

Record each relevant check as **passed**, **failed**, **blocked**, or **not run**. Summarize output and redact secrets, credentials, customer data, private URLs, and noisy logs. Use only observed evidence; label unavailable before/after artifacts honestly.

**Complete when:** every factual claim planned for the body has supporting diff context or observed evidence, and verification gaps are known.

### 4. Choose review aids

Use the smallest visual that makes the change easier to review:

- Mermaid `flowchart`, `sequenceDiagram`, or state/data-flow diagram for runtime or data movement.
- Text call tree or pseudocode for algorithm and control-flow changes.
- Component tree, file tree, or focused diff for structural changes.

Prefer Mermaid in a fenced `mermaid` block. Use text when Mermaid would be unsupported, ambiguous, or excessive. Include only meaningful calls, files, states, props, and module boundaries. Omit visuals for trivial or documentation-only changes.

In repository-template mode, place a visual only in a compatible existing description or summary slot. In an explicit custom-format mode, follow the requested structure. When no compatible slot exists, omit the visual instead of adding a section.

For Merge Danger, use a numeric rating only when the selected format has a risk section or the no-template fallback is active. In repository-template mode, add the rating inside the existing risk section and preserve its fields. In an explicit custom format, include the rating only if that format provides a risk section. When no risk section exists, omit the score and risk analysis entirely.

**Complete when:** the body has the clearest useful visual and permitted risk information, or their omission is justified by the selected format.

### 5. Render the selected format

#### Repository template

Treat the selected template as the body contract:

- Preserve headings, order, required wording, and checklists.
- Replace instructional placeholders with concise factual content.
- Mark inapplicable sections `N/A` with a short reason instead of deleting them.
- Fill only what the diff and evidence support; preserve uncertainty in author-only items.
- Put evidence and visuals into existing compatible slots.
- Add `Rating: X/10` and its rationale inside an existing Merge Danger or risk section; do not create a new section.

#### Explicit custom format

Follow the user's requested structure exactly. Use the evidence record and permitted visual/risk guidance above without importing repository-template headings the user asked to replace.

#### No repository template

Read [`references/fallback-format.md`](references/fallback-format.md), then use its Summary, Evidence, and Merge Danger structure. The reference contains the rating bands and the required `Rating`, `Door`, and `Blast Radius` fields.

**Complete when:** the rendered body follows the selected contract and contains no unsupported claims or invented artifacts.

### 6. Return the draft

Return the copy-ready PR body first. Follow it with compact author notes containing:

- the selected template, explicit override, or fallback mode;
- checks and their passed/failed/blocked/not-run status;
- relevant uncommitted changes and evidence gaps;
- template constraints that caused a visual or risk section to be omitted.

When the selected format has no risk section, keep the Merge Danger score out of both the body and notes. Keep source attribution in this skill's `CREDITS.md`, not in generated PR bodies.

**Complete when:** the body is immediately copyable, notes are concise, and each factual claim is traceable to the diff or observed evidence.
