# Handoff

## Objective

Add an attributed behavioral-principles layer to the core harness policy so the
source can be identified and revisited later.

## Task Path

execution/sessions/2026-04-14_harness-governance/features/policy/tasks/karpathy-principles-provenance

## Current Status

Done

## Scope

- Add a compact, always-on behavior section to `AGENTS.md`.
- Preserve explicit provenance to the external source repository.
- Record the adoption rationale and re-review triggers in `memory/decisions/`.

## Plan

- [x] Read harness maintenance docs before changing shared policy.
- [x] Add an attributed adaptation of the four behavioral principles.
- [x] Record the provenance and review criteria in an ADR.
- [x] Run harness checks and whitespace checks.

## Progress

- [x] 2026-04-14: Task scaffold created.
- [x] 2026-04-14: Reviewed `ARCHITECTURE.md`, `ROADMAP.md`, and `TRACKING.md`
  before editing the harness.
- [x] 2026-04-14: Added `Behavioral Principles` to `AGENTS.md` with explicit
  attribution to `forrestchang/andrej-karpathy-skills`.
- [x] 2026-04-14: Added an ADR recording source material, adaptation rationale,
  and review triggers.
- [x] 2026-04-14: Verified with `bash scripts/check-harness.sh` and
  `git diff --check`.

## Decisions

- Keep provenance visible in the always-on policy, not only in a deep memory
  file.
- Adapt the external guidance to the harness instead of importing the external
  `CLAUDE.md` verbatim.
- Keep the new section below user instructions and hard safety invariants.

## Verification

- `bash scripts/check-harness.sh`
- `git diff --check`

## Next Actions

1. Commit the policy and ADR changes when ready.

## Open Questions

- None yet.

## Changed Files

- AGENTS.md
- memory/decisions/2026-04-14-karpathy-guidelines-attribution-in-core-policy.md

## Notes

Owner: jacob.kim
Execution Mode: lite
Source preserved in both the always-on policy and the ADR so future sessions
can review adoption without searching chat history.

## Auto Snapshot

TODO: maintained by stop-time automation when available.
