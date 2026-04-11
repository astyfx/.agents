# Harness Change Rollout and Validation

## Trigger

Use when changing the `.agents` harness itself: policy, docs, skills, hooks,
scripts, memory boundaries, or eval workflows.

## Inputs

- change scope and intended user-facing effect
- affected source-of-truth docs
- whether the work is substantial enough for a tracked task
- relevant prior handoff or plan artifacts

## Required Tools

- `ARCHITECTURE.md`, `ROADMAP.md`, and `AGENTS.md`
- `scripts/check-harness.sh`
- `the-progress-tracker` for active-task continuity
- relevant skill docs when the change alters routing or workflow behavior
- `evals/` tasks and result scaffolding when behavior changes materially

## Steps

1. Re-read the canonical architecture and roadmap before changing harness
   structure or policy.
2. Decide whether the work needs a tracked task. If yes, create or resume one
   and point `work-handoff.md` at it.
3. Change the live source files together:
   - policy and routing docs
   - scripts or hooks
   - memory records when the change introduces a durable lesson or decision
4. Keep boundary updates synchronized. If execution memory, operational
   memory, or prompt-loading rules change, update all affected docs in the same
   slice.
5. Run the relevant harness checks and at least one realistic verification
   path.
6. If the change affects agent behavior rather than only text, record an eval
   result under `evals/results/`.
7. Roll the new state into `work-handoff.md` and the tracked `handoff.md`.

## Expected Artifacts

- synchronized doc and script updates
- new or updated tracking records for substantial work
- memory records for durable decisions or recurring failure modes
- verification notes and, when appropriate, an eval result

## Verification

- run `bash scripts/check-harness.sh`
- run `bash -n` on any shell scripts that changed
- verify that new docs point to existing paths and current workflow names
- confirm that the handoff state matches the latest implementation slice

## Rollback Notes

- if a proposed harness change widens the always-on prompt surface without
  clear benefit, revert the idea before expanding the docs
- if a new behavior cannot be verified, record the gap explicitly instead of
  marking the slice complete
