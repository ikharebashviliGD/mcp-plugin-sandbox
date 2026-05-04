# mcp-plugin-sandbox

Sandbox plugin for testing the **Claude Code plugin auto-update flow** end-to-end.

Bundles:

- `XcodeBuildMCP` MCP server registration (via `npx -y xcodebuildmcp@latest mcp`)
- `list-simulators` skill — instructs the agent to use `XcodeBuildMCP`'s `list_sims` tool when asked about iOS simulators
- `list-devices` skill — instructs the agent to use `XcodeBuildMCP`'s `list_devices` tool when asked about connected physical iOS devices
- `list-schemes` skill — instructs the agent to use `XcodeBuildMCP`'s `list_schemes` tool when asked about Xcode build schemes
- `discover-projects` skill — instructs the agent to use `XcodeBuildMCP`'s `discover_projs` tool when asked to find Xcode projects/workspaces in a directory
- `SessionStart` hook — refreshes the local marketplace catalog at session start so Claude Code's auto-update can see new plugin versions (workaround for [#35752](https://github.com/anthropics/claude-code/issues/35752))

## Layout

```
mcp-plugin-sandbox/
├── .claude-plugin/
│   ├── plugin.json          # plugin manifest (name, version)
│   └── marketplace.json     # marketplace entry, allows install via /plugin marketplace add
├── .mcp.json                # MCP server registration (XcodeBuildMCP)
├── skills/
│   ├── list-simulators/
│   │   └── SKILL.md         # auto-activates on simulator-related queries
│   ├── list-devices/
│   │   └── SKILL.md         # auto-activates on physical-device queries
│   ├── list-schemes/
│   │   └── SKILL.md         # auto-activates on Xcode-scheme queries
│   └── discover-projects/
│       └── SKILL.md         # auto-activates on Xcode-project discovery queries
├── hooks/
│   └── hooks.json           # registers the SessionStart hook
├── scripts/
│   └── refresh-marketplace.sh  # invoked by the SessionStart hook
└── README.md
```

## Install in Claude Code

```
/plugin marketplace add ikharebashviliGD/mcp-plugin-sandbox
/plugin install mcp-plugin-sandbox@mcp-plugin-sandbox
```

After install, restart the Claude Code session. The MCP server should appear under enabled servers, and the skill becomes auto-activatable.

## Verifying the install

Ask Claude:

> Which iOS simulators are currently running on my machine?

Expected behavior:

1. Reply starts with the marker `[skill:list-simulators v1]` (proves the skill loaded and activated).
2. Tool calls go through `XcodeBuildMCP.list_sims` (proves the MCP server is registered and reachable).

## Auto-update test

| Stage | Version | What changed |
|---|---|---|
| 1 | `0.1.0` | Initial plugin with `list-simulators` skill |
| 2 | `0.2.0` | Added `list-devices` skill |
| 3 | `0.3.0` | Added `list-schemes` skill |
| 4 | `0.4.0` | Added `discover-projects` skill |
| 5 | `0.5.0` | Added `SessionStart` hook that auto-refreshes the marketplace catalog |
| 6 | `0.6.0` | Version bump only — used to verify zero-touch auto-update; revealed that the original hook only refreshed the catalog but did not apply plugin updates |
| 7 | `0.7.0` | SessionStart hook extended to also call `claude plugin update` after marketplace refresh — full two-step pipeline for real zero-touch updates |
| 8 | `0.8.0` | Pure version bump — first verification that the two-step hook delivers actual zero-touch updates (no manual `/plugin update` required) |
| 9 | `0.9.0` | Pure version bump — second verification that zero-touch updates are stable across multiple cycles |
| 10 | `0.10.0` | Added `userConfig` block (`evinced_service_account_id`, `evinced_access_token`) and a second MCP server registration (`evinced-mobile-mcp`) that pulls those values into env via `${user_config.*}` substitution |

To verify auto-update worked after a new version ships:

1. Restart the Claude Code session (or run `/reload-plugins`).
2. Prompt the agent with a query that triggers the latest added skill, for example:
   - Stage 2: *"Which physical iOS devices are connected to my machine?"* → expect `[skill:list-devices v1]`
   - Stage 3: *"Which Xcode schemes are available in this project?"* → expect `[skill:list-schemes v1]`
   - Stage 4: *"Find all Xcode projects under this directory."* → expect `[skill:discover-projects v1]`
3. If you instead get a generic answer or a shell-based call, the new skill has not been picked up — auto-update failed and manual `/plugin update mcp-plugin-sandbox` is needed.

Note: Claude Code requires auto-update to be **toggled on per-marketplace** in the `/plugin` TUI. Without it, `/plugin update <plugin>` must be run manually to fetch new versions.

## Verifying the SessionStart hook

After installing `0.5.0` (or later), the hook fires on every session start. To verify:

1. Start a new Claude Code session.
2. Inspect the hook log:
   ```bash
   tail -n 20 /tmp/mcp-plugin-sandbox-hook.log
   ```
   You should see a `[hook:session-start fired]` line and the output of `claude plugin marketplace update mcp-plugin-sandbox`.

The hook is also what makes the **next** plugin update truly zero-touch: when a future version is published, the hook refreshes the catalog at startup, and Claude Code's built-in auto-update applies the new version on the session after that — without any manual `/plugin marketplace update`.
