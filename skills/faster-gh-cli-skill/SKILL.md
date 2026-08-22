---
name: faster-gh-cli-skill
description: Use GitHub CLI (`gh`) for pull requests, issues, reviews, Actions runs, repositories, secrets, gists, and API requests. Covers repository targeting, structured output, multiline Markdown, non-interactive workflows, typed API fields, and diagnosis of common GitHub CLI failures.
license: MIT
compatibility: Requires GitHub CLI, Git, GitHub network access, and an authenticated gh session.
metadata:
  author: zeke
  version: "1.0.0"
---

# Use GitHub CLI reliably

Prefer `gh` for GitHub work. Establish the authenticated account and repository before reading or changing remote state:

```powershell
gh auth status
gh repo view --json nameWithOwner,url,defaultBranchRef
git status --short
```

Pass `--repo owner/name` whenever the target is not unambiguous from the current working directory. Inspect an object before mutating it.

## Read structured output

Prefer `--json` and `--jq` over parsing display output:

```powershell
gh pr view 123 --repo owner/repo --json number,title,state,url,headRefName,baseRefName --jq '{number,title,state,url,head: .headRefName,base: .baseRefName}'
gh issue view 456 --repo owner/repo --json number,title,state,url
gh run list --repo owner/repo --limit 10 --json databaseId,status,conclusion,workflowName,url
```

When a JSON field is uncertain, inspect `gh <command> --help`. If help does not list fields, use a harmless invalid field to make `gh` print the valid set, then retry once:

```powershell
gh repo view owner/repo --json _fields
```

Common corrections:

| Incorrect assumption | Use instead |
| --- | --- |
| `defaultBranch` | `defaultBranchRef` |
| `stargazersCount` | `stargazerCount` |
| `merged` | `state`, `mergedAt`, or `closed` |
| `mergedAt` in search results | `closedAt`, or query the PR with `gh pr view` |
| `topics` in `gh repo view` | `gh api repos/owner/repo/topics` |

`gh search prs --state merged` is invalid. Use `--merged`; search's `--state` accepts `open` or `closed`.

## Send Markdown through files

Use `--body-file` for multiline Markdown in PRs, issues, and comments. Create the file with the environment's file-editing tool, pass it to `gh`, then remove it. This avoids shell interpolation of backticks, variables, and quotes.

```powershell
gh pr create --repo owner/repo --base main --head branch-name --title "fix: describe the change" --body-file path/to/pr-body.md
gh issue create --repo owner/repo --title "docs: add homepage" --body-file path/to/issue-body.md
gh pr comment 123 --repo owner/repo --body-file path/to/comment.md
```

Use the same pattern with `gh pr edit`, `gh issue edit`, and `gh issue comment`. A short, plain-text body without shell metacharacters may use `--body` directly.

## Work with pull requests

Read the PR and local branch state before creating or changing a PR:

```powershell
gh pr view 123 --repo owner/repo --json number,title,body,state,url,headRefName,baseRefName,author,commits,files,additions,deletions
git status --short
git branch --show-current
git log --oneline -10
git fetch origin
git log --oneline origin/main..HEAD
```

Before `gh pr create`, confirm the branch has commits relative to the base and exists remotely. Push with `git push -u origin HEAD` when needed. For a fork, pass `--head owner:branch-name`.

Errors such as `Head sha can't be blank`, `Base sha can't be blank`, `No commits between`, and `Head ref must be a branch` indicate an incorrect base/head, an unpushed branch, or no commits to compare. Diagnose branch and remote state before retrying.

Useful PR reads:

```powershell
gh pr list --repo owner/repo --state all --head branch-name --json number,title,state,url
gh pr diff 123 --repo owner/repo
gh pr diff 123 --repo owner/repo --name-only
gh pr checks 123 --repo owner/repo
```

`gh pr diff --stat` is unsupported. Use `gh pr view --json additions,deletions,changedFiles`.

For inline review comments, use `gh api` only after reading the PR files and existing comments. The API strictly validates `commit_id`, `path`, `side`, `line`, and `start_line`; bad positions return HTTP 422. Reply to an existing inline comment instead of creating a new top-level comment when continuing its thread.

## Inspect Actions

```powershell
gh pr checks 123 --repo owner/repo --watch
gh run list --repo owner/repo --branch branch-name --limit 10 --json databaseId,status,conclusion,displayTitle,workflowName,createdAt,url
gh run view RUN_ID --repo owner/repo --json status,conclusion,url,jobs
gh run view RUN_ID --repo owner/repo --log-failed
```

`gh run watch RUN_ID --exit-status` can wait indefinitely. Use it only when waiting is part of the task and give the command an appropriate timeout.

If workflow dispatch returns HTTP 422 because the workflow lacks `workflow_dispatch`, inspect the workflow file instead of retrying.

## Use `gh api` as the fallback

Use a dedicated `gh` subcommand when one exists. Otherwise use `gh api`:

```powershell
gh api repos/owner/repo/pulls/123/files --paginate --jq '.[] | {filename,status,patch}'
gh api repos/owner/repo/contents/path/to/file -H "Accept: application/vnd.github.raw"
```

Preserve value types:

| Value | Pattern |
| --- | --- |
| String | `--raw-field name=value` |
| Typed JSON scalar | `--field count:=10 --field enabled:=true` |
| Complex JSON | `--input path/to/request.json` |

`-f enabled=true` sends the string `"true"`, not a boolean, and can cause HTTP 422.

## Handle secrets and gists

List secret names with `gh secret list --repo owner/repo`. Pipe secret values from an environment variable or a secret manager into `gh secret set`; never place values in command arguments, files, issues, or PR bodies.

PowerShell:

```powershell
$env:SECRET_VALUE | gh secret set SECRET_NAME --repo owner/repo
```

POSIX shell:

```sh
printf '%s' "$SECRET_VALUE" | gh secret set SECRET_NAME --repo owner/repo
```

For gists, omit `--public` to create a secret gist; `gh gist create --private` is not valid. When reading from stdin, include `-` and provide non-empty content.

## Diagnose failures

1. Read the exact error and command help.
2. For an unknown field or flag, discover the valid usage and retry once.
3. For PR creation errors, inspect status, branch, remotes, push state, and `origin/base..HEAD`.
4. For HTTP 401, 403, or GraphQL permission errors, run `gh auth status` and report missing permissions.
5. For HTTP 422, inspect request shape, typed fields, and review-comment positions.
6. For a timeout or transient network error, retry once with a narrower request or suitable timeout.
7. After two equivalent failures, change the diagnosis rather than repeating the command.

Interactive authentication needs the user. Do not start `gh auth refresh` in an unattended workflow. Organization repository creation may require organization-level permission that no CLI flag can bypass.
