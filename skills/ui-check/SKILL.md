---
name: ui-check
description: Use when asked to visually check, verify, or compare how a page/screen actually looks after a UI change — routes to the claude-in-chrome extension for web (real Chrome, logged-in session) or to ios-simulator-skill for iOS (simulator, real device)
---

# UI Check — Web vs Mobile Router

## Overview

Verifying a UI change means *seeing the rendered result*, never reading source code. Which tool renders it depends on platform:

| Platform | Tool | Why this one |
|---|---|---|
| Web | `claude-in-chrome` (browser extension) | Drives the user's real Chrome — real login session, real cookies, real network. No Playwright/dev-server-only context needed. |
| iOS (native or React Native) | `ios-simulator-skill` | Accessibility-tree navigation, purpose-built for AI agents, minimal token output. |

This skill is for **ad-hoc visual checks** ("does this page look right", "compare against this mock"). It is not the same as:
- Writing/running Playwright test suites → use `webapp-testing` skill instead

## Decision

```
Is the thing being checked a web page (browser-rendered)?
├─ Yes → Web route (claude-in-chrome)
└─ No → mobile screen (iOS) → ios-simulator-skill
```

## Web route (claude-in-chrome)

1. **Load tools in one batch** — claude-in-chrome tools are deferred; loading them one at a time wastes round-trips:
   `ToolSearch("select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__computer,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__tabs_create_mcp,mcp__claude-in-chrome__get_page_text")`
2. `tabs_context_mcp` → see what's already open, don't blindly open a new tab.
3. `navigate` (or `tabs_create_mcp` + `navigate`) to the page/route under test.
4. Capture what's rendered — `read_page`/`get_page_text` for DOM/content, `computer` screenshot action for the visual.
5. If a reference image/mock was given, compare point-by-point (layout, spacing, color, copy, icons) — don't just eyeball "looks fine".
6. Never click anything that triggers a native `alert`/`confirm`/`prompt` dialog — it blocks the extension. See the claude-in-chrome MCP instructions for the full dialog-avoidance list.

## Mobile route — iOS (ios-simulator-skill)

1. `bash scripts/sim_health_check.sh` — confirm simulator reachable and app installed.
2. `python scripts/screen_mapper.py` — structured accessibility-tree element list (cheap, ~10 tokens vs a screenshot).
3. Only take an actual screenshot when a *visual* compare (colors, spacing, icon correctness against a mock) is needed — the accessibility tree doesn't tell you if a button is the wrong shade of blue.
4. `python scripts/navigator.py --find-text/--find-type/--find-id` for any interaction needed to reach the screen under test.

## Comparing against a reference image

When a design mock/reference screenshot exists, don't just say "looks right" — check point-by-point and report explicitly: layout match, spacing, color/theme, icon/asset correctness, text/label accuracy. If it doesn't match, say what differs before re-checking; don't loop silently.

## Common mistakes

- Loading claude-in-chrome tools one ToolSearch call at a time instead of one batched call.
- Reading component source code as a substitute for actually rendering and looking at the page/screen.
- Clicking a delete/confirm button through claude-in-chrome without checking it won't trigger a blocking native dialog first.
