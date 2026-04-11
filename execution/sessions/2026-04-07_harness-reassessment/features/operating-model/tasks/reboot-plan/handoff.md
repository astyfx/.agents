# Handoff

## Objective

Re-evaluate the `.agents` harness from the operating-model level and produce a
practical reboot plan for long-term AI-native engineering and management work.

## Task Path

execution/sessions/2026-04-07_harness-reassessment/features/operating-model/tasks/reboot-plan

## Current Status

Done

## Scope

- Assess whether the current execution-memory layer, `learnings`, `ROADMAP`,
  and cross-agent sharing model are still pulling their weight.
- Convert the user's stated goals into a durable planning artifact that future
  Claude and Codex sessions can continue from.
- Define a phased reboot plan that reduces token overhead, improves learning
  and troubleshooting capture, and keeps per-repo outputs team-safe.

## Plan

- [x] Review the current harness architecture, roadmap, tracking, routing, and
  changelog.
- [x] Inspect the current state of `tracking/`, `learnings/`, and `evals/` for
  signs of real usage versus static design intent.
- [x] Draft a reboot plan covering target architecture, migration phases,
  risks, and success metrics.
- [x] Review the proposal with the user and decide the first implementation
  slice.
- [x] Implement the first reboot slice across core docs, operational memory,
  and the tracked-task scaffolder.
- [x] Continue the reboot through migration cleanup and final close-out.

## Progress

- [x] 2026-04-07: Task scaffold created.
- [x] 2026-04-07: Reviewed `ARCHITECTURE.md`, `ROADMAP.md`,
  `docs/instructions/TRACKING.md`, `docs/instructions/ROUTING.md`,
  `CHANGELOG.md`, `README.md`, and `learnings/README.md`.
- [x] 2026-04-07: Confirmed the requested Stave task ids are not present in the
  local `.agents` repository, so the reboot plan is grounded in current repo
  evidence plus the user's latest brief.
- [x] 2026-04-07: Created `plan.md` with a diagnosis of the current harness,
  a target operating model, migration phases, and a risk matrix.
- [x] 2026-04-07: Ran `bash scripts/check-harness.sh`; the planning docs are
  fine, and the only reported repo-level issues are missing `~/.claude` and
  `~/.codex` symlinks in the current machine setup.
- [x] 2026-04-07: Re-opened the tracked reboot plan after the interrupted
  session so the user can review the proposal directly from the durable
  artifact.
- [x] 2026-04-07: Implemented the first reboot slice:
  - added `docs/instructions/CONTEXT_LOADING.md`
  - created the new `memory/` structure with decision, troubleshooting, and
    scorecard records
  - updated core docs to separate execution memory from operational memory
  - removed the `python3` dependency from `scripts/new-task.sh`
- [x] 2026-04-07: Verified the slice with:
  - `bash -n scripts/new-task.sh`
  - `bash -n scripts/check-harness.sh`
  - `bash scripts/check-harness.sh`
  - a real temp-directory run of `scripts/new-task.sh --mode expanded`
- [x] 2026-04-07: Implemented the second reboot slice:
  - added four real workflow records under `memory/playbooks/`
  - recorded the first eval result under `evals/results/`
  - added a follow-up scorecard snapshot after the eval landed
- [x] 2026-04-07: Verified the second slice with:
  - `bash scripts/check-harness.sh`
  - `git diff --check`
- [x] 2026-04-08: Implemented the third reboot slice:
  - removed the `python3` dependency from `scripts/init.sh`
  - removed the `python3` dependency from:
    - `scripts/hooks/pre-commit-lint.sh`
    - `scripts/hooks/pre-write-secrets.sh`
    - `scripts/hooks/post-write-format.sh`
    - `scripts/hooks/on-stop-handoff.sh`
  - updated `scripts/check-harness.sh` to assert the active init/hook path
    stays python-free
- [x] 2026-04-08: Verified the third slice with:
  - `bash -n scripts/init.sh scripts/check-harness.sh scripts/hooks/pre-commit-lint.sh scripts/hooks/pre-write-secrets.sh scripts/hooks/post-write-format.sh scripts/hooks/on-stop-handoff.sh`
  - representative hook payload runs for commit lint, secret blocking, and
    post-write path parsing
  - a temp-`HOME` run of `bash scripts/init.sh` followed by
    `bash scripts/check-harness.sh`
  - a temp workspace run of `scripts/hooks/on-stop-handoff.sh`
  - `bash scripts/check-harness.sh`
  - `git diff --check`
