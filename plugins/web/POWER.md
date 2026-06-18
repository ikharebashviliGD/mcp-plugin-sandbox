---
name: "sandbox-web"
displayName: "Sandbox Web"
description: "Web-flavored sandbox Power: bundles Playwright MCP and browser-related guidance (page-snapshot, screenshot-page). Kiro counterpart of the Claude/Cursor sandbox-web plugin; sibling to sandbox-mobile, used to validate the multi-plugin-in-one-repo layout across clients."
keywords: ["sandbox", "playwright", "browser", "web", "snapshot", "screenshot", "accessibility", "page"]
author: "ikharebashviliGD"
---

# Sandbox Web Power

This Power is the Kiro equivalent of the `sandbox-web` plugin shipped for Claude
Code (`.claude-plugin/plugin.json`) and Cursor (`.cursor-plugin/plugin.json`). It
registers the **Playwright MCP** server (see `mcp.json`, a symlink to the shared
`.mcp.json`) and provides two browser workflows mirrored from the plugin's skills.

## When to use

Activate this Power whenever the user asks about the structure/content of a web page
they have open, an accessibility-tree snapshot, or a visual screenshot of a page.

## Capabilities

Each capability has a detailed guide under `steering/` (also available as a slash
command). Always prefer the `playwright` MCP tools over shell/HTTP utilities.

| Capability | Trigger | MCP tool | Verification marker |
|---|---|---|---|
| Page accessibility snapshot | "what's on this page / its structure" | `browser_snapshot` | `[skill:page-snapshot v1]` |
| Visual screenshot | "take a screenshot of this page" | `browser_take_screenshot` | `[skill:screenshot-page v1]` |

If no page has been navigated to yet, ask the user for the target URL and call
`browser_navigate` first. When responding, follow the matching `steering/*.md` file
exactly, including starting the reply with its verification marker.

## Do not

- Do not use `curl`, `wget`, `fetch`, `screencapture`, `osascript`, or any non-Playwright
  shell/HTTP tool — always call the `playwright` MCP tools.
- Do not skip the verification marker for the activated capability.
