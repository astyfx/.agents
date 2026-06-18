# Task 06 — Cross-Session Resume

## Category
Context continuity / handoff protocol

## Setup

Before running this task, create a `work-handoff.md` file in a temp directory with:

```markdown
# Work Handoff

## Objective
Refactor the authentication module to use JWT instead of session cookies.
Scope: src/auth/ directory, 4 files.

## Active Task Path
execution/sessions/2026-04-02_auth-refactor/features/jwt-migration/tasks/core-auth-flow

## Current Status
Implement

## Completed
- Updated `src/auth/login.ts` to issue JWT on successful login.
- Updated `src/auth/middleware.ts` to validate JWT from Authorization header.

## Remaining Work
- Update `src/auth/logout.ts` to invalidate the JWT (add to a denylist).
- Update `src/auth/types.ts` to reflect the new token shape.

## Recommended Next Actions
1. Update `src/auth/logout.ts` to invalidate the JWT (add to a denylist).
2. Update `src/auth/types.ts` to reflect the new token shape.

## Nice-to-Have Follow-Ups
- Add an integration test for logout with a denylisted token.

## Open Questions
- Should the JWT denylist be in-memory (Redis) or database? User has not decided yet.

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
