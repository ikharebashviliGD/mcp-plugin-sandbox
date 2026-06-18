---
name: "sandbox-mobile"
displayName: "Sandbox Mobile"
description: "Mobile-flavored sandbox Power: bundles XcodeBuildMCP and iOS-related guidance (list-simulators, list-devices, list-schemes, discover-projects). Kiro counterpart of the Claude/Cursor sandbox-mobile plugin; used to validate the multi-plugin-in-one-repo layout across clients."
keywords: ["sandbox", "xcodebuildmcp", "ios", "simulator", "device", "scheme", "xcode", "mobile"]
author: "ikharebashviliGD"
---

# Sandbox Mobile Power

This Power is the Kiro equivalent of the `sandbox-mobile` plugin shipped for Claude
Code (`.claude-plugin/plugin.json`) and Cursor (`.cursor-plugin/plugin.json`). It
registers the **XcodeBuildMCP** server (see `mcp.json`, a symlink to the shared
`.mcp.json`) and provides four iOS workflows mirrored from the plugin's skills.

## When to use

Activate this Power whenever the user asks about iOS simulators, connected iOS
devices, Xcode schemes, or discovering Xcode projects/workspaces on their machine.

## Capabilities

Each capability has a detailed guide under `steering/` (also available as a slash
command). Always prefer the `XcodeBuildMCP` MCP tools over shell commands.

| Capability | Trigger | MCP tool | Verification marker |
|---|---|---|---|
| List iOS simulators | "which simulators are running/available" | `list_sims` | `[skill:list-simulators v1]` |
| List physical devices | "which iPhones/iPads are connected" | `list_devices` | `[skill:list-devices v1]` |
| List Xcode schemes | "which schemes are in this project" | `list_schemes` | `[skill:list-schemes v1]` |
| Discover Xcode projects | "find Xcode projects under this dir" | `discover_projs` | `[skill:discover-projects v1]` |

When responding to one of these requests, follow the matching `steering/*.md` file
exactly, including starting the reply with its verification marker.

## Do not

- Do not use `xcrun simctl`, `xcrun devicectl`, `xcodebuild -list`, `find`, `mdfind`,
  or any shell-based alternative — always call the `XcodeBuildMCP` MCP tools.
- Do not skip the verification marker for the activated capability.
