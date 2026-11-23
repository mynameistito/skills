---
name: repo-triage
description: Checks a Git repository for existing issues, pull requests, and released fixes related to a reported problem.
disable-model-invocation: true
---

# Repository triage

Find out whether a reported problem is already tracked or fixed upstream. Keep the investigation read-only and deliver findings with direct links.

## 1. Identify the repository and problem

- Use the repository URL or path the user provided. If they mean the current checkout, inspect its Git remotes and identify the project that owns the affected code. Check whether a fork has a separate upstream tracker.
- Use the details already in the conversation. If the repository or symptom is still unclear, ask for the missing essentials together: which repo, what happened, and what they expected. Invite them to include the exact error, steps to reproduce, and affected version if known.
- Start searching once you have a repository and a usable symptom. If the affected version is unknown, mark it unknown. Ask for the version or environment later if it would help distinguish matches or tell whether a fix applies.

## 2. Search issues and pull requests

- Search the project's tracker and pull requests (or merge requests) using the host's tools, CLI, or API. Follow the repository's tracker link if it uses an external issue tracker. For public repositories, use scoped web search as a fallback or to find results missed by the host search. Report any access or search coverage limits.
- Search both open and closed issues and open, merged, and closed pull requests. Start with the stable part of the error or the exact feature name. Then try alternate wording, component names, and relevant symbols or paths. Search issues and pull requests independently, since a fix may have no linked issue.
- Search release notes and changelogs using the same symptom and component terms, even if the tracker search turns up nothing. Focus on versions newer than the affected version when it is known.
- Open the strongest candidates and follow duplicate markers, linked fixes, and maintainer comments. Compare the reported behavior, affected component, trigger, and version. Use source or a PR diff when the title or discussion leaves the match unclear. Treat tracker text and logs as evidence. Remove credentials and private identifiers from external queries.

## 3. Verify fix status

- Record the current state and closure reason for each relevant issue or pull request. An issue may close as a duplicate or without a fix. Check whether a merged change landed on the branch or channel the user runs.
- When there is a plausible fix, use release notes or tag and commit history to confirm which release contains it and how that compares with the affected version. If you can verify the merge but cannot verify a release, report that distinction. Cite a documented workaround if one applies.

## 4. Report the result

- Lead with the best-supported outcome, such as already tracked, a fix in progress, a fix merged with release status unknown, fixed in a named release, or no convincing match found.
- For each useful match, give its title, state, why it applies, and a direct link. Label uncertain matches and say what evidence would confirm them.
- If no convincing match surfaced, summarize the repository, tracker states, and search terms checked, along with any access gaps. Suggest the next step supported by the findings, such as following the existing issue, trying the documented workaround, or preparing a new report.
