# Eval Run Scoring and Scorecard Update

## Trigger

Use when a real benchmark run should be recorded under `evals/results/` and
rolled into the harness evidence trail.

## Inputs

- eval task id and agent name
- the actual run context or prompt variant that was executed
- scoring judgment against the task success criteria
- whether the aggregate view or scorecard meaningfully changed

## Required Tools

- `evals/tasks/`
- `scripts/new-eval-result.sh`
- `scripts/summarize-evals.py`
- `memory/scorecard/`
- `work-handoff.md` and the active tracked `handoff.md` for multi-session work

## Steps

1. Choose the eval task that best matches the work that actually happened.
2. If the run is a real-world variant instead of the exact canned prompt,
   decide whether the match is still honest enough to score and note the
   caveat explicitly.
3. Create the result scaffold with `bash scripts/new-eval-result.sh <agent> <task-id>`.
4. Score the run field by field:
   - `pass`
   - `rework_count`
   - `verification_quality`
   - `policy_compliance`
   - `time_minutes`
5. Write notes that map the observed behavior to the task success criteria and
   list any caveats.
6. Run `scripts/summarize-evals.py` to refresh the aggregate view.
7. If the aggregate evidence changed materially, add or update a scorecard
   snapshot under `memory/scorecard/`.
8. Roll the new counts, remaining evidence gaps, and next eval candidates into
   `work-handoff.md` and the active tracked `handoff.md`.

## Expected Artifacts

- a new `evals/results/*.md` file with filled scores
- updated aggregate summary from `scripts/summarize-evals.py`
- a scorecard snapshot when the evidence meaningfully changes
- synchronized handoff state

## Verification

- confirm the chosen task actually matches the run that was scored
- make sure every required result field is filled
- run `scripts/summarize-evals.py` successfully after writing the result
- if a scorecard snapshot was updated, verify the counts match the aggregate

## Rollback Notes

- do not mark a run as pass without mapping it back to the task criteria
- do not hide prompt or environment caveats; note them in the result file
- if the run was too far from the intended task, discard it instead of forcing
  it into the eval history
