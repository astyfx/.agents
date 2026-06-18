# archive

Retired harness subsystems. Kept for reference; not part of the active harness
and not loaded or validated. Full history is in `git log`.

- `evals/` — eval task corpus + run results. Dormant since 2026-04 (codex-only,
  never fed on the Claude side). Retired 2026-06-19 to stop presenting a dead
  benchmark as live.
- `scorecard/` — harness scorecard snapshots. Generated artifact that was not
  steering decisions.
- `CHANGELOG.md` — the old hand-maintained change log. History now lives in
  `git log`; the harness no longer maintains a parallel narrative.
- `scripts/` — eval/scorecard helper scripts (`new-eval-result.sh`,
  `summarize-evals.pl`, `scorecard.sh`).
- `ENGINEERING_GROWTH.md` — agentic-engineering coaching doc. Was never routed
  (no Core Docs / CONTEXT_LOADING entry) and overlapped the core behavioral
  principles; retired 2026-06-19.

To revive any of these, `git mv` it back and re-add the relevant references.
