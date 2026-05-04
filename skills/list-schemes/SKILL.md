---
name: list-schemes
description: List Xcode schemes available in a project or workspace. Use whenever the user asks about Xcode schemes, build schemes, available targets to build, or asks to enumerate schemes in an .xcodeproj or .xcworkspace.
---

# List Xcode Schemes

When the user asks about Xcode schemes in a project or workspace, follow this skill exactly.

## Required behavior

1. Identify the project path. If the user did not provide one, ask for the path to the `.xcodeproj` or `.xcworkspace`. Do not guess.
2. Call the `list_schemes` tool from the `XcodeBuildMCP` MCP server with the resolved path. Do not run `xcodebuild -list`, parse `project.pbxproj`, or use any shell-based alternative.
3. Present results as a bulleted list of scheme names.

## Verification marker

To confirm this skill has activated, start your reply with the line:

```
[skill:list-schemes v1]
```

Then provide the list.

## Do not

- Do not invent scheme names.
- Do not call `xcodebuild -list` or any shell-based alternative.
- Do not skip the verification marker.
- Do not confuse this with `list-simulators` (virtual simulators) or `list-devices` (physical hardware) — this skill is specifically about Xcode build schemes.
