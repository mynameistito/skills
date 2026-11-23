# Setup and troubleshooting

## Identify the failing layer

| Observation | Next check |
| --- | --- |
| Browse tools are missing | Check `browse --version` and whether the current agent has a Browse stdio registration. After adding a registration, reload MCP or restart the client. |
| CLI works, but MCP is missing | Check that this client launches the same executable with argument `mcp`. Use the absolute path if the client's PATH differs from the terminal's. |
| Browse connects to the relay but the browser is offline | Follow [Recover a paired browser](#recover-a-paired-browser). |
| Browser has never paired | Use Browse's setup page in the intended profile. For manual pairing, have the user run `browse pair` in their own terminal and enter the one-time code directly in the extension. |
| Multiple browsers are connected | Choose the user's intended browser from `status` and set `browser` when creating the tab. |
| A tab or ref stopped resolving | Check `tabs` for the tab, then take a fresh snapshot. Idle tabs can close. A browser restart invalidates the old tab IDs. |

## Recover a paired browser

1. Read MCP `status` and, if the CLI is available, `browse status --json` and `browse pair --list`. Match the relay endpoint and instance, then identify the requested paired browser. If the CLI is connected and MCP is offline, troubleshoot the client’s relay registration before touching the browser pairing. `paired-offline` means a saved pairing exists and the relay has no active connection from that browser. The extension toggle only shows whether the extension is enabled.
2. Open the requested browser’s paired profile if it is closed. Use an authorized desktop UI tool to open Browse’s Details in `chrome://extensions` and select **Extension options**. If desktop UI access is unavailable, ask the user for the relay address and connection status shown in Browse Settings. Compare that address with the MCP endpoint.
3. If the settings show a different local port, check the existing relay on that port before restarting or re-pairing. For example, in PowerShell run `$env:OPENCODE_BROWSER_PORT = '19990'; browse status --json`, substituting the port shown in settings. If this lists the requested browser as connected, pass the same environment variable to each `browse` CLI call and select that browser when opening a tab. Keep the working pairing. A lasting MCP fix is to set `OPENCODE_BROWSER_PORT` in that client’s Browse MCP registration and reload it, if the user asks to change the registration.
4. If the configured relay matches and the browser is offline, use **Advanced** → **Reconnect** in Browse Settings where available. Use the desktop UI or ask the user to click it. If the browser remains offline and a restart is authorized, use `browse status --json` to confirm that the intended local relay has no connected browsers or active targets. Then run `browse restart` once using the same executable and environment as that status check. A `reconnecting` reply immediately after restart is provisional. Confirm `connected: true` and the requested browser in the browser list, then open a task tab and verify a page read.
5. If the browser is still offline, use the extension’s connection status or a redacted connection error to distinguish conflicts, version mismatches, and unpaired profiles. Keep tokens, pairing codes, and raw diagnostics out of logs and chat.

## Install when requested

Use the [upstream install instructions](https://github.com/anomalyco/browse#install) for platform-specific commands. Check `browse --help` for the local version's flags. Register just the requested client with `browse install --agent codex` or its corresponding agent flag. For a manual stdio configuration use the absolute executable path and the `mcp` argument. Reload the client before testing the new MCP registration. Separately install the official extension in the intended Chromium profile and pair it with the relay.

Use `browse pair --list` to inspect pairing records. Keep pairing codes, relay tokens, and profile credentials out of logs and chat. For remote pairing, follow [upstream's remote setup](https://github.com/anomalyco/browse#browser-on-another-computer) only when requested. Use a private encrypted network and verify which machine runs the relay. Browse's extension connection does not provide transport encryption itself.

Verify the registration with the client's tools, then check `status` for a connected browser. If a browser smoke test is in scope, open `https://example.com/` in a fresh tab, verify the heading, and close that tab. A successful installation and an online browser are separate checks.
