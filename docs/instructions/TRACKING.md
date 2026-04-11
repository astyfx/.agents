# TRACKING.md

Rules for lightweight durable execution memory.

## Purpose

Persist just enough state that another agent can resume the work without
replaying chat history. Execution memory should reduce coordination cost, not
create paperwork.

Execution memory is task-local only. Reusable patterns, troubleshooting notes,
playbooks, and durable harness decisions belong in `./memory/`, not here.

## Default Stance

- Default to lightweight tracking.
- Prefer one durable task file over a bundle of mandatory artifacts.
- Add extra files only when they materially reduce risk or handoff cost.
- Keep task-local state here; move cross-task knowledge into `./memory/`.

## Applicability

Use **lightweight tracking** when work is substantial. Treat a task as
substantial if any of these are true:
- touches multiple files or layers
- is expected to take more than about 30 minutes
- introduces/refactors architecture or interfaces
- has significant risk (data, security, performance, release stability)
- explicitly requested by the user

Skip formal tracking for trivial edits, one-shot questions, or isolated doc
tweaks unless the user asks for it.

Use **expanded tracking** only when at least one of these is true:
- the work is likely multi-day or multi-session
- the design needs a self-contained plan another agent can execute cold
- verification evidence is long enough that it would clutter the main task file
- the user explicitly asks for more detailed artifacts

## Required Location

- Default execution-memory root: `./execution/`
- One session folder per work session:
  - `./execution/sessions/YYYY-MM-DD_<session-slug>/`
- One feature folder inside each session:
  - `./execution/sessions/YYYY-MM-DD_<session-slug>/features/<feature-slug>/`
- One task folder inside each feature:
  - `./execution/sessions/YYYY-MM-DD_<session-slug>/features/<feature-slug>/tasks/<task-slug>/`

## Default Required File Per Task

- `handoff.md`: the canonical durable task record

Use `handoff.md` as the single source of truth by default. It should carry the
minimum state another agent needs to continue:

```md
# Handoff

## Objective
<overall goal>

## Task Path
<execution/sessions/.../tasks/...>

## Current Status
<Discover | Plan | Implement | Verify | Blocked | Done>

## Scope
<short bullets or paragraph>

## Plan
<short checklist or ordered steps>

## Progress
<timestamped bullets for meaningful milestones>

## Decisions
<important decisions and why>

## Verification
<tests/checks run, or "Not run yet">

## Next Actions
<specific next steps>

## Open Questions
<user decisions or unresolved items>

## Changed Files
<key files touched>

## Notes
<context that would otherwise be lost>

## Auto Snapshot
<maintained by stop-time automation when available>
```

## Optional Expanded Artifacts

Create these only when the work truly needs them:
- `plan.md`: a self-contained execution plan for multi-hour or multi-sprint
  work
- `verification.md`: lengthy test evidence or independent review output
- `execution-log.md`: failure/recovery trail for debugging-heavy work

If an expanded artifact exists, keep `handoff.md` as the index and current
state summary. Do not let secondary files become the only source of truth.

## Scaffolding

Use the task scaffolder in the mode that matches the work:
- `bash scripts/new-task.sh <session> <feature> <task-slug>`:
  lightweight default under `execution/`
- `bash scripts/new-task.sh <session> <feature> <task-slug> --mode expanded`:
  adds `plan.md`, `verification.md`, and `execution-log.md` templates

## Phase Model

Use these statuses unless the user specifies another model:
1. Discover
2. Plan
3. Implement
4. Verify
5. Blocked
6. Done

Keep phases inline in `Current Status`, `Plan`, and `Progress`. Separate
`phases.md` or `tasks.md` files are not required by default.

## Operating Rules

- Create the session/feature/task folders at the start of tracked work.
- Seed `handoff.md` first. Do not create extra tracking files speculatively.
- Keep `work-handoff.md` pointed at the active task directory.
- Update `handoff.md` at major milestones and before ending the session.
- Prefer short checkbox lists in `Plan` and short timestamped bullets in
  `Progress`.
- If work spans multiple chats, continue in the same task folder unless scope
  changes materially.
- If a task already uses expanded tracking, keep `handoff.md` synchronized with
  the deeper artifacts instead of duplicating everything.
- In `work-handoff.md` and task `handoff.md`, keep next actions grounded in the
  current execution state. If the relevant changes exist only in the working
  tree, do not propose a next roadmap phase, migration-plan version, or broader
  rollout/versioning follow-up. Add those proposals only after the underlying
  change is committed or merged.
