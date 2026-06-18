# 2026-04-08 Execution Default and Figma Playbook

## Metrics

- Always-on core docs:
  - `AGENTS.md`: 113 lines
  - `docs/instructions/RESPONSE_STYLE.md`: 26 lines
  - total default core: 139 lines
- Optional context-loading rule file:
  - `docs/instructions/CONTEXT_LOADING.md`: 57 lines
- Real eval result files: 4
- Active playbooks under `memory/playbooks/`: 7
- Troubleshooting records: 1
- Decision records: 2
- Legacy `learnings/*.md` topic files: 7
- `scripts/summarize-evals.py` aggregate:
  - codex 4 runs / 4 pass / 0 partial / 0 fail

## Notes

- New substantial work now defaults to `execution/`, while older task paths
  under `tracking/` remain resumable in place.
- The harness now has a connector-heavy Figma implementation playbook, but it
  still needs a real validated run to prove the workflow, not just document it.
- The main evidence gap is no longer path naming; it is still connector-heavy
  validation and, if needed later, cross-agent evidence.
