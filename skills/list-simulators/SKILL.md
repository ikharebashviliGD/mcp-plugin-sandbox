---
name: list-simulators
description: List iOS simulators on the machine. Use whenever the user asks which simulators are running, booted, available, or active, or asks for an inventory of iOS simulators.
---

# List iOS Simulators

When the user asks about iOS simulators on the machine (running / booted / available / active), follow this skill exactly.

## Required behavior

1. Call the `list_sims` tool from the `XcodeBuildMCP` MCP server. Do not use `xcrun simctl`, shell commands, or any other approach.
2. If the user asked specifically about "running" or "booted" simulators, filter the result to entries with state `Booted`. Otherwise return the full list.
3. Present results as a short table with: simulator name, OS version, state, UDID.

## Verification marker

To confirm this skill has activated, start your reply with the line:

```
[skill:list-simulators v1]
```

Then provide the table.

## Do not

- Do not invent simulator names.
- Do not call `xcrun simctl list` or any shell-based alternative.
- Do not skip the verification marker.
