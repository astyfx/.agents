# Verification

## Checks

- Reviewed the current harness docs and repo state:
  - `AGENTS.md`
  - `ARCHITECTURE.md`
  - `ROADMAP.md`
  - `CHANGELOG.md`
  - `README.md`
  - `docs/instructions/CONTEXT_LOADING.md`
  - `docs/instructions/TRACKING.md`
  - `docs/instructions/ROUTING.md`
  - `learnings/README.md`
  - `memory/README.md`
  - `work-handoff.md`
  - recent tracking task records
- `bash -n scripts/new-task.sh`
- `bash -n scripts/check-harness.sh`
- Verified with repo inspection that:
  - `learnings/` is still a flat topic set
  - the Stave task ids named by the user do not exist in `.agents`
- Ran `bash scripts/check-harness.sh`:
  - policy, hooks, scripts, skills, evals, memory, and work-handoff checks
    passed
  - symlink checks also passed in the current environment
- Ran `scripts/new-task.sh --mode expanded` in `/tmp/agents-harness-test`
  - created the expected execution-memory files
  - seeded `work-handoff.md`
  - required no `python3`
- Added reusable workflow records under `memory/playbooks/` for:
  - GitHub PR review and follow-up
  - Slack thread to task and Jira setup
  - repo bootstrap and handoff hygiene
  - harness change rollout and validation
- Created `evals/results/2026-04-07_codex_06.md` as the first real eval result
  using this session's cross-session resume behavior as the scored run
- Added `memory/scorecard/2026-04-07-first-playbooks-and-eval.md`
- `bash -n scripts/init.sh scripts/check-harness.sh scripts/hooks/pre-commit-lint.sh scripts/hooks/pre-write-secrets.sh scripts/hooks/post-write-format.sh scripts/hooks/on-stop-handoff.sh`
- Ran representative hook payload smoke tests:
  - invalid `git commit -m` is blocked
  - valid Conventional Commit passes
  - secret-like content to a tracked file is blocked
  - placeholder content in `.env.example` passes
  - post-write hook accepts `path` payloads without `python3`
- Ran `scripts/hooks/on-stop-handoff.sh` in a temp workspace:
  - created a session snapshot under `~/.agents/claude/session-snapshots/`
  - refreshed the tracked task's `## Auto Snapshot` section
- Ran `bash scripts/init.sh` with a temp `HOME` and then
  `bash scripts/check-harness.sh`
  - `claude/settings.json` was populated correctly
  - the harness check passed in the temp environment
- Ran `scripts/summarize-evals.py`
  - direct execution works without `python3`
  - the aggregate view reports 4 codex runs / 4 pass / 0 fail
- Ran `bash scripts/check-harness.sh`
  - policy, hooks, scripts, skills, evals, memory, and work-handoff checks
    passed
  - `evals/results/` now contains four real runs
- Ran `git diff --check`
  - no whitespace or patch formatting issues found
- No automated tests were required beyond shell validation, scaffolding checks,
  and targeted hook smoke tests.
- Created `evals/results/2026-04-08_codex_06.md` as a second real eval result
  for the cross-session resume workflow
- Created `evals/results/2026-04-08_codex_04.md` as a real code-review eval
  result to diversify the benchmark history
- Added `memory/scorecard/2026-04-08-python-free-eval-summary-and-second-resume-run.md`
- Added `memory/playbooks/eval-run-scoring-and-scorecard-update.md`
- Created `evals/results/2026-04-08_codex_10.md` as a real prompt-refinement
  eval result using the `the-refine-prompt` behavior
- Added `memory/playbooks/stave-task-resume-and-local-execution-bridge.md`
- Added `memory/scorecard/2026-04-08-stave-bridge-and-prompt-refinement-eval.md`
- Added `memory/decisions/2026-04-08-execution-memory-default-path.md`
- Added
  `memory/playbooks/figma-design-to-implementation-and-visual-verification.md`
- Added `memory/scorecard/2026-04-08-execution-default-and-figma-playbook.md`
- Ran `bash -n scripts/new-task.sh scripts/init-repo.sh scripts/init.sh scripts/check-harness.sh`
- Ran `scripts/new-task.sh demo feature task-one --mode expanded` in a
  temp directory
  - created `execution/sessions/...`
  - updated `work-handoff.md` with the new execution-memory task path
- Ran `scripts/init-repo.sh <tmp/project> --with-execution`
  - created `.claude/`, `.codex/`, and `execution/sessions/`
- Re-ran `scripts/summarize-evals.py`
  - the aggregate view still reports 4 codex runs / 4 pass / 0 fail
- Re-ran `bash scripts/check-harness.sh`
  - the new `execution/`-default checks passed
- Re-ran `git diff --check`
  - no whitespace or patch formatting issues found
- Renamed `scripts/new-task.sh` as the canonical scaffolder and confirmed the
  old script path is no longer used by the live harness
- Moved durable task records from `tracking/` into `execution/`
- Deleted `claude-progress.txt`

## Review Notes

- The reboot plan is intentionally additive-first. It describes a migration path
  rather than performing a disruptive rename or directory move in the same
  session.
- The default durable task-state root is now `execution/`, and the live harness
  no longer depends on `tracking/`.
- The improvement loop is no longer empty; connector-heavy workflow validation
  is a future optimization, not a blocker for this reboot task.
- `memory/playbooks/` is now operational rather than placeholder-only.
- The active init/eval utility path no longer depends on `python3`.
