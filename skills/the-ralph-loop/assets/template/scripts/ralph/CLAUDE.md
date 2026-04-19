# Ralph Agent Instructions

You are an autonomous coding agent running inside a Ralph loop for this
repository. Each iteration is a fresh Claude invocation.

## Loop State

Read these files first:

1. `scripts/ralph/prd.json`
2. `scripts/ralph/progress.txt` if it exists. Check the `## Codebase Patterns`
   section before anything else.
3. Nearby `AGENTS.md`, `CONVENTIONS.override.md`, `LIBRARIES.override.md`,
   `README.md`, and project config files that define how this repo works.

If `work-handoff.md` exists, read it. If it points at an `execution/...`
directory, read that task `handoff.md` too. Keep those files aligned when you
make meaningful progress, but do not depend on them existing.

## Project-Specific Quality Commands

Replace this section after scaffolding so the loop does not have to guess.

- Typecheck: TODO
- Lint: TODO
- Tests: TODO
- Build: TODO
- Browser verification: TODO if available

If the commands are still `TODO`, infer the smallest correct checks from the
repo's package manager scripts, CI config, or README.

## Your Task

1. Ensure you are on the branch named by `branchName` in `scripts/ralph/prd.json`.
   Create it from the repo's mainline branch if needed.
2. Pick the highest-priority story where `passes: false`.
3. Implement only that one story.
4. Run the minimum checks required by its acceptance criteria.
5. Update nearby `AGENTS.md` files only when you discovered reusable,
   cross-story knowledge.
6. If checks pass, commit tracked code changes with a Conventional Commit.
7. Update `scripts/ralph/prd.json` to mark the story as passed.
8. Append a concise progress entry to `scripts/ralph/progress.txt`.

## Commit Rules

- Use a valid Conventional Commit.
- Prefer `feat(ralph): ...` for feature stories.
- Use `fix(ralph): ...`, `docs(ralph): ...`, or `chore(ralph): ...` when that
  better matches the actual change.
- Keep the subject imperative and concise.

Example:

```text
feat(ralph): implement US-001 priority field
```

## Progress Format

Append to `scripts/ralph/progress.txt`. Do not replace the file. Keep the
latest general learnings in a `## Codebase Patterns` section near the top.

Use this entry format:

```markdown
## [YYYY-MM-DD HH:MM] - [Story ID]
- Implemented:
- Files changed:
- Checks:
- Commit:
- Learnings for future iterations:
  - Reusable pattern or gotcha
---
```

Only add to `## Codebase Patterns` when the learning is broadly reusable.

## Story Boundaries

- Work on one story per iteration.
- Keep changes focused and minimal.
- Do not mark a story as passed if its checks failed.
- If the story changes UI, do browser verification when tooling exists.
- If browser tooling does not exist, note the manual verification gap in
  `progress.txt` and in the story `notes`.

## Stop Condition

After finishing a story, check whether every story in `scripts/ralph/prd.json`
now has `passes: true`.

If all stories are complete, end with:

```text
<promise>COMPLETE</promise>
```

Otherwise, end normally so the outer loop can start the next fresh iteration.
