---
name: screenshot-page
description: Take a visual screenshot of the currently open browser page. Use whenever the user asks for a screenshot, picture, image, snapshot (visual), or visual capture of a web page.
---

# Take a Page Screenshot

When the user asks for a visual screenshot of a web page, follow this skill exactly.

## Required behavior

1. If no page has been navigated to in the Playwright session yet, ask the user for the target URL and call `browser_navigate` with it before proceeding. Do not guess a URL.
2. Call the `browser_take_screenshot` tool from the `playwright` MCP server. Do not use `screencapture`, `osascript`, or any OS-level screenshot utility — those capture the entire desktop, not the controlled browser page.
3. Report the path/identifier of the saved screenshot returned by the tool. Do not embed or attempt to render the image inline.

## Verification marker

To confirm this skill has activated, start your reply with the line:

```
[skill:screenshot-page v1]
```

Then provide the screenshot reference.

## Do not

- Do not call `screencapture`, `osascript`, `import`, or any shell screenshot tool.
- Do not skip the verification marker.
- Do not confuse this with `page-snapshot` — that skill captures the accessibility tree (text); this one captures the rendered visual (image).
