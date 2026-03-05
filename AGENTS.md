# AGENTS.md

Shared rules for both Claude and Codex.

## Principles

- Keep settings minimal and explicit.
- Prefer reproducible, versioned configuration.
- Store shared assets in `skills/` and `subagents/`.

## Structure

- Claude-specific guidance lives in `CLAUDE.md` and `claude/`.
- Codex-specific guidance lives in `codex/`.

## Coding Principles

- Prefer clarity over cleverness.
- Keep functions small and single-purpose.
- Write tests for behavior, especially regression-prone paths.
- Make incremental, reviewable changes.
- Preserve backward compatibility unless explicitly changed.
- Avoid hidden side effects and global state coupling.
- Document non-obvious decisions in code comments or PR notes.

## Libraries Policy

- Prefer specified libraries if exists in the `LIBRARIES.md`
- Before coding, inspect installed/used libraries in the target project (`package.json`, lockfiles, imports, build config).
- Prioritize already-installed and already-used libraries unless the user explicitly requests a change.
- Reuse existing dependencies already in the project before adding new ones.
- Add new libraries only when they provide clear, durable value.
- Avoid overlapping libraries with duplicate responsibilities.
- Pin versions for reproducibility where possible.
- Choose actively maintained libraries with permissive licenses.

### Project Override Rules

- Project-level override file path: `./LIBRARIES.override.md`
- If override exists, priority order is:
  1. User direct instruction
  2. `./LIBRARIES.override.md`
  3. Root `LIBRARIES.md`
  4. Agent default judgment
- Override must document:
  - reason for exception
  - affected scope (feature/module)
  - migration or rollback note
- Agent must mention applied override briefly in task summary/handoff.

## Agentic Engineering Growth

Goal: help the user become an excellent agentic engineer (inspired by the 9-skill model from https://flowkater.io/posts/2026-03-01-agentic-engineering-9-skills/).

### 9 Skills To Practice

1. Decomposition
2. Context Architecture
3. Definition of Done
4. Failure Recovery Loop
5. Observability
6. Memory Architecture
7. Parallel Orchestration
8. Abstraction Layering
9. Taste

### Agent Coaching Rules

- Decomposition: break work into explicit, testable sub-tasks before implementation.
- Context Architecture: identify required files, constraints, interfaces, and assumptions first.
- Definition of Done: state concrete acceptance criteria (behavior, tests, performance, UX).
- Failure Recovery Loop: when blocked, run diagnose -> isolate -> minimal fix -> verify -> document.
- Observability: add/verify logs, metrics, error handling, and reproducible debug paths.
- Memory Architecture: maintain concise project memory (decisions, pitfalls, conventions, next steps).
- Parallel Orchestration: parallelize independent checks/reads/tasks when safe; serialize risky edits.
- Abstraction Layering: keep boundaries clear (UI/app/domain/infra), avoid leaking internals across layers.
- Taste: prefer simple, maintainable, coherent solutions; remove unnecessary complexity.

### Per-Task Output Contract

For each substantial task, include:
- Task decomposition (short list)
- Done criteria
- Verification evidence (tests/commands/results)
- What was learned (1-3 bullets for memory)

## Planning And Phase Tracking

Agents must persist planning and execution artifacts to the repository, not only in chat.

### Required Location

- Root tracking folder: `./tracking/`
- One session folder per work session:
  - `./tracking/sessions/YYYY-MM-DD_<session-slug>/`
- One feature folder inside each session:
  - `./tracking/sessions/YYYY-MM-DD_<session-slug>/features/<feature-slug>/`
- One task folder inside each feature:
  - `./tracking/sessions/YYYY-MM-DD_<session-slug>/features/<feature-slug>/tasks/<task-slug>/`

### Required Files Per Task

- `plan.md`: scope, assumptions, decomposition, done criteria.
- `phases.md`: phase breakdown and current phase status.
- `tasks.md`: checklist-style task list with timestamps and owner.
- `execution-log.md`: commands run, key outputs, failures, recoveries.
- `verification.md`: tests/checks performed and results.
- `handoff.md`: summary, open issues, next actions.

### Phase Model

Use these phases unless the user specifies another model:
1. Discover
2. Plan
3. Implement
4. Verify
5. Handoff

### Operating Rules

- Create the session/feature/task folders at the start of substantial work.
- Keep `phases.md` and `tasks.md` updated as status changes.
- Append important decisions and recovery steps immediately to `execution-log.md`.
- Close each task with `verification.md` and `handoff.md`.
- If work spans multiple chats, continue in the same task folder unless scope changes.
