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
3. `ROADMAP.md` is the living evolution plan — phases, architecture decisions, priorities.
4. Runtime bridge files in `claude/` and `codex/` stay thin and defer to root policy.

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
| `ROADMAP.md` | Living evolution plan with phases and decisions | Read before harness work; update when phases change |
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
| `scripts/init-repo.sh` | Per-repo agent config scaffolder | Creates bridge files, override templates, optional tracking/CI |
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

## Cross-Agent Parity Table (v2)

Assumes Codex supports subagents and plugins as of 2026-03.

| Concern | Claude | Codex |
|---|---|---|
| Shared policy | `claude/CLAUDE.md` -> `AGENTS.md` | `codex/AGENTS.md` -> `AGENTS.md` |
| Commit validation | Hook | Hook + hard invariant as safety net |
| Secret protection | Hook | Hook + hard invariant as safety net |
| Formatting | Hook | Hook + hard invariant as safety net |
| Skill selection | Shared `skills/` | Shared `skills/` |
| Subagent routing | Shared `ROUTING.md` | Shared `ROUTING.md` |
| Subagent spawn | Agent tool + AGENT.md | Native subagent + AGENT.md |
| MCP / Plugins | settings.json MCP servers | Plugin config (equivalent) |
| Durable tracking | Shared `tracking/` | Shared `tracking/` |
| Progress scratch | Shared `claude-progress.txt` format | Shared `claude-progress.txt` format |
| Evals | Shared `evals/` | Shared `evals/` |
| Learnings | Shared `learnings/` | Shared `learnings/` |
| Per-repo init | Shared `scripts/init-repo.sh` | Shared `scripts/init-repo.sh` |

## Harness Maintenance Rules

- Read this file before changing the harness itself.
- If you add a new layer, directory, or invariant, update:
  - `ARCHITECTURE.md`
  - `AGENTS.md` if the behavior changes shared policy
  - `CHANGELOG.md` for major evolution
  - `check-harness.sh` if the harness should validate it
- Prefer improving wiring and enforcement before adding more surface area.

## Global vs Per-Repo Model

`.agents` is a personal harness — it provides global defaults.
Individual project repos get their own agent config via `scripts/init-repo.sh`.

### Design principle: team-friendly per-repo files

Per-repo files created by `init-repo.sh` contain **no personal paths** (`~/.agents/`).
They can be committed to shared repos without affecting team members who don't have the harness.

Personal config (hooks, MCP servers, plugins) works through Claude's merge hierarchy:

```text
Global (~/.claude/settings.json)   ← your personal harness hooks (auto-applied everywhere)
  ↓ merged with
Project (.claude/settings.json)    ← team settings (committed)
  ↓ merged with
Local (.claude/settings.local.json) ← personal per-repo overrides (gitignored)
```

This means:
- Teammates without `~/.agents/` still get useful project context from `.claude/CLAUDE.md`.
- Your personal hooks fire everywhere via the global config — no per-repo duplication needed.
- Personal per-repo overrides go in `settings.local.json` (gitignored automatically).

### What stays global (here)

- Canonical policy (AGENTS.md)
- Generic skills, subagents, learnings
- Enforcement hooks (in global `~/.claude/settings.json`)
- Default conventions and library preferences
- Eval framework, ROADMAP, CHANGELOG

### What lives per-repo (scaffolded, committable)

- `.claude/CLAUDE.md` — project context (tech stack, commands, rules)
- `.claude/settings.json` — team-shared settings (permissions, not personal hooks)
- `.codex/AGENTS.md` — project context + base conventions
- `CONVENTIONS.override.md` — team-agreed convention overrides
- `LIBRARIES.override.md` — team-agreed library overrides
- `tracking/` — project-specific task tracking (optional)
- `.github/workflows/` — project CI (optional)

### What is gitignored (personal, per-repo)

- `.claude/settings.local.json` — personal overrides
- `claude-progress.txt` — personal agent working state
- `.claude/.claude.json`, `.claude/history.jsonl`, etc. — runtime state

### Per-repo init flow

```text
scripts/init-repo.sh <project-path> [--with-tracking] [--with-ci]
  -> creates team-friendly .claude/CLAUDE.md, .codex/AGENTS.md (no personal paths)
  -> creates .claude/settings.json (empty team permissions, no hooks)
  -> creates override templates (CONVENTIONS, LIBRARIES)
  -> optionally scaffolds tracking/ and CI workflows
  -> updates .gitignore with personal/runtime patterns
```

## Current Boundaries

- Skills are the main portability layer.
- Subagents are intentionally minimal and not the default path.
- Evals are still lightweight and human-scored, but now operationally supported.
- `AGENTS.md` stays short; flow detail belongs here.
- `ROADMAP.md` tracks planned evolution and architecture decisions.
