# TRACKING.md

Rules for persistent plan and phase tracking.

## Purpose

Agents must persist planning and execution artifacts to the repository, not only in chat.

## Applicability

Apply full tracking when work is substantial. Treat a task as substantial if any of these are true:
- touches multiple files or layers
- is expected to take more than about 30 minutes
- introduces/refactors architecture or interfaces
- has significant risk (data, security, performance, release stability)
- explicitly requested by the user

For trivial edits, a lightweight note in `handoff.md` is sufficient.

## Required Location

- Root tracking folder: `./tracking/`
- One session folder per work session:
  - `./tracking/sessions/YYYY-MM-DD_<session-slug>/`
- One feature folder inside each session:
  - `./tracking/sessions/YYYY-MM-DD_<session-slug>/features/<feature-slug>/`
- One task folder inside each feature:
  - `./tracking/sessions/YYYY-MM-DD_<session-slug>/features/<feature-slug>/tasks/<task-slug>/`

## Required Files Per Task

- `plan.md`: scope, assumptions, decomposition, done criteria
- `phases.md`: phase breakdown and current phase status
- `tasks.md`: checklist-style task list with timestamps and owner
- `execution-log.md`: commands run, key outputs, failures, recoveries
- `verification.md`: tests and checks performed with results
- `handoff.md`: summary, open issues, next actions

## Phase Model

Use these phases unless the user specifies another model:
1. Discover
2. Plan
3. Implement
4. Verify
5. Handoff

## Operating Rules

- Create the session/feature/task folders at the start of substantial work.
- Keep `phases.md` and `tasks.md` updated as status changes.
- Append important decisions and recovery steps immediately to `execution-log.md`.
- Close each task with `verification.md` and `handoff.md`.
- If work spans multiple chats, continue in the same task folder unless scope changes.