- [x] 2026-04-08: Implemented the fourth reboot slice:
  - removed the remaining Python dependency from
    `scripts/summarize-evals.py` while preserving its path
  - updated `evals/README.md` to use direct script execution
  - recorded a second real eval result in `evals/results/2026-04-08_codex_06.md`
  - added a new scorecard snapshot in
    `memory/scorecard/2026-04-08-python-free-eval-summary-and-second-resume-run.md`
- [x] 2026-04-08: Verified the fourth slice with:
  - direct execution of `scripts/summarize-evals.py`
  - `bash scripts/check-harness.sh`
  - `git diff --check`
- [x] 2026-04-08: Implemented the fifth reboot slice:
  - added `memory/playbooks/eval-run-scoring-and-scorecard-update.md`
  - recorded a non-`06` eval result in `evals/results/2026-04-08_codex_04.md`
  - refreshed the scorecard snapshot so eval history now spans multiple task
    types
- [x] 2026-04-08: Verified the fifth slice with:
  - `scripts/summarize-evals.py`
  - `bash scripts/check-harness.sh`
  - `git diff --check`
- [x] 2026-04-08: Implemented the sixth reboot slice:
  - added `memory/playbooks/stave-task-resume-and-local-execution-bridge.md`
  - recorded a prompt-refinement eval result in
    `evals/results/2026-04-08_codex_10.md`
  - added a new scorecard snapshot in
    `memory/scorecard/2026-04-08-stave-bridge-and-prompt-refinement-eval.md`
- [x] 2026-04-08: Verified the sixth slice with:
  - `scripts/summarize-evals.py`
  - `bash scripts/check-harness.sh`
  - `git diff --check`
- [x] 2026-04-08: Implemented the seventh reboot slice:
  - promoted `execution/` to the default durable execution-memory root
  - updated core docs and scaffolding to seed `execution/sessions/...` by
    default
  - added `memory/decisions/2026-04-08-execution-memory-default-path.md`
  - added
    `memory/playbooks/figma-design-to-implementation-and-visual-verification.md`
  - added
    `memory/scorecard/2026-04-08-execution-default-and-figma-playbook.md`
- [x] 2026-04-08: Verified the seventh slice with:
  - `bash -n scripts/new-task.sh scripts/init-repo.sh scripts/init.sh scripts/check-harness.sh`
  - a temp run of `scripts/new-task.sh demo feature task-one --mode expanded`
  - a temp run of `scripts/init-repo.sh <tmp/project> --with-execution`
  - `scripts/summarize-evals.py`
  - `bash scripts/check-harness.sh`
  - `git diff --check`
- [x] 2026-04-08: Implemented the eighth reboot slice:
  - moved durable task records from `tracking/` into `execution/`
  - removed `--with-tracking`, `HARNESS_TASK_ROOT`, and legacy scratch support
  - renamed the scaffolder to `scripts/new-task.sh`
  - renamed the Stave continuation playbook to
    `memory/playbooks/stave-task-resume-and-local-execution-bridge.md`
  - deleted `claude-progress.txt`
- [x] 2026-04-08: Verified the eighth slice with:
  - `bash -n scripts/new-task.sh scripts/init-repo.sh scripts/init.sh scripts/check-harness.sh`
  - a temp run of `scripts/new-task.sh demo feature task-one --mode expanded`
  - a temp run of `scripts/init-repo.sh <tmp/project> --with-execution`
  - `scripts/summarize-evals.py`
  - `bash scripts/check-harness.sh`
  - `git diff --check`

## Decisions

- Decision: Treat this work as an expanded tracked task.
  Rationale: The reboot is inherently multi-session and needs a self-contained
  planning artifact that future sessions can continue without replaying chat
  history.
- Decision: Record the reboot as a draft direction in `ROADMAP.md`, but keep
  the detailed proposal in this task.
  Rationale: The roadmap should show the next active direction, while the task
  plan holds the full reasoning and staged execution detail.
- Decision: Default new durable task state to `execution/`.
  Rationale: The user does not want to preserve the `tracking` name long term,
  and the live harness should use one execution path instead of a split model.
- Decision: Remove the transitional compatibility layer once the migration is
  complete.
  Rationale: The user explicitly said compatibility is unnecessary, and the
  live harness is clearer when it uses one execution path and one scratch file.

## Verification

