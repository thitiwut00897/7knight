# Design: Lifecycle Workflow Redesign (Define → Plan → Build → Verify → Review → Ship)

**Date:** 2026-07-05
**Status:** Approved (pending final doc review)
**Supersedes in part:** [`2026-07-05-claude-code-plugin-migration-design.md`](2026-07-05-claude-code-plugin-migration-design.md) — that doc's plugin structure (agents/skills/commands/hooks layout, marketplace mechanism) still stands; this doc replaces the *content* of the PO/Tester/Senior/Refactor workflow it described.

## Goal

Replace the old PO-orchestrated Master-Test-Case bureaucracy with a lifecycle-stage workflow (`Define → Plan → Build → Verify → Review → Ship`), modeled on `addyosmani/agent-skills`, while keeping the parts of the old flow that are a genuine strength (strict AC traceability, a dedicated test-writing role separate from implementation), fixing the React-Native hardcoding identified during the plugin migration, and adding Jira + git integration the old flow never had.

## Why change

A side-by-side review of `addyosmani/agent-skills` against our own `po-agent`/`tester-agent`/`senior-full-stack-agent`/`refactor-agent` flow surfaced:

- Our Define/Plan/Build/Verify are *heavier* (Master TC ↔ Task TC traceability) but hardcoded to React Native/JS — not usable for backend or other stacks
- We have **no Review stage at all** (no 5-axis review, no security/performance check) and **no Ship stage** (no GO/NO-GO decision, no rollback plan) — addyosmani's pack covers both
- addyosmani's task slicing is stack-agnostic vertical slices; ours (`No-API Workflow`, mock-then-swap) was horizontal and RN-specific

This redesign keeps our traceability/role-separation strengths, drops the RN-only assumptions, and fills the Review/Ship gap by adapting three of addyosmani's specialist personas.

## Agent roster (7 total — 3 new)

| Agent | Status | Role |
|---|---|---|
| `po-agent` | Rewritten | Orchestrates the full 6-stage loop end to end when invoked via `/po-workflow` (still opt-in — does not run automatically every session) |
| `tester-agent` | Rewritten | Writes failing tests from a task's AC before implementation (RED); runs regression checks at Verify |
| `senior-full-stack-agent` | Rewritten | Implements to pass tests (GREEN) — backend then frontend, any stack per `project-blueprint.md`; RN-specific detail (styled-components, testID) moves to existing skills, referenced conditionally |
| `refactor-agent` | Rewritten | Fixes failures from Verify/Review without changing behavior — no longer JS/ESLint-only; reads the project's actual lint/test tooling from `project-blueprint.md` |
| `code-reviewer` | **New** | 5-axis review (correctness, readability, architecture, security, performance) — adapted stack-agnostic from `addyosmani/agent-skills` |
| `security-auditor` | **New** | OWASP-style audit (secrets, auth/authz, dependency CVEs) — adapted from `addyosmani/agent-skills` |
| `test-engineer` | **New** | Test coverage gap analysis (happy path, edge cases, error paths, concurrency) — used in the Ship fan-out; distinct from `tester-agent`'s per-task RED-writing role |

## Commands

- `/po-workflow` — rewritten to run the full 6-stage loop below, replacing its old Master-TC-based behavior. Still opt-in.
- `/spec`, `/plan`, `/build` (with `auto` mode), `/verify`, `/review`, `/ship` — new standalone commands, one per stage, usable independently of `/po-workflow`
- `/init-project-docs` — unchanged in mechanism; `project-blueprint.md` template gains two new fields (see Template updates below)

## Stage-by-stage design

### 1. Define

