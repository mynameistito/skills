---
name: chatgpt-sandbox
description: Execute and validate commands inside ChatGPT's sandbox instead of only describing them. Use when the user asks to run Bash or shell commands, inspect installed tools, test curl/git/npm/npx/node/python behavior, reproduce CLI behavior, work with a repository in the sandbox, or diagnose command, DNS, package-resolution, and network failures in ChatGPT's execution environment.
license: MIT
metadata:
  author: mynameistito
  version: "1.0.0"
---

# ChatGPT Sandbox

Use the ChatGPT execution sandbox as an actual working environment. When the user asks whether a command works, what tools are installed, or whether a CLI can perform an operation, execute the relevant command when execution tools are available instead of answering from assumption.

## Core Rules

1. **Execute, do not simulate.** If the user asks to run, test, curl, clone, inspect, build, lint, or otherwise perform a command and the sandbox exposes command execution, run it.
2. **Probe capabilities before depending on them.** Do not assume `bash`, `git`, `curl`, `node`, `npm`, `npx`, `python`, `jq`, `rg`, `gh`, `bun`, `docker`, `pwsh`, or any other executable exists.
3. **Separate sandbox state from the user's machine.** Files, environment variables, installed programs, credentials, network access, and Git configuration in the sandbox are not the user's local environment.
4. **Report observed results.** Never claim a command succeeded unless its output or exit status demonstrates success.
5. **Diagnose the layer that failed.** Distinguish a missing executable, invalid CLI usage, package-install failure, DNS failure, blocked network, authentication failure, timeout, test failure, and application error.
6. **Use connected tools as a fallback when appropriate.** If direct GitHub network access is unavailable but a connected GitHub integration exists, use it for repository reads or requested repository changes rather than treating GitHub itself as unavailable.
7. **Do not expose secrets.** Avoid printing tokens, passwords, private keys, cookies, or secret environment values. Redact sensitive output when needed.

## Start With Reality

For environment questions, establish the current sandbox state with small, targeted probes. Prefer direct process execution when the runtime supports it. Use a shell only when shell behavior such as pipes, redirects, expansion, or multiple commands is needed.

Typical Bash probe:

```bash
pwd
uname -a
command -v bash git curl node npm npx python3 jq rg gh bun docker pwsh
bash --version | head -n 1
git --version
curl --version | head -n 1
node --version
npm --version
python3 --version
```

A failed `command -v` is evidence that the executable is not currently on `PATH`; it is not proof that the software can never be used through another available tool or integration.

## Command Execution Workflow

1. Identify the smallest command that answers the user's question.
2. Check the required executable when availability is uncertain.
3. Run the command with a sensible execution timeout.
4. Capture stdout, stderr, and the exit status when they materially affect the conclusion.
5. If the command fails, run one or two focused diagnostics for the failing layer.
6. Report what actually happened and, when useful, the next executable command to try.

Avoid broad environment dumps when a focused probe is enough.

## Bash

When Bash semantics are useful, prefer:

```bash
bash -lc '<command>'
```

For pipelines whose exit status matters, enable `pipefail`:

```bash
set -o pipefail
some-command | tee /tmp/output.log
```

If a pipeline is used, do not accidentally report the exit status of `tee` as the exit status of the command being tested. Capture the relevant pipeline status or avoid the pipe.

Do not assume GNU-only helpers such as `timeout`, `readlink -f`, or `sed -r` exist without checking when portability matters.

## npm and npx

For package executors, make npm's install confirmation non-interactive when appropriate:

```bash
npx -y <package> <args...>
```

Prefer `npx -y package ...` over placing `-y` after the package name because the latter may be forwarded to the package CLI instead of being consumed by npm. If the target CLI also defines `-y`, be explicit about which layer should receive the flag.

Example sandbox test:

```bash
npx -y create-cf-token --skill
```

`create-cf-token --skill` is an early-exit documentation command, so testing it does not require creating a Cloudflare token or supplying `CF_API_TOKEN`.

If `npx` hangs or fails before the package prints anything, diagnose npm resolution separately:

