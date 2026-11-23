---
name: blacksmith
description: Use the Blacksmith CLI from WSL to inspect CI, report usage, manage caches, and run Testboxes.
disable-model-invocation: true
---

# Blacksmith CLI

Use this skill when the user explicitly invokes `$blacksmith` or asks to use this skill.

## Run in WSL

From Windows, use the user's WSL distro and a login shell so the CLI uses the Linux PATH and account. Verify the CLI before using it.

```powershell
wsl.exe -- bash -lc 'blacksmith --version'
```

Add `-d <distro>` before `--` if the user names a distro. Run the Bash examples below inside WSL. For repository-dependent commands, change to the intended checkout and confirm it with `git rev-parse --show-toplevel`. Translate a Windows path with `wslpath` when needed and quote paths with spaces.

If Blacksmith is missing and installation is in scope, use the [official Linux installer](https://docs.blacksmith.sh/blacksmith-cli/overview.md#installation) inside WSL. Recheck `blacksmith --version` in a fresh login shell. Check `blacksmith <command> --help` for the installed CLI's flags.

## Select the organization

Load the `2password` skill before handling credentials. Use `blacksmith auth status` to find the organizations available in WSL. If login is needed, use the browser flow from `blacksmith auth login` and let the user complete sign-in. If a headless machine needs an existing organization token, follow the [authentication guide](https://docs.blacksmith.sh/blacksmith-cli/overview.md#authentication) and pass the token through stdin using the credential workflow. Keep token values out of chat, command arguments, and logs.

Use `--org <slug>` when the organization is known. Use an explicit `--repo owner/repo` wherever the subcommand supports it. For organization-wide queries, set the time range and narrow by repository when the task calls for it.

## Pick the command

Replace the example repository, job ID, and time window with values from the task. Use `--format json` for downstream parsing where the command supports it.

| Task | Starting command and reference |
| --- | --- |
| Find failed jobs in a repository | `blacksmith jobs list --repo owner/repo --conclusion failure --since 7d --format table`. Use the returned job ID with `blacksmith jobs logs 12345678` or `blacksmith jobs stats 12345678`. [Jobs](https://docs.blacksmith.sh/blacksmith-cli/jobs.md) |
| Search across CI logs | `blacksmith logs search --query 'level:error repo:owner/repo "connection refused"' --since 24h`. [Logs](https://docs.blacksmith.sh/blacksmith-cli/logs.md) |
| Report compute usage and estimated cost | `blacksmith usage --since 30d --breakdown-by runner_type,repo --format table`. Use `usage storage` for storage and `runners catalog` for runner SKUs. [Usage](https://docs.blacksmith.sh/blacksmith-cli/usage.md) |
| Inspect Actions or Bazel cache entries | `blacksmith cache list --repo owner/repo --format table`. For a requested deletion, match the key and scope against the listing. The `clear` command removes all Actions cache entries for the repository. [Cache](https://docs.blacksmith.sh/blacksmith-cli/cache.md) |
| Inspect sticky disks | `blacksmith stickydisk list --repo owner/repo --format table`. For a requested deletion, match the disk key against the listing. [Sticky disks](https://docs.blacksmith.sh/blacksmith-cli/stickydisk.md) |

For CI triage, report the matching job ID, the relevant step or error, and what the logs or metrics show. For usage reports, include the organization, date range, and units. The CLI's estimated cost uses list prices.

## Run tests in a Testbox

Read the [Testbox command guide](https://docs.blacksmith.sh/blacksmith-cli/testbox.md) for setup, sync behavior, and flags. Testboxes require a configured workflow in the target repository. `blacksmith testbox init` is interactive and writes workflow and skill files, so use it when the user asks to set up Testboxes.

1. In the intended checkout, run `blacksmith testbox warmup blacksmith-testbox.yml` with the actual workflow filename. Set `--ref` and `--job` when the task requires a particular ref or job. Warmup dispatches a GitHub Actions run and returns a Testbox ID.
2. Verify the checkout contains the changes intended for remote sync. Run `blacksmith testbox run --id "$testbox_id" 'npm test'` with the returned ID and the repository's real test command. The command waits for readiness, mirrors local changes via rsync, and returns the remote exit code. Files deleted locally are removed from the remote mirror.
3. Report the Testbox ID and test result. Stop the Testbox you created when finished with `blacksmith testbox stop --id "$testbox_id"`. Stopping it cancels its underlying Actions run. Keep it running if the user asked to reuse it.
