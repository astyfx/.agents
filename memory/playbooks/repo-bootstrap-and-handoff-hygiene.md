# Repo Bootstrap and Handoff Hygiene

## Trigger

Use when onboarding a new repository into the harness or when a repo lacks
team-safe agent scaffolding and session continuity.

## Inputs

- target repository path
- whether the repo needs execution-memory scaffolding
- whether CI templates should be added
- current repo conventions and existing agent files

## Required Tools

- `scripts/init-repo.sh`
- project-level scans for `README`, `package.json`, `pyproject.toml`,
  `Cargo.toml`, and repo-local policy files
- `the-progress-tracker` for multi-session work

## Steps

1. Inspect the target repo for existing conventions and local agent policy
   files before scaffolding anything.
2. Decide whether the repo needs:
   - base agent bridge files only
   - `execution/` support for multi-session work
   - CI workflow helpers
3. Run `scripts/init-repo.sh` with the minimum flags needed.
4. Review generated files to confirm they are team-safe and contain no personal
   home-directory paths.
5. Ensure local scratch artifacts stay uncommitted:
   - `work-handoff.md`
   - `.claude/settings.local.json`
   - any repo-local personal override files
6. If the task is substantial, initialize or update `work-handoff.md` and set
   the active tracking path when one exists.
7. On session stop, roll forward the current state into `work-handoff.md` and
   the tracked `handoff.md`.

## Expected Artifacts

- `.claude/CLAUDE.md`
- `.claude/settings.json`
- `.codex/AGENTS.md`
- `CONVENTIONS.override.md`
- `LIBRARIES.override.md`
- optional `execution/sessions/`
- current `work-handoff.md` state for ongoing work

## Verification

- confirm generated files are committable by teammates without `~/.agents`
- confirm repo-local conventions are not overwritten blindly
- verify `.gitignore` or local policy prevents scratch-state leakage

## Rollback Notes

- if the repo already has stronger local conventions, prefer adapting the
  bridge files instead of regenerating everything
- never replace existing tracked files without reading them first
