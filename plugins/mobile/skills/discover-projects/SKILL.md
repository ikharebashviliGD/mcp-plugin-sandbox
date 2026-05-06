---
name: discover-projects
description: Find Xcode projects and workspaces inside a directory. Use whenever the user asks to discover, find, locate, scan for, or enumerate Xcode projects (.xcodeproj) or workspaces (.xcworkspace) under a given path or in the current repository.
---

# Discover Xcode Projects and Workspaces

When the user asks to find Xcode projects or workspaces in a directory, follow this skill exactly.

## Required behavior

1. Identify the search root. If the user did not provide one, default to the current working directory and state that assumption explicitly.
2. Call the `discover_projs` tool from the `XcodeBuildMCP` MCP server with the resolved directory path. Do not run `find`, `fd`, `mdfind`, or any shell-based search.
3. Present the discovered items as two short lists: one for `.xcodeproj`, one for `.xcworkspace`. Show full paths.
4. If nothing is found, return a single line stating "No Xcode projects or workspaces found under <path>".

## Verification marker

To confirm this skill has activated, start your reply with the line:

```
[skill:discover-projects v1]
```

Then provide the listings.

## Do not

- Do not run `find . -name "*.xcodeproj"` or any shell equivalent.
- Do not invent file paths.
- Do not skip the verification marker.
- Do not confuse this with `list-schemes` — that skill works on a single known project; this skill discovers projects in the first place.
