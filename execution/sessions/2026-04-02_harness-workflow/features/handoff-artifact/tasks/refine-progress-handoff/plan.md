# Plan

## Scope

Replace the model-specific `claude-progress.txt` scratch protocol with a
model-neutral handoff artifact and update the live harness surface that reads,
writes, validates, and documents it.

## Task Path

execution/sessions/2026-04-02_harness-workflow/features/handoff-artifact/tasks/refine-progress-handoff

## Assumptions

- Keep the existing `the-progress-tracker` skill name unless a rename is clearly
  worth the migration cost.
- Introduce a new root scratch file named `work-handoff.md`.
- Preserve backward compatibility in scripts by reading legacy
  `claude-progress.txt` when present.

## Decomposition

1. Audit the live references and decide the new file shape.
2. Update the progress-tracker skill to describe the new handoff protocol.
3. Update scripts that scaffold, read, or validate the scratch file.
4. Update architecture and roadmap docs to describe the new artifact.
5. Verify with search and harness validation.

## Done Criteria

- Live harness docs point to `work-handoff.md` instead of `claude-progress.txt`.
- `the-progress-tracker` skill defines a handoff-oriented format with remaining
  work and nice-to-have follow-ups.
- `new-task.sh`, `on-stop-handoff.sh`, `check-harness.sh`,
  `init-repo.sh`, and `init.sh` understand the new artifact.
- Existing legacy `claude-progress.txt` files still do not break the flow.
- Verification shows the remaining live references are only historical records
  or deliberate legacy compatibility paths.
