# Stave Task Resume and Local Execution Bridge

## Trigger

Use when a user asks to continue a Stave task and the real execution state may
already live in local `work-handoff.md` and `execution/` artifacts.

## Inputs

- current Stave task awareness or retrieved Stave context
- `work-handoff.md`
- recent tracked `handoff.md` records under `execution/sessions/`
- any task ids or artifact links mentioned in chat

## Required Tools

- Stave current-task context from the runtime
- `the-progress-tracker`
- local repo search across `execution/sessions/`, `work-handoff.md`, and
  related handoff files

## Steps

1. Read `work-handoff.md` first if it exists.
2. Compare the active local task path with the Stave task context and any task
   ids mentioned in chat.
3. Distinguish between:
   - the Stave conversation that introduced the work
   - the durable local artifact where execution actually continued
4. Resume from the local durable artifact instead of replaying old chat or
   restarting from the originating Stave task.
5. Summarize:
   - current status
   - completed work
   - remaining work
   - the next concrete slice
6. If the requested Stave task id does not exist locally, state that clearly
   and explain which local artifact is being used as the continuation point.
7. After the slice is done, roll the updated state back into `work-handoff.md`
   and the tracked `handoff.md`.

## Expected Artifacts

- a correct continuation point anchored to local durable artifacts
- updated `work-handoff.md`
- updated tracked `handoff.md` when the work is substantial
- explicit note when Stave task ids and local task paths differ

## Verification

- confirm the resumed task path exists locally
- verify that already-completed slices are not repeated
- make sure the next action in handoff reflects the latest actual change, not
  an earlier Stave planning state

## Rollback Notes

- do not assume the latest Stave task id is the authoritative execution state
- if multiple plausible local continuation points exist, stop and compare the
  evidence instead of guessing
