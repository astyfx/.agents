---
name: the-progress-tracker
description: Resume work from a previous session, keep a concise work handoff, or summarize leftover work for the next agent. Use when the user says "이어서 작업", "어디까지 했지", "resume", "continue where we left off", "진행 상황 정리", "handoff 정리", "잔여 작업 정리", or "다음에 이어서". Reads and writes `work-handoff.md` as a cross-agent portable handoff file.
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "이어서 작업해줘"
  - "어디까지 했지?"
  - "resume the task"
  - "진행 상황 정리해줘"
  - "continue where we left off"
---

# The Progress Tracker

Cross-session continuity via a portable work handoff. Any agent reads and writes
the same format.

## Use This Skill When

- Starting a new session on an ongoing multi-session task.
- The user asks to resume, continue, or summarize current progress.
- Ending a substantial session (create or update the handoff snapshot).
- Switching agents mid-task (Claude → Codex or vice versa).

## The Progress File

**Primary file**: `./work-handoff.md` at the project root.

**Format**:

```markdown
# Work Handoff

## Objective
<one-paragraph description of the overall goal>

## Active Task Path
<path to the active task directory, e.g. execution/sessions/.../tasks/...>

## Current Status
<current phase: Discover | Plan | Implement | Verify | Handoff>

## Completed
<short bullets for work that is already done>

## Remaining Work
<short bullets for work that is still pending>

## Recommended Next Actions
<the exact next steps — specific file, function, or command>

## Nice-to-Have Follow-Ups
<optional improvements that are safe to defer>

## Open Questions
<anything unresolved that the user needs to decide>

## Changed Files
<list of files modified since task start>

## Notes
<any gotchas, decisions made, or context that is not obvious>
```

**Rules**:
- This file is NOT committed (add to `.gitignore` if not already there).
- It is a working scratch file, not a permanent record.
- Permanent record lives in `execution/sessions/.../handoff.md` by default.
- By default, that tracking task is a single durable `handoff.md` file. Add
  `plan.md`, `verification.md`, or `execution-log.md` only when the work
  actually needs expanded artifacts.
- Reusable patterns, troubleshooting notes, and durable decisions belong in
  `memory/`, not in the handoff files.
- `Active Task Path` should point to the task directory, not directly to `handoff.md`.
- Keep it concise. Roll the current state forward instead of appending indefinitely.
- `Recommended Next Actions` and `Nice-to-Have Follow-Ups` should stay tied to
  the current execution state.
- If the underlying work exists only in the working tree, do not suggest a next
  roadmap phase, migration-plan version, or broader rollout/versioning follow-up.
- Those broader proposals are allowed only after the relevant change is
  committed or merged; reference the commit or merge when possible.

## Workflow: Session Start (Resuming)

1. Check if `./work-handoff.md` exists.
2. If it exists: read it and produce a structured briefing:
   - Current status and phase
   - Active tracking task path
   - What is already complete (do not redo this)
   - What remains and what to do next
   - Optional nice-to-have follow-ups
   - Open questions that need a decision before proceeding
3. If neither file exists: check `execution/sessions/` for recent
   `handoff.md` files.
5. If no progress artifacts exist: start fresh, create `work-handoff.md` after
   the first milestone.

## Workflow: During Work

Update `./work-handoff.md` at each significant milestone:
- Phase transition (Discover → Plan, Plan → Implement, etc.)
- Completion of a file or module
- When an open question gets resolved
- When the active execution task path changes
- When remaining work or nice-to-have follow-ups materially change

Keep updates minimal — just change the relevant fields.

## Workflow: Session End

Before ending the session:
1. Update `./work-handoff.md` with the final status, completed work,
   remaining work, recommended next actions, and nice-to-have follow-ups.
2. If a task exists, update `execution/.../handoff.md` as the
   permanent record. If expanded tracking files exist, keep the summary in
   `handoff.md` aligned with them.
3. Make sure `Active Task Path` still points to the active task before ending
   the session.
4. The handoff scratch file captures "where to pick up"; `handoff.md` captures
   "what was done and why".

## Cross-Agent Compatibility

This skill is compatible with both Claude and Codex because:
- It uses only plain markdown files, not tool-specific APIs.
- The file name and format are model-neutral and readable by any agent without
  special tooling.
- Codex should follow the same session-start/end workflow via its AGENTS.md invariants.

## Done Definition

A session handoff is complete when:
- `work-handoff.md` reflects the current state accurately.
- `Active Task Path` points to the correct active task.
- The next action is specific enough that a different agent can pick it up cold.
- Remaining work and nice-to-have follow-ups are separated clearly.
- Open questions are explicitly listed (not buried in chat history).