- If no Jira card was given: ask whether one exists. If the user has none, proceed directly from their request — do not block.
- If a card exists: read it completely — description, images/attachments, **all** comments — via Atlassian MCP or pasted content. This extends (does not replace) the existing always-on **Jira Card Read Gate** hook rule: that rule already blocks code changes when a linked card can't be read; this stage adds that after a successful read, the agent must *summarize its understanding and get explicit user confirmation* before writing `SPEC.md` — it must not go straight from reading to speccing.
- Anything ambiguous or missing in the card: ask the user. Never fill gaps by assumption.
- For the technical parts of the spec (tech stack, project structure, code style, testing strategy, boundaries): pull baseline values from `docs/codebase-docs/project-blueprint.md` first (if the project has run `/init-project-docs`); only ask the user for what the blueprint doesn't cover or what's specific to this task.
- Output: `SPEC.md` at the project root.

### 2. Plan

- Read `SPEC.md` + `project-blueprint.md` + relevant existing code. Enter plan mode (read-only, no edits).
- Slice work into **vertical, fullstack tasks**. Each task is internally ordered:
  1. Analyze what data/flags the frontend actually needs
  2. Build the backend to match
  3. Build the frontend and integrate with the real backend just built (no mocking, no waiting)
  4. End with the user checking the UI against what was wanted
- Each task carries AC + verification steps (no Master-TC-ID mapping — that traceability layer is dropped; see "Dropped from the old flow").
- If a Jira card exists: create matching **subtasks under the main card** in Jira, one per planned task.
- Present the plan to the user for approval before proceeding.
- Save to `tasks/plan.md` + `tasks/todo.md` (real files, so a plan survives a session boundary).

### 3. Build

