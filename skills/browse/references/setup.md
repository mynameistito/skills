# Setup and troubleshooting

## Identify the failing layer

| Observation | Next check |
| --- | --- |
| Browse tools are missing | Check `browse --version` and whether the current agent has a Browse stdio registration. After adding a registration, reload MCP or restart the client. |
| CLI works, but MCP is missing | Check that this client launches the same executable with argument `mcp`. Use the absolute path if the client's PATH differs from the terminal's. |
| Browse connects to the relay but the browser is offline | Read `status` or `browse status --json` and follow `nextStep`. Open the paired profile and check that the extension is enabled. An offline paired browser normally reconnects automatically. |
| Browser has never paired | Use Browse's setup page or `browse pair` for the intended profile. Manual pairing requires entering the one-time code in the extension. |
| Multiple browsers are connected | Choose the user's intended browser from `status` and set `browser` when creating the tab. |
| A tab or ref stopped resolving | Check `tabs` for the tab, then take a fresh snapshot. Idle tabs can close. A browser restart invalidates the old tab IDs. |

## Install when requested

Use the [upstream install instructions](https://github.com/anomalyco/browse#install) for platform-specific commands. Check `browse --help` for the local version's flags. Register just the requested client with `browse install --agent codex` or its corresponding agent flag. For a manual stdio configuration use the absolute executable path and the `mcp` argument. Reload the client before testing the new MCP registration. Separately install the official extension in the intended Chromium profile and pair it with the relay.

Use `browse pair --list` to inspect pairing records. Keep pairing codes, relay tokens, and profile credentials out of logs and chat. For remote pairing, follow [upstream's remote setup](https://github.com/anomalyco/browse#browser-on-another-computer) only when requested. Use a private encrypted network and verify which machine runs the relay. Browse's extension connection does not provide transport encryption itself.

Verify the registration with the client's tools, then check `status` for a connected browser. If a browser smoke test is in scope, open `https://example.com/` in a fresh tab, verify the heading, and close that tab. A successful installation and an online browser are separate checks.
