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

1. Read MCP `status` or `browse status --json`, using both when available to compare the relay endpoint and instance. `paired-offline` indicates a saved pairing and no connected browser. Use `browse pair --list` to check whether the requested profile has a saved pairing. The extension toggle only shows whether the extension is enabled.
2. Open the requested browser’s paired profile if it is closed. Use an authorized desktop UI tool to open Browse’s Details in `chrome://extensions` and select **Extension options**. If desktop UI access is unavailable, ask the user for the relay address and connection status shown in Browse Settings. Compare that address with the endpoint from each available status interface.
3. Use the interface that reaches the relay shown in Browse Settings. If neither interface reaches that relay and the settings show a different local port, use a temporary CLI override to check that port. In PowerShell, set `$env:OPENCODE_BROWSER_PORT = '19990'` in a separate shell and run `browse status --json`, substituting the port shown in settings. If status lists the requested browser as connected, resume with that interface and select the browser when opening a tab. Keep the working pairing. A relay can listen on a fallback port and still store saved tabs under its original configured port. Use the temporary override for the live relay and check the relay’s original launch configuration before changing an MCP registration or performing a restart.
4. If the requested browser is offline on the selected relay, use **Advanced** → **Reconnect** in Browse Settings where available. Use the desktop UI or ask the user to click it, then check status on that same relay. If the browser remains offline and a restart is authorized, use the relay’s original launch environment and executable to confirm the intended endpoint and instance have no connected browsers or active targets. Run `browse restart` once from that same environment. If the launch environment is unknown, continue with diagnostics. A `reconnecting` reply immediately after restart is provisional. Confirm `connected: true` and the requested browser in the browser list, then open a task tab and verify a page read.
5. If the browser is still offline, use the extension’s connection status or a redacted connection error to distinguish conflicts, version mismatches, and unpaired profiles. Keep tokens, pairing codes, and raw diagnostics out of logs and chat.

## Install when requested

Use the [upstream install instructions](https://github.com/anomalyco/browse#install) for platform-specific commands. Check `browse --help` for the local version's flags. Register just the requested client with `browse install --agent codex` or its corresponding agent flag. For a manual stdio configuration use the absolute executable path and the `mcp` argument. Reload the client before testing the new MCP registration. Separately install the official extension in the intended Chromium profile and pair it with the relay.

Use `browse pair --list` to inspect pairing records. Keep pairing codes, relay tokens, and profile credentials out of logs and chat. For remote pairing, follow [upstream's remote setup](https://github.com/anomalyco/browse#browser-on-another-computer) only when requested. Use a private encrypted network and verify which machine runs the relay. Browse's extension connection does not provide transport encryption itself.

Verify the registration with the client's tools, then check `status` for a connected browser. If a browser smoke test is in scope, open `https://example.com/` in a fresh tab, verify the heading, and close that tab. A successful installation and an online browser are separate checks.
