# ADR — 2026-04-09 — Curated Memory And Selective Evals

status: accepted

## Context

The reboot clarified the main artifact lanes, but two ambiguities remained:

- whether `memory/` should evolve into an auto-ingested LLM wiki
- whether `evals/` should keep growing as a generic run log

The actual workflow in this harness is execution-heavy and resume-heavy. The
main value comes from:

- durable task continuation via `execution/`
- a small number of reusable operational records in `memory/`
- eval evidence that informs routing, workflow, or harness decisions

Broad auto-ingestion would likely increase note volume faster than it improves
future execution quality.

## Decision

- Keep `memory/` curated by default.
- Do not auto-ingest chat logs, tool output, or broad source corpora into
  durable memory.
- Treat `learnings/` as an archive-only legacy lane.
- Keep `evals/`, but use them selectively for change validation, workflow
  baselines, routing checks, or agent comparisons.
- Require new eval results to record what decision or change they are meant to
  inform.

## Consequences

- The harness stays lighter and higher-signal than a full auto-maintained wiki.
- Fewer eval runs are expected, but each should be easier to interpret later.
- Future sessions can distinguish durable operational knowledge from raw work
  history more reliably.

## Follow-Up Work

- Backfill decision context on existing real eval results.
- Prefer auto-draft plus review if memory capture automation is added later.
- Retire stale `learnings/` files gradually as equivalent `memory/` records
  become available.
