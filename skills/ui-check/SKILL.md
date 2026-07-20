---
name: ui-check
description: Use when asked to visually check, verify, or compare how a page/screen actually looks after a UI change — routes to the claude-in-chrome extension for web (real Chrome, logged-in session) or to ios-simulator-skill / sim-use for iOS/Android (simulator, emulator, real device)
---

# UI Check — Web vs Mobile Router

## Overview

Verifying a UI change means *seeing the rendered result*, never reading source code. Which tool renders it depends on platform:

| Platform | Tool | Why this one |
|---|---|---|
| Web | `claude-in-chrome` (browser extension) | Drives the user's real Chrome — real login session, real cookies, real network. No Playwright/dev-server-only context needed. |
| iOS (native or React Native) | `ios-simulator-skill` | Accessibility-tree navigation, purpose-built for AI agents, minimal token output. **Prefer this over generic sim-use for iOS.** |
| Android / iOS when `ios-simulator-skill` isn't installed | `sim-use` (7knight) | Accessibility-tree observe→act→verify loop, works for both platforms. |

This skill is for **ad-hoc visual checks** ("does this page look right", "compare against this mock"). It is not the same as:
- Writing/running Playwright test suites → use `webapp-testing` skill instead
- Replaying recorded mobile regression flows across many screens → use `/regression-sim-use` command directly

## Decision

```
Is the thing being checked a web page (browser-rendered)?
├─ Yes → Web route (claude-in-chrome)
└─ No → mobile screen
    ├─ ios-simulator-skill available/installed → iOS route (ios-simulator-skill)
    └─ Android, or ios-simulator-skill unavailable → sim-use
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

## Mobile route — Android or no ios-simulator-skill (sim-use)

Follow `skills/sim-use/SKILL.md`'s observe→act→verify loop: `sim-use ui --device <UDID>` to observe, act on a selector, verify with another `sim-use ui` or `sim-use screenshot`. Run the preflight check first (`scripts/preflight.py --device <UDID>` or the 3 manual checks in that skill) before first interaction with a device.

## Comparing against a reference image

When a design mock/reference screenshot exists, don't just say "looks right" — check point-by-point and report explicitly: layout match, spacing, color/theme, icon/asset correctness, text/label accuracy. If it doesn't match, say what differs before re-checking; don't loop silently.

## Common mistakes

- Loading claude-in-chrome tools one ToolSearch call at a time instead of one batched call.
- Reaching for generic `sim-use` for an iOS check when `ios-simulator-skill` is installed and available — it's cheaper and purpose-built for iOS.
- Reading component source code as a substitute for actually rendering and looking at the page/screen.
- Clicking a delete/confirm button through claude-in-chrome without checking it won't trigger a blocking native dialog first.
