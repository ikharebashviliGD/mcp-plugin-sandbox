# mcp-plugin-sandbox

Sandbox **marketplace** that hosts **two sibling plugins** in a single git repository, used to validate the multi-plugin layout (one repo, multiple plugins) and per-plugin independent auto-update across clients. Ships per-client manifests for **Claude Code** and **Cursor** from the same source tree.

| Plugin | Server | Skills | Purpose |
|---|---|---|---|
| `sandbox-mobile` | `XcodeBuildMCP` (`npx -y xcodebuildmcp@latest mcp`) | `list-simulators`, `list-devices`, `list-schemes`, `discover-projects` | Stand-in for a "mobile" product plugin |
| `sandbox-web` | `Playwright MCP` (`npx -y @playwright/mcp@latest`) | `page-snapshot`, `screenshot-page` | Stand-in for a "web" product plugin |

Both plugins are **placeholders** — they intentionally do **not** use Evinced servers. The goal is to test the marketplace mechanics (install only one, version-bump only one, auto-update only one) with two real, independently maintained MCPs.

## Layout

```
mcp-plugin-sandbox/
├── .claude-plugin/
│   └── marketplace.json              # Claude catalog: lists both plugins
├── .cursor-plugin/
│   └── marketplace.json              # Cursor catalog: same listing, Cursor schema
├── plugins/
│   ├── mobile/                       # sandbox-mobile @ 0.1.0
│   │   ├── .claude-plugin/plugin.json    # Claude manifest
│   │   ├── .cursor-plugin/plugin.json    # Cursor manifest (points mcpServers → ./.mcp.json)
│   │   ├── .mcp.json                     # XcodeBuildMCP — shared by both clients
│   │   ├── hooks/hooks.json              # SessionStart hook (Claude only)
│   │   ├── scripts/refresh-marketplace.sh
│   │   └── skills/                       # SKILL.md format is identical for Claude and Cursor
│   │       ├── list-simulators/SKILL.md
│   │       ├── list-devices/SKILL.md
│   │       ├── list-schemes/SKILL.md
│   │       └── discover-projects/SKILL.md
│   └── web/                          # sandbox-web @ 0.1.0
│       ├── .claude-plugin/plugin.json
│       ├── .cursor-plugin/plugin.json
│       ├── .mcp.json                     # Playwright MCP — shared
│       ├── hooks/hooks.json              # SessionStart hook (Claude only)
│       ├── scripts/refresh-marketplace.sh
│       └── skills/
│           ├── page-snapshot/SKILL.md
│           └── screenshot-page/SKILL.md
└── README.md
```

Key design points:

- **One repo, two plugins, two clients.** Each plugin ships side-by-side manifests for Claude Code (`.claude-plugin/plugin.json`) and Cursor (`.cursor-plugin/plugin.json`) from the same source tree. Skills and `.mcp.json` are written once and reused by both clients.
- **MCP config is not duplicated.** Claude reads `.mcp.json` automatically; Cursor's manifest points `mcpServers` at the same `./.mcp.json` file.
- **Per-client marketplaces sit at the repo root.** `.claude-plugin/marketplace.json` and `.cursor-plugin/marketplace.json` list the same two plugins via subdir `source` paths.
- **Each plugin is self-contained.** Manifests, MCP registration, hooks, and skills live under the plugin's subdirectory. Nothing is shared between mobile and web at runtime.
- **Each plugin owns its own SessionStart hook (Claude only).** Both hooks refresh the same marketplace, but each only updates its own plugin (`sandbox-mobile@…` or `sandbox-web@…`). This keeps version bumps fully independent. Cursor relies on its own built-in plugin auto-update and does not need a hook for this.

## Install in Claude Code

Add the marketplace once:

```
/plugin marketplace add ikharebashviliGD/mcp-plugin-sandbox
```

Then install **only what you need**:

```
# Just mobile
/plugin install sandbox-mobile@mcp-plugin-sandbox

# Or just web
/plugin install sandbox-web@mcp-plugin-sandbox

# Or both
/plugin install sandbox-mobile@mcp-plugin-sandbox
/plugin install sandbox-web@mcp-plugin-sandbox
```

After install, restart the Claude Code session. Each installed plugin's MCP server should appear under enabled servers, and its skills become auto-activatable.

## Install in Cursor

Cursor's `/add-plugin <name>` slash command only resolves names from the Cursor Marketplace — it does not accept arbitrary git URLs. While this sandbox is not published to the official marketplace, it can be loaded via Cursor's local-plugin path:

```bash
mkdir -p ~/.cursor/plugins/local
cd ~/.cursor/plugins/local
git clone https://github.com/ikharebashviliGD/mcp-plugin-sandbox.git
```

