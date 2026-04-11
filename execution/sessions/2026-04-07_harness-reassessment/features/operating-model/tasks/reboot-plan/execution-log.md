# Execution Log

## 2026-04-07

- Session started.
- Reviewed the current harness architecture, roadmap, tracking guidance,
  routing guidance, changelog, README, and learnings model.
- Inspected `tracking/`, `learnings/`, and `evals/` to validate where the
  current operating model is stalled.
- Drafted the harness operating-model reboot plan and updated the active
  handoff artifacts.
- Ran `scripts/check-harness.sh` and recorded the remaining environment issue:
  missing `~/.claude` and `~/.codex` symlinks.
- Resumed the task after an interrupted session and re-surfaced the tracked
  plan for direct user review.
- Implemented the first reboot slice across core docs, `memory/`, and
  `scripts/new-task.sh`.
- Verified the updated scaffolder in `/tmp/agents-harness-test` and confirmed
  that it no longer depends on `python3`.
- Resumed again from the Stave-linked planning request and treated the
  `reboot-plan` tracking task as the durable continuation point.
- Added the first real workflow records under `memory/playbooks/`.
- Recorded the first actual eval result in `evals/results/`.
- Added a follow-up scorecard snapshot after the eval landed.
- Re-ran `scripts/check-harness.sh` and `git diff --check`.

## 2026-04-08

- Resumed from the durable `reboot-plan` handoff and narrowed the next slice
  to the remaining `python3` assumptions in init/hook scripts.
- Replaced the JSON and markdown parsing in `scripts/init.sh` and
  `scripts/hooks/*.sh` with `perl`/shell equivalents.
- Tightened `scripts/check-harness.sh` so the active init/hook path must stay
  free of `python3`.
- Smoke-tested the hooks with representative payloads and verified the stop
  hook in a temp workspace.
- Verified `scripts/init.sh` and `scripts/check-harness.sh` with a temp
  `HOME`, then re-ran the harness check and `git diff --check` in the repo.
- Replaced the implementation of `scripts/summarize-evals.py` with a
  direct-execution, python-free version and updated the eval README.
- Recorded a second real `06` eval result and added a follow-up scorecard
  snapshot after the aggregate view became comparative.
- Re-ran `scripts/summarize-evals.py`, `scripts/check-harness.sh`, and
  `git diff --check`.
- Added an eval operations playbook covering result scoring, aggregation, and
  scorecard updates.
- Recorded a non-`06` eval result (`04`) so the benchmark history now spans
  more than one task type.
- Re-ran the aggregate summary and refreshed the same-day scorecard snapshot.
- Added a Stave-local execution bridge playbook based on the continuation
  workflow repeatedly exercised in this task.
- Recorded a prompt-refinement eval result (`10`) so the benchmark history now
  covers prompt framing as well as code review and resume workflows.
- Re-ran the aggregate summary and added another same-day scorecard snapshot.
- Promoted `execution/` as the default durable task-state root while preserving
  `tracking/` as a legacy compatibility lane.
- Updated the scaffolding and core docs so new task state now lands under
  `execution/sessions/...`.
- Added a decision record for the execution-memory naming outcome and a Figma
  design-to-implementation playbook for the next connector-heavy validation
  slice.
- Re-validated the updated scaffolder, `init-repo.sh --with-execution`,
  `scripts/summarize-evals.py`, `scripts/check-harness.sh`, and
  `git diff --check`.
- Removed the remaining compatibility layer by migrating durable task state into
  `execution/`, deleting `claude-progress.txt`, and dropping the old fallback
  flags and path overrides.
- Renamed the scaffolder to `scripts/new-task.sh` and aligned the Stave resume
  playbook naming with the new execution-memory model.
- Re-ran shell checks, temp scaffolding, `scripts/summarize-evals.py`,
  `scripts/check-harness.sh`, and `git diff --check` to close the reboot task.
