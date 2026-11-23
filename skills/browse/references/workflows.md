# Browser workflows

## CLI workflow

Run these as separate commands. Substitute the tab ID returned by `navigate` for `<tab-id>`.

```text
browse navigate https://example.com/
browse snapshot --tab <tab-id>
browse tabs close --tab <tab-id>
```

Use `browse click <ref> --tab <tab-id>` or `browse fill <ref> <value> --tab <tab-id>` with a ref from that tab's current snapshot. `browse execute --file script.js --tab <tab-id>` avoids shell-specific quoting for longer scripts. The CLI also supports `--json` for structured arguments. Use `browse <tool> --help` to confirm option names for the installed release.

## Frames, dialogs, and handoffs

- Use the iframe refs from the snapshot or a scoped `frameLocator`. If a selector finds many elements, narrow it before clicking.
- For a native JavaScript dialog, use Browse's `dialog` tool to inspect and respond explicitly. For a DOM modal, scope selectors to the modal.
- Open a handoff before triggering an interaction that waits for the user's input. In `execute`, use `start: () => ref("e12").click()` with the actual ref. The execution timeout pauses during the handoff. If it times out, is cancelled, or the tab closes, check current state before resuming.
- Use `demonstrate` when the user wants to show a workflow. Treat the recording as input for understanding the flow. Replaying any action with external effects requires its own authorization.

## Images, recordings, and files

- Return `await page.screenshot()` from `execute` to inspect an inline image. To deliver an artifact, save with `browse.screenshot({ path: "result.png" })` and use the returned path. Use full-page capture only when needed. It can briefly resize the viewport on long pages. For visual-only controls, `screenshotWithLabels()` maps visible controls to selectors and rectangles.
- Save artifacts to a Browse file root. A relative path resolves to a private Browse location on the relay machine. Use `files.roots` to inspect the available roots and `files.path(name)` when you need a relay-local path. On a remote relay, verify how the user's client can access the result.
- For video, use `browse.recording({ action: "start", path: "flow.webm", maxDurationMs: 60000 })` on the target tab, perform the scoped flow, and use `action: "stop"` to finalize and retrieve the path. Use `cancel` to discard a failed take. WebM and MP4 transcoding require FFmpeg on the relay. MKV is available for capture without transcoding. Verify the output before handing it back.
- For uploads, target the file input or its label with `setInputFiles` or the `upload` tool. Use files the user intended to submit, from Browse's allowed roots. Distinguish selecting the file from submitting the form and verify each required step. On remote configurations, path inputs refer to the relay and copies are bounded by the tool's limits. Check the live schema for inline file support and the upstream documentation for large same-machine uploads.

## Diagnose page behavior

- Start `pageConsole` capture or `network` capture before triggering the behavior. Read console events with `pageConsole.read()` and stop capture when finished.
- For network diagnostics, use `network.start({ urlFilter: "/api/", bodies: false })` and narrow further by methods or resource types where possible. Reproduce the permitted interaction once, then use `network.stop()`. Use `network.cancel()` when the result is unnecessary. Return only the fields needed for the task. Captures can still include private application data even with credential redaction.
- When the page is hidden and pauses work, consider `keepVisible` on a task-owned tab. For a slow page, wait on a concrete state with a bounded timeout. Keep tab cleanup tied to ownership even if the task ends with an error.

See the [upstream tool guide](https://github.com/anomalyco/browse#tools) and the installed tool help for version-specific details.