Because the repository root contains `.cursor-plugin/marketplace.json`, Cursor discovers it as a multi-plugin source and registers both `sandbox-mobile` and `sandbox-web` from their respective `plugins/<name>/.cursor-plugin/plugin.json` manifests.

Restart Cursor. Both plugins should appear in the Plugins panel and can be enabled independently. Their MCP servers are picked up from `plugins/<name>/.mcp.json` (referenced via `mcpServers` in the Cursor manifest), and skills under `plugins/<name>/skills/` are auto-discovered.

To verify that subdirectory plugins are treated as fully separate, enable only `sandbox-mobile` and confirm that Playwright MCP and the web skills do not appear.

## What this sandbox is meant to validate

| # | Question | How to verify |
|---|---|---|
| 1 | Can a single git repo host **two independent plugins** that show up as separate entries in the marketplace? | After `/plugin marketplace add`, `/plugin` TUI lists both `sandbox-mobile` and `sandbox-web`. |
| 2 | Can the user install **only one** of them? | Install `sandbox-mobile` only. Verify that Playwright MCP is NOT registered and that web skills do NOT appear in skill discovery. |
| 3 | Are plugin versions tracked **independently**? | Bump `plugins/mobile/.claude-plugin/plugin.json` to `0.2.0`, leave web at `0.1.0`. After session restart + auto-update, only mobile cache directory should advance to `0.2.0`. Web cache stays at `0.1.0`. |
| 4 | Does the SessionStart hook of one plugin trigger updates for the **other**? (It should NOT.) | After installing both plugins, bump only mobile's version. Inspect `/tmp/sandbox-mobile-hook.log` and `/tmp/sandbox-web-hook.log` — only mobile's update should report a version change. |
| 5 | Does Cursor handle the same multi-plugin layout? | After local-clone install, the Plugins panel should list both plugins as separate entries. Toggling one should not affect the other's MCP server or skills. |
| 6 | Does the same source tree serve both Claude Code and Cursor without duplication? | `.mcp.json` and `skills/` are written once. Cursor's manifest references the same `.mcp.json` via `mcpServers`. Both clients see the same MCP server and skills with no copy/paste. |

## Verification queries

After installing a plugin, prompt the agent with a query that triggers one of its skills:

### sandbox-mobile

| Skill | Query | Expected marker |
|---|---|---|
| `list-simulators` | "Which iOS simulators are currently running on my machine?" | `[skill:list-simulators v1]` |
| `list-devices` | "Which physical iOS devices are connected to my machine?" | `[skill:list-devices v1]` |
| `list-schemes` | "Which Xcode schemes are available in this project?" | `[skill:list-schemes v1]` |
| `discover-projects` | "Find all Xcode projects under this directory." | `[skill:discover-projects v1]` |

### sandbox-web

| Skill | Query | Expected marker |
|---|---|---|
| `page-snapshot` | "What's on the page I just opened?" (after navigating in Playwright) | `[skill:page-snapshot v1]` |
| `screenshot-page` | "Take a screenshot of the current page." | `[skill:screenshot-page v1]` |

If you instead get a generic answer or a shell-based call, the plugin's skill has not been picked up — auto-update or skill discovery failed.

## Auto-update test plan

Each plugin tracks its own version. To verify zero-touch independent updates:

1. Install both plugins. Confirm cache layout:
   ```bash
   ls ~/.claude/plugins/cache/mcp-plugin-sandbox/
   # Expect: sandbox-mobile/0.1.0/  sandbox-web/0.1.0/
   ```
2. Bump only `plugins/mobile/.claude-plugin/plugin.json` to `0.2.0`, commit, push.
3. Restart Claude Code. Hook fires, marketplace refreshes, mobile updates.
4. Recheck cache:
   ```bash
   ls ~/.claude/plugins/cache/mcp-plugin-sandbox/
   # Expect: sandbox-mobile/0.2.0/  sandbox-web/0.1.0/   ← web untouched
   ```
5. Inspect logs:
   ```bash
   tail -n 20 /tmp/sandbox-mobile-hook.log   # should report update applied
   tail -n 20 /tmp/sandbox-web-hook.log      # should report no update
   ```

The same pattern works in reverse — bump only `plugins/web/.claude-plugin/plugin.json` and verify `sandbox-mobile` stays at its version.

## Note on the previous mcp-plugin-sandbox version

This repo previously published a single `mcp-plugin-sandbox` plugin (with Evinced `userConfig`, XcodeBuildMCP, and four iOS skills) at versions `0.1.0`–`0.10.0`. That single-plugin layout is **gone**. After pulling the new structure, customers who installed the old plugin will see it orphaned and should uninstall it manually:

```
/plugin uninstall mcp-plugin-sandbox@mcp-plugin-sandbox
```

The two new plugins (`sandbox-mobile`, `sandbox-web`) are fresh installs, both starting at `0.1.0`.
