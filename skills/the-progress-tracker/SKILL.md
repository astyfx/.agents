---
name: the-progress-tracker
description: Resume work from a previous session, track cross-session progress, or create a handoff summary. Use when the user says "이어서 작업", "어디까지 했지", "resume", "continue where we left off", "진행 상황 정리", "다음에 이어서", or when starting a new session on an ongoing task. Reads and writes claude-progress.txt as a cross-agent portable progress file.
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

Cross-session continuity via a portable progress file. Any agent reads and writes the same format.

## Use This Skill When

- Starting a new session on an ongoing multi-session task.
- The user asks to resume, continue, or summarize current progress.
- Ending a substantial session (create or update the progress snapshot).
- Switching agents mid-task (Claude → Codex or vice versa).

## The Progress File

**File**: `./claude-progress.txt` at the project root (the "claude" prefix is historical; any agent uses it).

**Format**:

```markdown
# Progress

## Task
<one-paragraph description of the overall goal>

## Status
<current phase: Discover | Plan | Implement | Verify | Handoff>

## Last Completed Step
<specific last action taken — concrete enough to avoid repeating it>

## Next Action
<the exact next step — specific file, function, or command>

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
- Permanent record lives in `tracking/sessions/.../handoff.md`.
- Keep it under 30 lines. Compress old entries instead of appending indefinitely.

## Workflow: Session Start (Resuming)

1. Check if `./claude-progress.txt` exists.
2. If it exists: read it and produce a structured briefing:
   - Current status and phase
   - What was last completed (do not redo this)
   - What to do next (start here)
   - Open questions that need a decision before proceeding
3. If it does not exist: check `tracking/sessions/` for recent handoff.md files.
4. If no progress artifacts exist: start fresh, create progress.txt after first milestone.

## Workflow: During Work

Update `./claude-progress.txt` at each significant milestone:
- Phase transition (Discover → Plan, Plan → Implement, etc.)
- Completion of a file or module
- When an open question gets resolved

Keep updates minimal — just change the relevant fields.

## Workflow: Session End

Before ending the session:
1. Update `./claude-progress.txt` with final status, last completed step, and next action.
2. If a tracking task exists, update `tracking/.../handoff.md` as the permanent record.
3. The progress file captures "where to pick up"; the handoff.md captures "what was done and why".

## Cross-Agent Compatibility

This skill is compatible with both Claude and Codex because:
- It uses only plain markdown files, not tool-specific APIs.
- The file format is readable by any agent without special tooling.
- Codex should follow the same session-start/end workflow via its AGENTS.md invariants.

## Done Definition

A session handoff is complete when:
- `claude-progress.txt` reflects the current state accurately.
- The next action is specific enough that a different agent can pick it up cold.
- Open questions are explicitly listed (not buried in chat history).
