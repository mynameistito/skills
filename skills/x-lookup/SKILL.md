---
name: x-lookup
description: Read public X (Twitter) statuses, conversations, profiles, search results, followers, and following through x-lookup.mynameistito.com. Use when an agent needs current public X content as compact or full Markdown or JSON without browser login, cookies, an API key, or a repository checkout.
license: MIT
metadata:
  author: mynameistito
  version: "1.0.0"
allowed-tools:
  - Bash(bun skills/x-lookup/scripts/x-lookup.ts *)
  - Bash(curl *x-lookup.mynameistito.com*)
---

# Use x-lookup.mynameistito.com

Use the hosted, read-only API. It needs no repository checkout, install, X login, cookies, or API key. Only public X content is available.

The `curl` examples below are the portable default for this catalog. When working from a checkout of [mynameistito/x-lookup](https://github.com/mynameistito/x-lookup), the repository also provides `skills/x-lookup/scripts/x-lookup.ts` as a typed Bun wrapper around the same API:

```bash
bun skills/x-lookup/scripts/x-lookup.ts \
  "https://x.com/handle/status/1234567890"

bun skills/x-lookup/scripts/x-lookup.ts search \
  "from:handle release" --feed latest
```

Use the wrapper's `--help` for its full CLI options. Do not assume this catalog contains the wrapper itself; use the hosted API when that checkout is unavailable.

## Read statuses and conversations

```bash
curl -sS -G "https://x-lookup.mynameistito.com/api/convert" \
  --data-urlencode "url=https://x.com/handle/status/1234567890" \
  --data-urlencode "thread=full" \
  -H "Accept: text/markdown"
```

The default is a compact Markdown conversation with parent context and selected replies. Use `thread=off` for one status, `thread=20` to cap the conversation, `context=thread` for only the direct author chain, or `replies=recent|off` to change reply inclusion. Direct status rewrites also work at `https://x-lookup.mynameistito.com/:handle/status/:id`.

## Browse profiles and people

Use the browse endpoint with a public X URL or handle:

```bash
curl -sS -G "https://x-lookup.mynameistito.com/api/browse" \
  --data-urlencode "resource=profile" \
  --data-urlencode "handle=handle" \
  --data-urlencode "limit=20" \
  -H "Accept: text/markdown"
```

Profiles return profile details and original recent posts. The upstream API does not expose pinned-post markers. Use `resource=followers` or `resource=following` with the same `handle` parameter to list people. Add `full=true` for metrics, dates, descriptions, and counts.

## Search and pagination

```bash
curl -sS -G "https://x-lookup.mynameistito.com/api/browse" \
  --data-urlencode "resource=search" \
  --data-urlencode "q=from:handle release" \
  --data-urlencode "feed=latest" \
  --data-urlencode "limit=10" \
  -H "Accept: text/markdown"
```

Search feeds are `latest` (default), `top`, and `media`. `limit` is capped at 50. Prefer the opaque cursor from the Markdown `Continue` link or JSON `nextCursor` for reliable continuation. If search returns HTTP 502 with code `search_unavailable`, treat it as temporarily unavailable rather than missing content.

## Output and source

- Markdown is compact by default. Use `full=true`; status conversion also supports `format=obsidian`.
- Send `Accept: application/json` when structured posts, users, media, `nextCursor`, warnings, or the provider `source` are needed.
- Inspect the `X-Source` response header when diagnosing provider selection. Video is not downloaded or transcoded; inspect the media URLs in JSON or Markdown.
- Add `nocache=true` to bypass the hosted cache.

## Errors and limits

Private, deleted, gated, or unavailable posts cannot be read. Fallback sources can omit conversation posts, articles, quotes, or media; inspect JSON `warnings` and `source` rather than inventing missing content. Preserve API errors and status codes when reporting failures.
