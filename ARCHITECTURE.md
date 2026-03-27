# Harness Architecture

Authoritative reference for how `~/.agents` works today.
If you change the harness structure, execution flow, invariants, or directory responsibilities,
update this file in the same change.

## What This Repo Is

`~/.agents` is a personal cross-agent harness for Claude and Codex.
It is designed to keep these stable across tools:

- shared policy
- shared skills
- shared tracking artifacts
- shared eval tasks
- shared generic learnings

It is not trying to make Claude and Codex internally identical.
It is trying to make them behave similarly at the workflow level.

## Source of Truth

1. `AGENTS.md` is the canonical shared policy.
2. `ARCHITECTURE.md` explains how the harness is assembled and how the layers interact.
3. Runtime bridge files in `claude/` and `codex/` stay thin and defer to root policy.

## Layer Map

```text
┌────────────────────────────────────────────────────────────────────┐
│                         Policy Layer                               │
│  AGENTS.md + docs/instructions/*                                   │
│  Canonical shared rules, conventions, tracking, routing defaults   │
└───────────────────────────────┬────────────────────────────────────┘
                                │ interpreted by
┌───────────────────────────────▼────────────────────────────────────┐
│                      Entry / Bridge Layer                          │
│  claude/CLAUDE.md  -> points Claude back to AGENTS.md              │
│  codex/AGENTS.md   -> points Codex back to AGENTS.md + invariants  │
└───────────────────────────────┬────────────────────────────────────┘
                                │ enforced by
┌───────────────────────────────▼────────────────────────────────────┐
│                      Enforcement Layer                             │
│  Claude: settings.json hooks -> scripts/hooks/*.sh                 │
│  Codex: explicit invariant rules in codex/AGENTS.md                │
│  Goal: same outcome, different mechanism                           │
└───────────────────────────────┬────────────────────────────────────┘
                                │ guided by
┌───────────────────────────────▼────────────────────────────────────┐
│                        Skills Layer                                │
│  skills/*/SKILL.md + optional scripts/references/assets            │
│  Portable reusable procedures for planning, review, UI, workflow   │
└───────────────────────────────┬────────────────────────────────────┘
                                │ may delegate via
┌───────────────────────────────▼────────────────────────────────────┐
│                      Orchestration Layer                           │
│  subagents/* + docs/instructions/ROUTING.md                        │
│  Research/review boundaries, single-agent default, spawn guidance  │
└───────────────────────────────┬────────────────────────────────────┘
                                │ persists into
┌───────────────────────────────▼────────────────────────────────────┐
│                    Artifact / Memory Layer                         │
│  tracking/       -> per-task audit trail                           │
│  claude-progress.txt -> cross-session working scratch              │
│  learnings/      -> generic reusable engineering knowledge         │
│  evals/results/  -> benchmark run history                          │
└───────────────────────────────┬────────────────────────────────────┘
                                │ bootstrapped and checked by
┌───────────────────────────────▼────────────────────────────────────┐
│                      Runtime / Ops Layer                           │
│  scripts/init.sh, scripts/check-harness.sh, eval scripts           │
│  claude/ and codex/ runtime state                                  │
└────────────────────────────────────────────────────────────────────┘
```

## Task Execution Flow

```text
User request
  -> Claude/Codex entrypoint reads bridge file
  -> bridge file points back to root AGENTS.md
  -> AGENTS.md selects core docs / skills / routing defaults
  -> enforcement layer blocks bad commits, secret writes, missing formatting
  -> agent executes work
  -> tracking artifacts record plan / tasks / verification / handoff
  -> progress file enables resume
  -> evals can measure whether harness changes improved outcomes
```

## Directory Responsibilities

