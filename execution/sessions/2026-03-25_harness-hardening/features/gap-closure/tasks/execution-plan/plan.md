# Plan

## Scope

Plan the next improvement pass for the harness based on the current review of gaps
remaining after the v2 upgrade. Focus on turning passive documentation and partial
guardrails into behavior that is actually enforced or reliably invoked.

## Assumptions

- The current v2 upgrade is directionally correct and should be hardened, not reverted.
- The user wants to improve the harness incrementally without inflating `AGENTS.md`.
- The best next work is to close wiring and enforcement gaps before adding more layers.
- Claude and Codex should remain near-parity at the workflow level, even if mechanisms differ.

## Decomposition

1. Wire passive artifacts into active policy/routing:
   - make `evals/`, `learnings/`, and `ROUTING.md` discoverable from central policy
   - define when agents should read them
2. Harden security enforcement:
   - upgrade secret detection from filename-only to filename + content + tracked-file awareness
3. Make handoff durable:
   - connect stop-time snapshots to tracked `handoff.md` and `claude-progress.txt`
4. Improve eval usefulness:
   - keep the manual tasks, but add a result template generator and summary script
5. Fix portability rough edges:
   - remove hardcoded owner values
   - ensure health checks validate wiring, not only file presence
6. Defer non-critical expansion:
   - do not add more skills/subagents until the above gaps are closed

## Prioritized Gap List

### Priority 1 — Wiring Gaps

Symptoms:
- `evals/`, `learnings/`, and `ROUTING.md` exist, but `AGENTS.md` does not route agents to them.
- `ARCHITECTURE.md` describes them as active layers, but behavior still depends on a human remembering they exist.

Why first:
- This is the highest leverage fix.
- It turns existing assets into working parts of the harness without adding new subsystems.

Deliverables:
- Add `ROUTING.md` to the central document map or routing rules in `AGENTS.md`
- Add a short policy for when to consult `learnings/`
- Add a short policy for when to run or consult `evals/`

### Priority 2 — Security Hardening

Symptoms:
- `pre-write-secrets.sh` blocks only suspicious filenames.
- A real secret can still be written into normal tracked files like `config.ts`, `README.md`, or `settings.json`.

Why second:
- This is the biggest remaining real-world failure mode.

Deliverables:
- Extend secret checks to inspect content for common credential prefixes and private-key markers
- Check whether the destination file is tracked or likely to be committed
- Keep `.env.example` / `.sample` allowlists intact

### Priority 3 — Durable Handoff

Symptoms:
- `on-stop-handoff.sh` writes a runtime snapshot, but it does not update tracking `handoff.md`
- The architecture implies stronger session continuity than is currently enforced

Why third:
- The repo now has tracking and progress machinery; the stop flow should actually feed it

Deliverables:
- Define a minimal protocol for locating the active tracking task from `claude-progress.txt`
- Update stop-time automation to append or refresh `handoff.md` when the task path is known
- Keep fail-safe behavior if no task is active

### Priority 4 — Eval Operations

Symptoms:
- Benchmarks now exist, but running and summarizing them is still manual
- There is no scoreboard or regression view

Why fourth:
- The eval corpus is already useful; small operational glue will make it sustainable

Deliverables:
- `scripts/new-eval-result.sh` to scaffold result files
- `scripts/summarize-evals.sh` or a small Python script to roll up pass rate, rework count, and policy compliance by agent
- A minimal baseline run on Claude and Codex for 2-3 tasks

### Priority 5 — Portability Cleanup

Symptoms:
- `new-task.sh` hardcodes `Owner: jacob.kim`
- `check-harness.sh` checks file presence but not enough semantic wiring

Why fifth:
- Lower risk than the first four, but important if the harness is meant to be stable and portable

Deliverables:
- Use `$USER` or an explicit argument in tracking scaffolds
- Extend `check-harness.sh` to validate:
  - hook commands are present in `claude/settings.json`
  - `AGENTS.md` references core docs intentionally
  - required fields exist in `claude-progress.txt` when present

## Recommended Implementation Order

### Pass 1 — Close correctness gaps

- Update `AGENTS.md`
- Update `docs/instructions/ROUTING.md` if needed
- Improve `pre-write-secrets.sh`
- Fix `new-task.sh`

Expected effort: 60 to 90 minutes

### Pass 2 — Connect handoff and progress

- Extend `the-progress-tracker` format to carry an active tracking task path
- Update `on-stop-handoff.sh` to sync a minimal handoff when possible
- Update `check-harness.sh` accordingly

Expected effort: 60 to 90 minutes

### Pass 3 — Make evals operable

- Add result scaffolding script
- Add summary script
- Run 2 to 3 baseline evals

Expected effort: 90 to 120 minutes

## Do Not Do Yet

- Do not add more subagent roles yet
- Do not add more skills yet
- Do not build a plugin/marketplace layer yet
- Do not expand memory beyond the current `learnings/` set until routing is wired

## Done Criteria

- `AGENTS.md` or its linked docs explicitly route to `evals/`, `learnings/`, and `ROUTING.md`
- Secret protection blocks more than suspicious filenames
- Handoff flow updates durable task artifacts when an active task is known
- Evals have basic tooling for result creation and summary
- Tracking scaffolds are no longer user-hardcoded
- Health checks validate wiring, not just file existence

## Done Criteria

TODO: concrete, observable acceptance criteria.
