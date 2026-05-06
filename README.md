# mcp-plugin-sandbox

Sandbox **marketplace** that hosts **two sibling plugins** in a single git repository, used to validate the multi-plugin layout (one repo, multiple plugins) and per-plugin independent auto-update across clients.

| Plugin | Server | Skills | Purpose |
|---|---|---|---|
| `sandbox-mobile` | `XcodeBuildMCP` (`npx -y xcodebuildmcp@latest mcp`) | `list-simulators`, `list-devices`, `list-schemes`, `discover-projects` | Stand-in for a "mobile" product plugin |
| `sandbox-web` | `Playwright MCP` (`npx -y @playwright/mcp@latest`) | `page-snapshot`, `screenshot-page` | Stand-in for a "web" product plugin |

Both plugins are **placeholders** — they intentionally do **not** use Evinced servers. The goal is to test the marketplace mechanics (install only one, version-bump only one, auto-update only one) with two real, independently maintained MCPs.

## Layout

```
mcp-plugin-sandbox/
├── .claude-plugin/
│   └── marketplace.json              # catalog: lists both plugins via subdir source
├── plugins/
│   ├── mobile/                       # sandbox-mobile @ 0.1.0
│   │   ├── .claude-plugin/plugin.json
│   │   ├── .mcp.json                 # XcodeBuildMCP
│   │   ├── hooks/hooks.json          # SessionStart hook
│   │   ├── scripts/refresh-marketplace.sh
│   │   └── skills/
│   │       ├── list-simulators/SKILL.md
│   │       ├── list-devices/SKILL.md
│   │       ├── list-schemes/SKILL.md
│   │       └── discover-projects/SKILL.md
│   └── web/                          # sandbox-web @ 0.1.0
│       ├── .claude-plugin/plugin.json
│       ├── .mcp.json                 # Playwright MCP
│       ├── hooks/hooks.json          # SessionStart hook
│       ├── scripts/refresh-marketplace.sh
│       └── skills/
│           ├── page-snapshot/SKILL.md
│           └── screenshot-page/SKILL.md
└── README.md
```

Key design points:

- **One marketplace, two plugins.** The marketplace catalog at the repo root references each plugin via a relative `source` path (`./plugins/mobile`, `./plugins/web`).
- **Each plugin is self-contained.** Its own `plugin.json`, MCP registration, hooks, and skills live under its subdirectory. Nothing is shared at runtime.
- **Each plugin owns its own SessionStart hook.** Both hooks refresh the same marketplace, but each only updates its own plugin (`sandbox-mobile@…` or `sandbox-web@…`). This means you can install one without the other, and version bumps are fully independent.

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

Cursor's `/add-plugin` command works only with plugins published to the Cursor Marketplace — it does **not** accept arbitrary git URLs. To test this sandbox in Cursor without going through marketplace submission, use the local-clone path:

```bash
mkdir -p ~/.cursor/plugins/local
cd ~/.cursor/plugins/local
git clone https://github.com/ikharebashviliGD/mcp-plugin-sandbox.git
```

Cursor reads `~/.cursor/plugins/local/<plugin>/` as a plugin root. For a multi-plugin repo, you may need to symlink each subdirectory in as its own plugin folder:

```bash
cd ~/.cursor/plugins/local
ln -s mcp-plugin-sandbox/plugins/mobile sandbox-mobile
ln -s mcp-plugin-sandbox/plugins/web sandbox-web
```

Restart Cursor. Both plugins should appear in the Plugins panel and can be enabled independently. (This is exactly what we want to verify: that Cursor treats subdirectory plugins as fully separate.)

## What this sandbox is meant to validate

| # | Question | How to verify |
|---|---|---|
| 1 | Can a single git repo host **two independent plugins** that show up as separate entries in the marketplace? | After `/plugin marketplace add`, `/plugin` TUI lists both `sandbox-mobile` and `sandbox-web`. |
| 2 | Can the user install **only one** of them? | Install `sandbox-mobile` only. Verify that Playwright MCP is NOT registered and that web skills do NOT appear in skill discovery. |
| 3 | Are plugin versions tracked **independently**? | Bump `plugins/mobile/.claude-plugin/plugin.json` to `0.2.0`, leave web at `0.1.0`. After session restart + auto-update, only mobile cache directory should advance to `0.2.0`. Web cache stays at `0.1.0`. |
| 4 | Does the SessionStart hook of one plugin trigger updates for the **other**? (It should NOT.) | After installing both plugins, bump only mobile's version. Inspect `/tmp/sandbox-mobile-hook.log` and `/tmp/sandbox-web-hook.log` — only mobile's update should report a version change. |
| 5 | Does Cursor handle the same multi-plugin layout? | Per the Cursor install steps above — both plugins should appear and be independently toggleable. |

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
