# 2026-04-08 Stave Bridge and Prompt-Refinement Eval

## Metrics

- Always-on core docs:
  - `AGENTS.md`: 113 lines
  - `docs/instructions/RESPONSE_STYLE.md`: 26 lines
  - total default core: 139 lines
- Optional context-loading rule file:
  - `docs/instructions/CONTEXT_LOADING.md`: 57 lines
- Real eval result files: 4
- Active playbooks under `memory/playbooks/`: 6
- Troubleshooting records: 1
- Decision records: 1
- Legacy `learnings/*.md` topic files: 7
- `scripts/summarize-evals.py` aggregate:
  - codex 4 runs / 4 pass / 0 partial / 0 fail
  - benchmark task types now include `04`, `06`, and `10`

## Notes

- The harness now has an explicit Stave-to-local continuation playbook based on
  the workflow repeatedly used in this reboot task.
- Eval history now covers code review, cross-session resume, and prompt
  refinement instead of staying clustered around a single workflow.
- The main evidence gap is now agent diversity and connector-heavy workflow
  coverage, not prompt refinement or eval summary portability.
