# Handoff

## Objective

Refactor harness tracking so the default is a single durable task record instead
of a mandatory multi-file artifact bundle.

## Task Path

execution/sessions/2026-04-06_tracking-refactor/features/lightweight-tracking/tasks/simplify-policy

## Current Status

Done

## Scope

- Simplify `TRACKING.md` to a lite-by-default model.
- Update the task scaffolder and dependent skills/docs to match.
- Preserve `work-handoff.md` and `tracking/.../handoff.md` compatibility.

## Plan

- [x] Research external agent-workflow patterns and compare them to the current harness.
- [x] Define a lite default with optional expanded artifacts.
- [x] Refactor tracking docs, scaffolder, and dependent workflow docs.
- [x] Run validation and close the task record.

## Progress

- [x] 2026-04-06: Reviewed `ARCHITECTURE.md`, `ROADMAP.md`, and current
  tracking dependencies before editing the harness.
- [x] 2026-04-06: Compared the current design with OpenAI Codex docs, OpenAI
  harness-engineering guidance, Task Master, and AgentOS patterns.
- [x] 2026-04-06: Rewrote tracking guidance around a single canonical
  `handoff.md` and made deep artifacts opt-in.
- [x] 2026-04-06: Updated the scaffolder, routing docs, reviewer guidance, and
  tracking-related skills to use the lighter model.
- [x] 2026-04-06: Added `new-task.sh --mode expanded` so the optional
  deep artifacts are scaffolded only when explicitly requested.

## Decisions

- Decision: Keep `tracking/.../handoff.md` as the durable canonical file.
  Rationale: This preserves hook and skill compatibility while removing the
  multi-file burden.
- Decision: Do not introduce a brand-new task file name.
  Rationale: Reducing artifact count solves the main problem without adding a
  migration burden across hooks, skills, and existing tracked work.

## Verification

- `bash -n scripts/new-task.sh scripts/init-repo.sh scripts/check-harness.sh scripts/hooks/on-stop-handoff.sh scripts/init.sh` passed.
- `bash scripts/new-task.sh demo feature expanded-task --mode expanded` in a temp directory created `handoff.md`, `plan.md`, `verification.md`, and `execution-log.md`, and seeded `work-handoff.md` with expanded-mode guidance.
- `bash scripts/check-harness.sh` passed.

## Next Actions

1. Review the diff and commit the lightweight tracking refactor when ready.

## Open Questions

- None.

## Changed Files

- AGENTS.md
- ARCHITECTURE.md
- CHANGELOG.md
- README.md
- docs/instructions/TRACKING.md
- docs/instructions/ROUTING.md
- scripts/init-repo.sh
- scripts/new-task.sh
- skills/the-build-fixer/SKILL.md
- skills/the-progress-tracker/SKILL.md
- skills/the-refactoring-planner/SKILL.md
- skills/the-slack-to-task/SKILL.md
- subagents/reviewer/AGENT.md

## Notes

The existing directory layout stays the same. Only the default artifact model
changes: one file by default, deeper docs only when justified.

## Auto Snapshot

TODO: maintained by stop-time automation when available.
