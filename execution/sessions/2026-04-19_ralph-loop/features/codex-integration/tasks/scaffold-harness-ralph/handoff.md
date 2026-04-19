# Handoff

## Objective

Introduce a Codex-compatible Ralph loop into the harness so target repositories
can scaffold repo-local loop files and run fresh-context `codex exec`
iterations against a `scripts/ralph/prd.json`.

## Task Path

execution/sessions/2026-04-19_ralph-loop/features/codex-integration/tasks/scaffold-harness-ralph

## Current Status

Done

## Scope

- Add a reusable Codex Ralph loop skill.
- Add a deterministic scaffold script that installs repo-local `scripts/ralph/`
  assets.
- Wire the scaffold into `init-repo.sh`.
- Extend harness validation for the new files.

## Plan

- [x] Inspect `snarktank/ralph` and current Codex harness constraints.
- [x] Add the Codex Ralph loop skill and repo-local templates.
- [x] Add a scaffold helper and wire it into `init-repo.sh`.
- [x] Verify syntax, temp-repo scaffolding, and overall harness health.

## Progress

- [x] 2026-04-19: Task scaffold created.
- [x] 2026-04-19: Reviewed `snarktank/ralph` README, `ralph.sh`, `prompt.md`,
  `CLAUDE.md`, and the PRD conversion skill.
- [x] 2026-04-19: Added `the-ralph-loop` plus repo-local Ralph templates for Codex.
- [x] 2026-04-19: Added `scripts/scaffold-ralph-codex.sh` and `init-repo.sh`
  `--with-ralph-codex`.
- [x] 2026-04-19: Verified shell syntax, temp scaffolding flows, and
  `scripts/check-harness.sh`.

## Decisions

- Keep the target-repo loop self-contained under `scripts/ralph/` so the setup
  does not depend on personal `~/.agents` paths after scaffolding.
- Keep runtime Ralph state gitignored by default and ship only
  `prd.json.example` as the committed template.
- Adapt commit guidance to strict Conventional Commits instead of copying the
  upstream `feat: [Story ID] - [Story Title]` format verbatim.

## Verification

- `bash -n scripts/scaffold-ralph-codex.sh`
- `bash -n scripts/init-repo.sh`
- `bash -n skills/the-ralph-loop/assets/template/scripts/ralph/ralph-codex.sh`
- `bash scripts/scaffold-ralph-codex.sh <temp-repo>`
- `bash scripts/init-repo.sh <temp-repo> --with-execution --with-ralph-codex`
- `bash scripts/check-harness.sh`

## Next Actions

1. Scaffold the loop into a real project repo.
2. Fill in repo-specific checks in `scripts/ralph/CODEX.md`.
3. Do one real PRD-driven smoke run if deeper confidence is needed.

## Open Questions

- None yet.

## Changed Files

- scripts/check-harness.sh
- scripts/init-repo.sh
- scripts/scaffold-ralph-codex.sh
- skills/INDEX.md
- skills/the-ralph-loop/SKILL.md
- skills/the-ralph-loop/assets/template/scripts/ralph/CODEX.md
- skills/the-ralph-loop/assets/template/scripts/ralph/prd.json.example
- skills/the-ralph-loop/assets/template/scripts/ralph/ralph-codex.sh

## Notes

Owner: jacob.kim
Execution Mode: expanded

## Auto Snapshot

- Timestamp: 2026-04-19_100153
- Working Directory: /Users/jacob.kim/.agents
- Snapshot File: /Users/jacob.kim/.agents/claude/session-snapshots/2026-04-19_100153.md
- Recent Git Status:
```text
 M scripts/check-harness.sh
 M scripts/init-repo.sh
 M skills/INDEX.md
?? execution/sessions/2026-04-19_ralph-loop/
?? scripts/scaffold-ralph-codex.sh
?? skills/the-ralph-loop/
?? skills/the-ralph-prd/
```

