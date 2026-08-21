---
name: browse-x
description: Read public X statuses, conversations, profiles, search results, followers, and following as compact or full Markdown or JSON through local Bun code.
license: MIT
metadata:
  author: mynameistito
  version: "1.0.0"
allowed-tools:
  - Bash(bun *browse-x.ts *)
---

# Browse X

This personal adaptation is based on the original `browse-x` skill from
[`pc-style/x-md`](https://github.com/pc-style/x-md), created by `mynameistito`.
Credit and behavior notes from the original implementation are retained here.

Use the local, read-only Bun implementation. It requires no x.md checkout or
hosted x.pcstyle.dev service. It fetches public data from upstream FxTwitter and
X syndication endpoints. Only public X content is available.

The helper is at `scripts/browse-x.ts` relative to this skill directory. Run it
from the skill directory, or replace the path in the examples with the installed
skill path.

## Read statuses and conversations

```bash
bun scripts/browse-x.ts "https://x.com/handle/status/1234567890"

bun scripts/browse-x.ts status "https://x.com/handle/status/1234567890" \
  --thread full --context full --replies top --userinfo author --full
```

The default is a compact Markdown conversation (`thread=full`), including the
parent context and selected replies. Use `--thread off` for one status,
`--thread 20` to cap the conversation, `--context thread` for only the direct
author chain, or `--replies recent|off` to change reply inclusion.

## Browse profiles and people

```bash
bun scripts/browse-x.ts profile "@handle" --limit 20
bun scripts/browse-x.ts "https://x.com/handle" --full
bun scripts/browse-x.ts followers "handle" --limit 50
bun scripts/browse-x.ts following "handle" --page 2 --full
```

Profiles return profile details and original recent posts. Followers and
following return users. `--full` adds metrics, dates, descriptions, and counts;
compact Markdown is the default.

## Search and pagination

```bash
bun scripts/browse-x.ts search "from:handle release" --feed latest
bun scripts/browse-x.ts search "typescript" --feed media --page 3 --limit 10
bun scripts/browse-x.ts search "typescript" --cursor '<opaque cursor>'
```

Search feeds are `latest` (default), `top`, and `media`. `--page` walks from the
first page and is capped at 10; `--limit` is capped at 50. Prefer the opaque
cursor from the Markdown `Continue` link or JSON `nextCursor` for continuation.

## Output and limits

- Markdown is compact by default. `--full` expands metadata.
- `--format obsidian` adds frontmatter and post headings for statuses.
- `--json` returns the complete response object, including posts, users, media,
  `nextCursor`, warnings, and the status `source` provider.
- Add `--headers` to print response headers before the body.
- `--nocache` bypasses the hosted cache.
- Local results are cached on disk under `.cache/conversions` by default. Set
  `CACHE_DIR`, `CACHE_TTL_SECONDS`, or `CACHE_DISABLED=1` to control caching.
- Video is not downloaded or transcoded; inspect preserved media URLs in output.

The helper exits 2 for invalid CLI usage and 1 for network or non-2xx API
responses. Private, deleted, gated, or unavailable posts cannot be read.
