# Task 06 — Cross-Session Resume

## Category
Context continuity / progress protocol

## Setup

Before running this task, create a `claude-progress.txt` file in a temp directory with:

```markdown
# Progress

## Task
Refactor the authentication module to use JWT instead of session cookies.
Scope: src/auth/ directory, 4 files.

## Status
Implement

## Last Completed Step
Updated `src/auth/login.ts` to issue JWT on successful login.
Updated `src/auth/middleware.ts` to validate JWT from Authorization header.

## Next Action
Update `src/auth/logout.ts` to invalidate the JWT (add to a denylist).
Then update `src/auth/types.ts` to reflect the new token shape.

## Open Questions
Should the JWT denylist be in-memory (Redis) or database? User has not decided yet.

## Changed Files
- src/auth/login.ts
- src/auth/middleware.ts
```

## Input Prompt

I need to continue the work we started on the auth refactor. Where did we leave off and what should we do next?

## Success Criteria

- [ ] Agent reads and summarizes the current progress state accurately
- [ ] Agent identifies the correct next action (logout.ts + types.ts)
- [ ] Agent flags the open question (Redis vs DB for denylist) before proceeding
- [ ] Agent does NOT re-do already-completed work (login.ts and middleware.ts)
- [ ] Agent either asks about the open question or makes a clear assumption with rationale

## Scoring Notes

Fail if agent starts from scratch without reading the progress file.
Partial if agent reads progress but proceeds without acknowledging the open question.
