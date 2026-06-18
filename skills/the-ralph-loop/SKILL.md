---
name: the-ralph-loop
description: "Ralph-style autonomous multi-story execution with fresh agent context per iteration. Use ONLY when work decomposes into a PRD of independent, verifiable stories and the user wants fresh Claude/Codex agents spawned until every story passes; NOT for scored single-target refinement (use the-improvement-loop). Triggers 'ralph loop', 'ralph 설정', 'prd.json 실행'."
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "ralph loop 설정해줘"
  - "set up a ralph loop for this repo"
  - "run this PRD through a ralph loop with claude"
  - "autonomous loop with fresh codex exec iterations"
  - "codex용 ralph loop 설정해줘"
  - "prd.json 기반으로 끝까지 돌려줘"
  - "spawn fresh agents until all stories done"
---

# The Ralph Loop

Fresh-context autonomous execution for Claude or Codex. Each iteration is a
new agent invocation, and the loop advances one small story at a time.

## Use This Skill When

- The user wants a Ralph-style autonomous loop (Claude or Codex).
- The work can be split into small, independently verifiable stories.
- A fresh agent context per iteration is a feature, not a problem.
- The user wants setup plus an actual runnable loop, not just a prompt.

## Do Not Use This Skill When

- The task is a one-off fix that should be implemented directly.
- The work is too ambiguous to decompose into verifiable stories first.
- A single story would still need a large multi-hour context window.

## What This Skill Produces

Scaffold repo-local loop files under `scripts/ralph/`:

- `scripts/ralph/ralph.sh` — unified runner supporting `--tool claude|codex`
- `scripts/ralph/CLAUDE.md` — per-iteration prompt for Claude
- `scripts/ralph/CODEX.md` — per-iteration prompt for Codex
- `scripts/ralph/prd.json.example`

Runtime state stays local by default:

- `scripts/ralph/prd.json`
- `scripts/ralph/progress.txt`
- `scripts/ralph/archive/`
- `scripts/ralph/.last-branch`
- `scripts/ralph/last-response.txt`

The scaffold script also adds those runtime files to `.gitignore`.

## Default Workflow

### 1. Scaffold the loop

Use the harness helper:

```bash
bash ~/.agents/scripts/scaffold-ralph-codex.sh /path/to/project
```

Or during repo bootstrap:

```bash
bash ~/.agents/scripts/init-repo.sh /path/to/project --with-ralph-codex
```

### 2. Create `scripts/ralph/prd.json`

Use the `the-ralph-prd` skill to generate and convert a PRD, or write it
directly. Follow Ralph sizing rules:

- one story must fit in one fresh agent iteration
- order by dependency (schema → backend → UI)
- acceptance criteria must be verifiable
- always include typecheck or equivalent checks
- include browser verification for UI work when tooling exists

### 3. Customize the prompt file

Fill in project-specific quality commands in `CLAUDE.md` or `CODEX.md`:

- Typecheck: `npm run typecheck` or equivalent
- Tests: `npm test` or equivalent
- Lint: `npm run lint` or equivalent

### 4. Run the loop

```bash
# With Claude (default)
./scripts/ralph/ralph.sh --tool claude 10

# With Codex
./scripts/ralph/ralph.sh --tool codex 10
```

The loop will:

1. spawn a fresh agent invocation
2. pick the highest-priority story with `passes: false`
3. implement only that story
4. run checks
5. commit tracked code changes with a Conventional Commit
6. update `prd.json` and `progress.txt`
7. stop when it sees `<promise>COMPLETE</promise>`

## Story Design Rules

- Keep stories small enough to finish in one iteration.
- Put schema or backend dependencies before UI stories.
- Avoid vague criteria like "works correctly".
- Prefer one concrete user-visible or system-visible change per story.

## Tool Notes

### Claude
- Invoked as `claude --dangerously-skip-permissions --print < CLAUDE.md`
- Runs from the project root directory
- Reads `scripts/ralph/prd.json` and `scripts/ralph/progress.txt`

### Codex
- Invoked as `codex exec --full-auto -C <project-root> ...  < CODEX.md`
- Prefer sandboxed automation first; only relax sandboxing deliberately
- Same prompt structure as CLAUDE.md

### Both
- Keep commits Conventional Commit compliant. Defaults to `feat(ralph): ...`
  but can use `fix(ralph): ...`, `docs(ralph): ...`, or `chore(ralph): ...`
- If the repo already uses `work-handoff.md` or `execution/`, keep them
  aligned when they exist, but the loop must remain self-contained.

## Done Definition

This skill is complete when:

- the repo-local scaffold exists
- `prd.json` is present and story-sized correctly
- the prompt has project-specific verification commands
- the loop is runnable with `./scripts/ralph/ralph-codex.sh`
