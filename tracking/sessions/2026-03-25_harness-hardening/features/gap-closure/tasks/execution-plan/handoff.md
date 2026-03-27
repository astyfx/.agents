# Handoff

## Summary

Implemented the hardening pass for the harness.
The main outcomes are:
- `ARCHITECTURE.md` is now the authoritative structure/flow document
- `AGENTS.md` now requires future harness work to consult and update that doc
- secret protection is stronger and applies to both `Write` and `Edit`
- tracked-task handoff now has a durable path via `claude-progress.txt` and stop-time sync
- eval operations now have result scaffolding and summary scripts
- `init.sh` now seeds the runtime baseline so the harness is reproducible on new machines

## Open Issues

- No real benchmark results have been recorded yet in `evals/results/`
- `claude-progress.txt` is intentionally absent at the repo root when no active task is in progress
- Runtime files under `claude/` and `codex/` remain local/ignored; reproducibility now depends on `scripts/init.sh`

## Next Actions

1. Run 2-3 real benchmark tasks and save the first results under `evals/results/`
2. Commit and push this hardening pass when ready
3. For future harness changes, start from `ARCHITECTURE.md` before editing structure or flow