- Reviewed the current harness source-of-truth docs and support artifacts.
- `bash -n scripts/new-task.sh` passed.
- `bash -n scripts/check-harness.sh` passed.
- `bash scripts/check-harness.sh` passed for policy, hooks, scripts, skills,
  operational memory, and handoff structure.
- Verified with repo inspection that:
  - `learnings/` is still a flat static knowledge bucket.
  - `evals/results/` now has a first real result file.
  - the provided Stave task ids do not resolve inside `.agents`.
- Verified that `scripts/new-task.sh --mode expanded` now works in a
  temp directory without invoking `python3`, and it seeds `work-handoff.md`
  correctly.
- Verified that the latest `check-harness.sh` run passes including symlink
  checks for `~/.claude` and `~/.codex`.
- Verified that the active init/hook path now works without `python3` by
  exercising representative hook payloads and a temp-`HOME` init run.
- Verified that `scripts/hooks/on-stop-handoff.sh` still creates a snapshot
  and refreshes the `## Auto Snapshot` section in a temp workspace.
- Verified that `scripts/summarize-evals.py` now runs directly without
  `python3` and reports the recorded eval results correctly.
- No automated tests were needed beyond shell validation, scaffolding checks,
  and targeted hook smoke tests.

## Next Actions

1. Use `execution/` and `scripts/new-task.sh` for future substantial work.
2. Commit or push the validated harness changes when ready.

## Open Questions

- None.

## Changed Files

- AGENTS.md
- ARCHITECTURE.md
- CHANGELOG.md
- ROADMAP.md
- README.md
- work-handoff.md
- docs/instructions/CONTEXT_LOADING.md
- docs/instructions/ENGINEERING_GROWTH.md
- docs/instructions/TRACKING.md
- learnings/README.md
- memory/README.md
- memory/patterns/README.md
- memory/troubleshooting/README.md
- memory/troubleshooting/python3-command-line-tools-bootstrap-stub.md
- memory/playbooks/README.md
- memory/playbooks/eval-run-scoring-and-scorecard-update.md
- memory/playbooks/github-pr-review-and-follow-up.md
- memory/playbooks/slack-thread-to-task-and-jira-setup.md
- memory/playbooks/repo-bootstrap-and-handoff-hygiene.md
- memory/playbooks/harness-change-rollout-and-validation.md
- memory/playbooks/stave-task-resume-and-local-execution-bridge.md
- memory/playbooks/figma-design-to-implementation-and-visual-verification.md
- memory/decisions/README.md
- memory/decisions/2026-04-07-operating-model-reboot.md
- memory/decisions/2026-04-08-execution-memory-default-path.md
- memory/scorecard/README.md
- memory/scorecard/2026-04-baseline.md
- memory/scorecard/2026-04-07-first-playbooks-and-eval.md
- memory/scorecard/2026-04-08-python-free-eval-summary-and-second-resume-run.md
- memory/scorecard/2026-04-08-stave-bridge-and-prompt-refinement-eval.md
- memory/scorecard/2026-04-08-execution-default-and-figma-playbook.md
- evals/results/2026-04-08_codex_04.md
- evals/results/2026-04-08_codex_10.md
- evals/results/2026-04-07_codex_06.md
- evals/results/2026-04-08_codex_06.md
- scripts/check-harness.sh
- scripts/init.sh
- scripts/init-repo.sh
- scripts/hooks/pre-commit-lint.sh
- scripts/hooks/pre-write-secrets.sh
- scripts/hooks/post-write-format.sh
- scripts/hooks/on-stop-handoff.sh
- evals/README.md
- scripts/summarize-evals.py
- scripts/new-task.sh
- skills/the-progress-tracker/SKILL.md
- execution/sessions/2026-04-07_harness-reassessment/features/operating-model/tasks/reboot-plan/handoff.md
- execution/sessions/2026-04-07_harness-reassessment/features/operating-model/tasks/reboot-plan/plan.md
- execution/sessions/2026-04-07_harness-reassessment/features/operating-model/tasks/reboot-plan/verification.md
- execution/sessions/2026-04-07_harness-reassessment/features/operating-model/tasks/reboot-plan/execution-log.md

## Notes

Owner: jacob.kim
Execution Mode: expanded

The user asked to continue from the earlier Stave planning task, so this
session treated that request as a resume into the durable `reboot-plan` task
rather than as a fresh redesign request. The reboot now has real playbooks,
four real eval artifacts, a python-free active init/eval utility path, and no
remaining `tracking/` compatibility layer.

## Auto Snapshot

TODO: maintained by stop-time automation when available.
