# ADR — 2026-04-07 Operating Model Reboot

## Status

Accepted

## Context

The harness had enough surface area but not enough compounding behavior.
`tracking/` had already been simplified, but it still risked becoming an
overloaded memory bucket. `learnings/` was static. `evals/` existed without
driving decisions. Repeated AI failure modes were still disappearing into chat
history.

## Decision

- Keep the core prompt thin and move situational detail behind explicit loading
  rules.
- Treat `tracking/` as execution memory only.
- Introduce `memory/` as the primary operational memory layer.
- Keep `learnings/` as a legacy compatibility lane during migration.
- Require real failure modes and measurable baselines to feed future harness
  changes.

## Consequences

- Harness maintenance now includes context-loading and memory-boundary updates.
- Durable knowledge can accumulate without bloating `AGENTS.md`.
- Future sessions have a stable place to put troubleshooting notes, decisions,
  and scorecards.
- Some scripts and docs still need follow-up migration into the new model.

## Follow-Up

- continue migrating reusable guidance from `learnings/` into `memory/`
- add playbook records for high-value integrations
- grow the scorecard from baseline into a recurring review loop
