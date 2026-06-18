# 2026-04-07 First Playbooks and Eval

## Metrics

- Always-on core docs:
  - `AGENTS.md`: 113 lines
  - `docs/instructions/RESPONSE_STYLE.md`: 26 lines
  - total default core: 139 lines
- Optional context-loading rule file:
  - `docs/instructions/CONTEXT_LOADING.md`: 57 lines
- Real eval result files: 1
- Active playbooks under `memory/playbooks/`: 4
- Troubleshooting records: 1
- Decision records: 1
- Legacy `learnings/*.md` topic files: 7

## Notes

- The reboot now has one real eval artifact instead of only task templates.
- `memory/playbooks/` is no longer a placeholder directory; it contains shared
  workflows for GitHub PR review, Slack-to-task setup, repo bootstrap, and
  harness rollout.
- The next evidence gap is still the lack of run history beyond a single
  cross-session resume result.