- Before the first task starts: create a git branch off `develop`, named `feature/{JIRA-KEY}:{short-name}` (or `feature/{short-name}` if there's no Jira card). All commits for every task in this plan land on this one branch — one branch per plan, not per task.
- Per task:
  1. `@tester-agent` writes a failing test from the task's AC (RED) — backend side first
  2. `@senior-full-stack-agent` implements the backend to pass it (GREEN)
  3. `@tester-agent` writes the frontend/integration test
  4. `@senior-full-stack-agent` implements the frontend and integrates with the real backend
  5. Run the full test suite (regression) + build/compile check (commands read from `project-blueprint.md`, both frontend and backend)
  6. Commit onto the feature branch, message referencing the Jira card
  7. If a Jira card exists: mark that task's Jira **subtask** done and update the **main card's** status
  8. Mark the task complete
- `/build` (default): one task, then stop.
- `/build auto`: single up-front approval for the whole plan, then every task runs unattended in dependency order — still full RED→GREEN→regression→commit per task. Stops only when a test/build failure has no obvious fix, the spec is ambiguous, or a task is high-risk/irreversible (auth, destructive migration, payments, deploys, secrets).

### 4. Verify

- Runs once, after every task in the plan is complete (not per task) — equivalent to the old flow's Final Regression.
- `@tester-agent` runs the full test suite across the whole project (frontend + backend) plus a full build/compile check.
- The user checks the UI of the complete feature against `SPEC.md`/the original Jira card.
- FAIL → `@refactor-agent` fixes without changing behavior → re-verify.
- PASS → proceed to Review.

### 5. Review

- `@code-reviewer` runs the 5-axis review (correctness, readability, architecture, security, performance), delegating the security axis to `@security-auditor` (OWASP-style pass).
- Findings are categorized Critical / Important / Suggestion with file:line references.
- Critical findings must be fixed (routed back to `@senior-full-stack-agent` or `@refactor-agent`) and re-reviewed before proceeding.
- Important/Suggestion findings are reported but do not block moving to Ship.

### 6. Ship

- Parallel fan-out: `@code-reviewer`, `@security-auditor`, `@test-engineer` run concurrently, each producing an independent report.
- Merge in the main session: Code Quality, Security (any Critical/High security finding becomes a launch blocker), Performance, Accessibility, Infrastructure (env vars, migrations, monitoring, feature flags), Documentation.
- Produce a single **GO / NO-GO** decision with Blockers, Recommended fixes, Acknowledged risks, and a **mandatory rollback plan** (trigger conditions, procedure, recovery target) before any GO.
- Skip the fan-out only when the diff touches 2 files or fewer, is under 50 lines, and doesn't touch auth/payments/data/config — otherwise always fan out.

## Jira integration

- **Read** (Define): existing always-on gate, extended to require a confirmed understanding-summary before speccing.
- **Write** (Plan): create one Jira subtask per planned task under the main card.
- **Status sync** (Build): update both the task's own subtask and the main card's status as work progresses.
- If no card was ever provided (per Define's "ask, then proceed if none"), none of the write/sync steps apply — everything stays local to `tasks/plan.md`.

## Git branching

- One feature branch per plan, created from `develop` before the first Build task, not one branch per task.
- Naming: `feature/{JIRA-KEY}:{short-name}`, or `feature/{short-name}` when there's no Jira card.
- All of a plan's commits land on that branch; branch name and commit messages both reference the Jira card when one exists.

## Template updates

`docs/templates/project-blueprint.md` (and therefore every project's scaffolded `project-blueprint.md`) gains two new fields so agents stop hardcoding tool commands:

- **Commands** — actual lint / test / build commands for this project (frontend and backend separately if they differ)
- **Git workflow** — base branch name (default assumption: `develop`) and branch naming convention, in case a project doesn't follow the `feature/{JIRA-KEY}:{name}` default

## Dropped from the old flow

- Master Test Case ID system (`TC-01`, `TC-T01`, PASS/FAIL emoji report templates) — replaced by plain AC + verification steps per task
- `No-API Workflow` (mock-contract, build-UI-first-then-swap-in-real-API pattern) — replaced by the backend-first vertical slice in Plan/Build, since a fullstack agent no longer needs to wait on a separate API delivery
- Rigid delegation syntax blocks (`@tester-agent: เตรียม Task Test Cases สำหรับ Task [N] ...`) — superseded by the stage-based flow above; agents still communicate via `@mention` but without the old TC-ID-keyed message format

## Impact on existing files

- Rewrite: `agents/po-agent.md`, `agents/tester-agent.md`, `agents/senior-full-stack-agent.md`, `agents/refactor-agent.md`
- New: `agents/code-reviewer.md`, `agents/security-auditor.md`, `agents/test-engineer.md`
- Rewrite: `commands/po-workflow.md`
- New: `commands/spec.md`, `commands/plan.md`, `commands/build.md`, `commands/verify.md`, `commands/review.md`, `commands/ship.md`
- Update: `docs/templates/project-blueprint.md` (add Commands + Git workflow fields)
- Update: `hooks/always-on-rules.md` (Jira Card Read Gate section — extend with the "summarize and confirm before speccing" requirement)
- No change needed: `commands/init-project-docs.md` mechanism, skills (`ui-guide-template`, `codeing-guide`, etc. stay as-is, still trigger-based)

## Testing / rollout plan

1. Dry-run `/spec` → `/plan` → `/build` on one small real feature with a real Jira card, in a throwaway test project, verifying: card read + summary-confirm gate, subtask creation, branch creation off `develop`, per-task subtask/card status sync
2. Dry-run the same flow with **no** Jira card, confirming Define proceeds without blocking and no Jira write calls are attempted
3. Run `/build auto` on a multi-task plan, confirming it stops on a deliberately-introduced high-risk task (e.g. a migration) and resumes correctly after approval
4. Run `/verify` → `/review` → `/ship` on the completed feature; confirm the 3-way fan-out at Ship runs concurrently (not sequentially) and produces a single GO/NO-GO with a rollback plan
5. Confirm `refactor-agent` and the review/audit agents correctly pull lint/test commands from `project-blueprint.md` rather than assuming ESLint/Jest, using a non-JS test project if available

## Explicitly out of scope

- Multi-branch-per-task strategies (one branch per plan only)
- Automatic Jira status transitions beyond In Progress / Done (no custom workflow states)
- Any change to the plugin distribution mechanism itself (marketplace/plugin.json) — covered by the prior migration design doc