| Path | Role | Notes |
|---|---|---|
| `AGENTS.md` | Canonical shared policy | Keep minimal and human-written |
| `ARCHITECTURE.md` | Harness structure and flow reference | Must be updated for structural harness changes |
| `CHANGELOG.md` | Human-written harness change log | Update for major harness evolution |
| `docs/instructions/CONVENTIONS.md` | Implementation conventions | Applies broadly |
| `docs/instructions/TRACKING.md` | Required tracking lifecycle | Applies to substantial work |
| `docs/instructions/ROUTING.md` | Subagent routing rules | Orchestration-specific |
| `skills/` | Reusable portable procedures | Primary context injection layer |
| `subagents/` | Reusable agent role definitions | Use sparingly and intentionally |
| `tracking/` | Per-task persistent execution record | Durable, task-specific |
| `learnings/` | Generic reusable engineering lessons | Not project-specific memory |
| `evals/tasks/` | Benchmark prompts | Stable task corpus |
| `evals/results/` | Run results | Compare Claude vs Codex over time |
| `scripts/hooks/` | Claude enforcement scripts | Mechanical invariants |
| `scripts/new-tracked-task.sh` | Tracking scaffolder | Seeds task folders and progress linkage |
| `scripts/new-eval-result.sh` | Eval result scaffolder | Creates result markdown files |
| `scripts/summarize-evals.py` | Eval aggregation | Summarizes benchmark history |
| `scripts/check-harness.sh` | Harness health validator | Checks structure and wiring |
| `claude/` | Claude runtime state + bridge config | Symlink target for `~/.claude` |
| `codex/` | Codex runtime state + bridge config | Symlink target for `~/.codex` |

## Current Enforcement Model

### Claude

- `claude/settings.json` wires hooks into Claude tool events
- `pre-commit-lint.sh` blocks bad commit messages before Bash commit commands run
- `pre-write-secrets.sh` blocks suspicious secret writes on `Write` and `Edit`
- `post-write-format.sh` formats supported source files after `Write` and `Edit`
- `on-stop-handoff.sh` writes a runtime snapshot and syncs tracked handoff when task context is known

### Codex

- No hook system is assumed
- Equivalent invariants live in `codex/AGENTS.md`
- Parity is achieved through outcome expectations, not matching implementation details

## Artifact Rules

### tracking/

- Durable, task-specific, structured
- Required for substantial work
- Source of truth for plan / phases / tasks / verification / handoff

### claude-progress.txt

- Temporary cross-session scratch file in the active project root
- Holds current task, status, next action, and `Tracking Task Path`
- Helps runtime hooks and skills locate the durable tracking task
- Never committed

### learnings/

- Only generic, transferable engineering knowledge
- No project-specific diary entries
- Good examples: testing patterns, TS pitfalls, architecture heuristics

### evals/

- `tasks/` contains benchmark prompts
- `results/` contains run records
- Scripts scaffold and summarize results, but human judgment still matters

## Cross-Agent Parity Table

| Concern | Claude | Codex |
|---|---|---|
| Shared policy | `claude/CLAUDE.md` -> `AGENTS.md` | `codex/AGENTS.md` -> `AGENTS.md` |
| Commit validation | Hook | Hard invariant |
| Secret protection | Hook | Hard invariant |
| Formatting | Hook | Hard invariant |
| Skill selection | Shared `skills/` | Shared `skills/` |
| Subagent routing | Shared `ROUTING.md` | Shared `ROUTING.md` |
| Durable tracking | Shared `tracking/` | Shared `tracking/` |
| Progress scratch | Shared `claude-progress.txt` format | Shared `claude-progress.txt` format |
| Evals | Shared `evals/` | Shared `evals/` |
| Learnings | Shared `learnings/` | Shared `learnings/` |

## Harness Maintenance Rules

- Read this file before changing the harness itself.
- If you add a new layer, directory, or invariant, update:
  - `ARCHITECTURE.md`
  - `AGENTS.md` if the behavior changes shared policy
  - `CHANGELOG.md` for major evolution
  - `check-harness.sh` if the harness should validate it
- Prefer improving wiring and enforcement before adding more surface area.

## Current Boundaries

- Skills are the main portability layer.
- Subagents are intentionally minimal and not the default path.
- Evals are still lightweight and human-scored, but now operationally supported.
- `AGENTS.md` stays short; flow detail belongs here.
