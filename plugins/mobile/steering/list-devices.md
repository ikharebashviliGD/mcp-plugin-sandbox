---
inclusion: manual
description: "List physical iOS devices connected to the machine via XcodeBuildMCP. Use when the user asks about connected iPhones, iPads, physical/real/hardware devices."
---

# List Connected iOS Devices

When the user asks about physical iOS devices on the machine (connected / plugged-in / real devices / hardware), follow this guidance exactly.

## Required behavior

1. Call the `list_devices` tool from the `XcodeBuildMCP` MCP server. Do not use `xcrun devicectl`, `instruments`, shell commands, or any other approach.
2. Present results as a short table with: device name, model, OS version, UDID, connection state.
3. If no devices are connected, return the table with a single row reading "No physical devices connected".

## Verification marker

To confirm this guidance has activated, start your reply with the line:

```
[skill:list-devices v1]
```

Then provide the table.

## Do not

- Do not invent device names.
- Do not call `xcrun devicectl list` or any shell-based alternative.
- Do not skip the verification marker.
- Do not confuse this with `list-simulators` — that one is for virtual simulators, this one is for physical hardware.