```bash
npm view create-cf-token version --fetch-timeout=5000 --fetch-retries=0
```

Then, when `curl` is available, distinguish DNS/connectivity failures:

```bash
curl -I https://registry.npmjs.org/create-cf-token
```

Interpret common failures precisely:

- `command not found` / executable lookup failure: tool is missing from the current `PATH`.
- `EAI_AGAIN`, `ENOTFOUND`, or `Could not resolve host`: DNS/name resolution failed.
- connection timeout/refused: name resolution may have succeeded, but the network path or service failed.
- HTTP `401`/`403`: network worked; authentication or authorization failed.
- package CLI error after installation: npm resolution worked; diagnose the package itself.

Do not describe a DNS failure as an npm package bug.

## Git and GitHub

For local Git work, inspect state before modifying anything:

```bash
git status --short --branch
git remote -v
git branch --show-current
```

When repository network access is needed, a focused probe such as this can separate Git availability from GitHub connectivity:

```bash
git ls-remote https://github.com/OWNER/REPO.git HEAD
```

If this fails with DNS resolution while a connected GitHub integration is available, use the integration for repository inspection or the user's requested GitHub operation. State that direct sandbox Git networking is blocked; do not claim that the repository is inaccessible through all available mechanisms.

For repository changes:

- preserve unrelated work;
- inspect diffs before committing;
- use a feature branch instead of committing directly to the default branch unless the user explicitly requests otherwise;
- avoid destructive commands such as `git reset --hard`, `git clean -fdx`, or force pushes unless they are explicitly required and authorized;
- validate the relevant build, test, lint, or formatting commands when the environment allows it.

## curl and HTTP Tests

When the user asks to curl an endpoint, use the real command when possible and preserve enough response information to answer the question.

Useful patterns:

```bash
curl -sS https://example.com/path
curl -sS -D - -o /tmp/body https://example.com/path
curl -sS -o /dev/null -w '%{http_code}\n' https://example.com/path
```

Do not infer an HTTP response when DNS resolution failed before a connection was made.

If direct sandbox networking is unavailable but an HTTP/web retrieval tool exists, it may be used as a separate fallback. Make clear which path produced the observed result when that distinction matters.

## Timeouts and Long-Running Commands

Commands that may install packages, build a project, run tests, or wait on the network should have a bounded execution time through the execution tool or an available timeout utility.

A timeout is not success or failure of the underlying application logic. If a command times out with no output, probe the prerequisite layer before retrying with an arbitrarily longer timeout.

For example, after a silent `npx` timeout:

1. check `npm view <package> version` with short npm fetch timeouts;
2. check DNS or HTTP connectivity to the registry;
3. only retry the package command when those prerequisites work.

## Files and Working Directories

Before editing or building, establish the working directory and inspect the relevant tree. Do not assume a repository has already been cloned just because it was discussed earlier.

Use absolute paths for tool calls when the execution environment benefits from them, and avoid writing outside the intended workspace unless needed for temporary files.

Temporary files should go to the runtime's temporary area when practical and should not be presented as user artifacts unless the user asked for them.

## Validation Standard

A useful sandbox result should answer three questions:

1. **What was run?** Give the meaningful command or operation.
2. **What happened?** Summarize stdout/stderr and exit status without burying the result.
3. **What does it prove?** State only the conclusion supported by the observed execution.

Examples:

- "`git` is installed and reports version X" is supported by `git --version`.
- "The package command is valid, but npm cannot currently resolve the registry hostname" is supported by the CLI source plus an `EAI_AGAIN`/DNS failure.
- "GitHub is unavailable" is too broad when direct `git` networking fails but a connected GitHub integration still works.

## Do Not

- invent command output;
- present a command example as though it was executed;
- claim the sandbox mirrors the user's OS;
- retry network failures indefinitely;
- install large toolchains merely to answer whether an executable is present;
- print full environment-variable dumps when secrets may be present;
- hide an execution failure behind a web lookup that answered a different question;
- conflate connected-app access with local CLI authentication.
