# Plan

## Context

The user wants the harness to support a Codex version of the Ralph loop from
`snarktank/ralph`. The adaptation needs to work with current harness rules:

- strict Conventional Commit enforcement
- repo-local, team-committable scaffolding
- optional compatibility with `work-handoff.md` and `execution/`
- no dependence on personal paths after scaffolding

## Execution Plan

1. Review the upstream Ralph assets and identify what must change for Codex.
2. Add a Codex-specific skill plus repo-local template assets.
3. Add a harness helper that installs those assets into target repos.
4. Wire the helper into `init-repo.sh`.
5. Validate via syntax checks, temp-repo scaffolding, and harness health checks.

## Done Criteria

- A Codex Ralph loop skill exists in `skills/`.
- A scaffold command can install runnable repo-local Ralph files.
- `init-repo.sh` can include the scaffold on demand.
- Harness validation checks cover the new surface.
- Basic smoke verification passes.

## Risks / Rollback

- Risk: the loop depends on Codex CLI flags that drift over time.
  Fallback: keep the prompt and scaffold isolated so only the repo-local loop
  script needs updating.
