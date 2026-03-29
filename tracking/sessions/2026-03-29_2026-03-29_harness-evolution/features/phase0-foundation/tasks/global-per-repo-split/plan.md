# Plan

## Scope

Implement the initial harness evolution plan derived from Codex use-case analysis.
This task covers the global vs per-repo split, Codex parity assumptions, new reusable
skills/subagents/evals, and persistent documentation for future sessions.

## Task Path

tracking/sessions/2026-03-29_2026-03-29_harness-evolution/features/phase0-foundation/tasks/global-per-repo-split

## Assumptions

- Codex can support subagents and plugin-style integrations closely enough to mirror
  Claude's workflow-level behavior.
- `.agents` remains a personal global harness; project-specific settings should be
  scaffolded into each repository instead of stored here.
- Future agents need durable artifacts that explain current state, rationale, and next
  evolution steps without relying on chat history.

## Decomposition

1. Define architecture decisions and roadmap for harness evolution.
2. Add per-repo scaffolding via `scripts/init-repo.sh`.
3. Extend shared skills, subagents, and eval tasks to cover the prioritized SaaS workflows.
4. Update architecture, routing, index, and health-check documents.
5. Verify the harness and record durable handoff artifacts.

## Done Criteria

- `ROADMAP.md` exists and reflects the current phased plan and architecture decisions.
- `scripts/init-repo.sh` scaffolds per-repo bridge files and optional tracking/CI assets.
- New skills, subagents, and eval tasks are present and indexed.
- Shared docs and health checks reflect the new structure.
- Tracking artifacts and progress state describe the completed work and next step.
