# 2026-04-08 Python-Free Eval Summary and Second Resume Run

## Metrics

- Always-on core docs:
  - `AGENTS.md`: 113 lines
  - `docs/instructions/RESPONSE_STYLE.md`: 26 lines
  - total default core: 139 lines
- Optional context-loading rule file:
  - `docs/instructions/CONTEXT_LOADING.md`: 57 lines
- Real eval result files: 3
- Active playbooks under `memory/playbooks/`: 5
- Troubleshooting records: 1
- Decision records: 1
- Legacy `learnings/*.md` topic files: 7
- `scripts/summarize-evals.py`:
  - direct execution works without `python3`
  - current aggregate: codex 3 runs / 3 pass / 0 partial / 0 fail

## Notes

- The active portability question around `scripts/summarize-evals.py` is now
  resolved: the script remains at the same path for compatibility, but its
  implementation no longer requires Python.
- The eval history is no longer limited to repeated task `06`; it now includes
  a code-review benchmark (`04`) as well as cross-session resume runs.
- The next evidence gap is broader workflow and agent diversity, not basic run
  count or summary portability.
