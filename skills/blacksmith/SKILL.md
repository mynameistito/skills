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

Use `blacksmith auth status` to find the organizations available in WSL. If login is needed, use `blacksmith auth login` and let the user complete browser sign-in.

For headless login with an existing organization token, use `blacksmith auth login --api-token - --non-interactive --organization <slug>`. Load the `2password` skill before retrieving or passing a token and use it to supply the token over stdin. If that skill is unavailable, have the user complete the [documented stdin login](https://docs.blacksmith.sh/blacksmith-cli/overview.md#authentication) directly in WSL and then recheck `blacksmith auth status`. Keep token values out of chat, command arguments, and logs.

Use `--org <slug>` when the organization is known. Use an explicit `--repo owner/repo` wherever the subcommand supports it. For organization-wide queries, set the time range and narrow by repository when the task calls for it.

## Pick the command

Replace the example repository, job ID, and time window with values from the task. Use `--format json` for downstream parsing where the command supports it.

| Task | Starting command and reference |
| --- | --- |
| Find failed jobs in a repository | `blacksmith jobs list --repo owner/repo --conclusion failure --since 7d --format table`. Use the returned job ID with `blacksmith jobs logs 12345678` or `blacksmith jobs stats 12345678`. [Jobs](https://docs.blacksmith.sh/blacksmith-cli/jobs.md) |
| Search across CI logs | `blacksmith logs search --query 'level:error repo:owner/repo "connection refused"' --since 24h`. [Logs](https://docs.blacksmith.sh/blacksmith-cli/logs.md) |
| Report compute usage and estimated cost | `blacksmith usage --since 30d --breakdown-by runner_type,repo --format table`. Use `usage storage` for storage and `runners catalog` for runner SKUs. [Usage](https://docs.blacksmith.sh/blacksmith-cli/usage.md) |
| Inspect Actions or Bazel cache entries | `blacksmith cache list --repo owner/repo --format table`. [Cache](https://docs.blacksmith.sh/blacksmith-cli/cache.md) |
| Inspect sticky disks | `blacksmith stickydisk list --repo owner/repo --format table`. [Sticky disks](https://docs.blacksmith.sh/blacksmith-cli/stickydisk.md) |

For CI triage, report the matching job ID, the relevant step or error, and what the logs or metrics show. For usage reports, include the organization, date range, and units. The CLI's estimated cost uses list prices.

For a requested Actions cache deletion, identify the target entries in the listing. `blacksmith cache delete --key <key>` matches every scope, version, and transparent-cache variant of that key by default. Use `--scope` (`null` for unscoped entries), `--version`, and `--transparent-cache` (`true` or `false`) as needed to target the requested entries. `blacksmith cache clear` removes all Actions cache entries for the repository.

For a requested sticky disk deletion, identify the key and architecture in the listing. `blacksmith stickydisk delete --key <key>` matches all architectures for that key. Pass `--arch` to target a single architecture.

## Run tests in a Testbox

Read the [Testbox command guide](https://docs.blacksmith.sh/blacksmith-cli/testbox.md) for setup, sync behavior, and flags. Testboxes require a configured workflow in the target repository. `blacksmith testbox init` is interactive and writes workflow and skill files, so use it when the user asks to set up Testboxes.

1. In the intended checkout, run `blacksmith testbox warmup blacksmith-testbox.yml` with the actual workflow filename. Pass `--ref` explicitly when the setup must come from a specific remote ref, and use `--job` to select a job in a multi-job workflow. Warmup dispatches a GitHub Actions run and returns a Testbox ID. The dispatched workflow sets up the environment and services once. Subsequent local file sync keeps that setup in place.
2. Verify the checkout contains the changes intended for remote sync. Run `blacksmith testbox run --id "$testbox_id" 'npm test'` with the returned ID and the repository's real test command. The command waits for readiness, mirrors local changes via rsync, and returns the remote exit code. Files deleted locally are removed from the remote mirror.
3. Report the Testbox ID and test result. Stop the Testbox you created when finished with `blacksmith testbox stop --id "$testbox_id"`. Stopping it cancels its underlying Actions run. Keep it running if the user asked to reuse it.
