---
inclusion: manual
description: "List Xcode schemes in a project or workspace via XcodeBuildMCP. Use when the user asks about Xcode schemes, build schemes, or available targets in an .xcodeproj/.xcworkspace."
---

# List Xcode Schemes

When the user asks about Xcode schemes in a project or workspace, follow this guidance exactly.

## Required behavior

1. Identify the project path. If the user did not provide one, ask for the path to the `.xcodeproj` or `.xcworkspace`. Do not guess.
2. Call the `list_schemes` tool from the `XcodeBuildMCP` MCP server with the resolved path. Do not run `xcodebuild -list`, parse `project.pbxproj`, or use any shell-based alternative.
3. Present results as a bulleted list of scheme names.

## Verification marker

To confirm this guidance has activated, start your reply with the line:

```
[skill:list-schemes v1]
```

Then provide the list.

## Do not

- Do not invent scheme names.
- Do not call `xcodebuild -list` or any shell-based alternative.
- Do not skip the verification marker.
- Do not confuse this with `list-simulators` (virtual simulators) or `list-devices` (physical hardware) — this guidance is specifically about Xcode build schemes.
