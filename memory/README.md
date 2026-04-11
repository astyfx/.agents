# Memory

Operational memory for the `.agents` harness.

This directory is the durable knowledge layer for information that should
improve future work across sessions, projects, Claude, and Codex.

## Memory Types

- `patterns/`
  - stable cross-project engineering heuristics and reusable guidance
- `troubleshooting/`
  - recurring failure modes, root causes, workarounds, and fixes
- `playbooks/`
  - repeatable workflows and integration procedures
- `decisions/`
  - durable harness decisions and ADR-style records
- `scorecard/`
  - measurable baselines and periodic improvement snapshots

## Boundaries

- Use `execution/` for default execution memory tied to one active task.
- Use `work-handoff.md` for session scratch state.
- Use `memory/` only for knowledge that should compound across tasks.
- `learnings/` remains readable as archived historical reference material.

## Non-Goals

- `memory/` is not a raw-source wiki, transcript dump, or catch-all notes bucket.
- Do not auto-ingest chat logs, tool output, or broad source corpora into
  `memory/` by default.
- If automation is added later, prefer draft generation with explicit review
  before durable publication.

## Ingestion Rules

- Add records only when they would have changed future work.
- Prefer one clear record over many thin notes.
- Promote conclusions, procedures, and failure modes, not raw transcripts.
- Capture real failure modes and real decisions, not aspirational ideas.
- Retire or supersede stale memory explicitly when the harness changes.
