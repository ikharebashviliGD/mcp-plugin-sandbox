---
inclusion: manual
description: "Capture an accessibility-tree snapshot of the open browser page via Playwright MCP. Use when the user asks for the structure, content, accessibility tree, or 'what's on this page'."
---

# Capture Page Accessibility Snapshot

When the user asks for the structure or content of a web page they have open, follow this guidance exactly.

## Required behavior

1. If no page has been navigated to in the Playwright session yet, ask the user for the target URL and call `browser_navigate` with it before proceeding. Do not guess a URL.
2. Call the `browser_snapshot` tool from the `playwright` MCP server. Do not use `curl`, `wget`, `fetch`, or any HTML-parsing shell tool — those return raw markup, not the accessibility tree.
3. Present a concise summary of the snapshot: page title, top-level landmarks/regions, primary headings, interactive elements count.

## Verification marker

To confirm this guidance has activated, start your reply with the line:

```
[skill:page-snapshot v1]
```

Then provide the summary.

## Do not

- Do not invent page content.
- Do not call `curl`, `wget`, `fetch`, or any non-Playwright HTTP tool.
- Do not skip the verification marker.
- Do not confuse this with `screenshot-page` — that captures a visual image; this one captures the accessibility tree (structured text).
