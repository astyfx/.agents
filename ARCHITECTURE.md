# Harness Architecture

Authoritative reference for how `~/.agents` works today.
If you change the harness structure, execution flow, invariants, or directory responsibilities,
update this file in the same change.

## What This Repo Is

`~/.agents` is a personal cross-agent harness for Claude and Codex.
It is designed to keep these stable across tools:

- shared policy
- shared skills
- shared execution-memory artifacts
- shared eval tasks
- shared operational memory

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
│  claude/CLAUDE.md  -> thin bridge; reads AGENTS.md + CLAUDE.md     │
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
│  execution/      -> default execution memory for active tasks      │
│  work-handoff.md -> cross-session handoff scratch                  │
│  memory/         -> patterns, troubleshooting, playbooks, ADRs     │
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
  -> execution artifacts record durable task state and optional deep plans
  -> work handoff file enables resume and leftover-work transfer
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
| `docs/instructions/TRACKING.md` | Lightweight tracking lifecycle | Applies to substantial work |
| `docs/instructions/CONTEXT_LOADING.md` | Thin-core prompt loading rules | Keeps default context small |
| `docs/instructions/ROUTING.md` | Subagent routing rules | Orchestration-specific |
| `skills/` | Reusable portable procedures | Primary context injection layer |
| `subagents/` | Reusable agent role definitions | Use sparingly and intentionally |
| `execution/` | Default execution-memory task records | Active task state and handoff only |
| `memory/` | Operational memory | Patterns, troubleshooting, playbooks, decisions, scorecards |
| `evals/tasks/` | Benchmark prompts | Stable task corpus |
| `evals/results/` | Run results | Compare Claude vs Codex over time |
| `scripts/hooks/` | Claude enforcement scripts | Mechanical invariants |
| `scripts/new-task.sh` | Execution-memory scaffolder | Seeds lite or expanded task folders and work-handoff linkage |
| `scripts/new-eval-result.sh` | Eval result scaffolder | Creates result markdown files |
| `scripts/summarize-evals.pl` | Eval aggregation (Perl) | Summarizes benchmark history |
| `scripts/init-repo.sh` | Per-repo agent config scaffolder | Creates bridge files, override templates, optional execution/CI |
| `scripts/check-harness.sh` | Harness health validator | Checks structure and wiring |
| `claude/` | Claude runtime state + bridge config | Symlink target for `~/.claude` |
| `codex/` | Codex runtime state + bridge config | Symlink target for `~/.codex` |

## Current Enforcement Model

### Claude

`claude/settings.json` wires hooks into Claude tool events:

| Event | Matcher | Hook(s) |
|---|---|---|
| `PreToolUse` | `Bash` | `pre-commit-lint.sh` — non-blocking advisory: warns (STDERR, exit 0) when a commit message is not Conventional Commits; does not block the commit |
| `PreToolUse` | `Write`, `Edit` | `pre-write-secrets.sh` — blocks secret-bearing files (narrow filename list: `.env`, `.pem`/`.p12`/`.pfx`/`.key`/`.keystore`/`.jks`, `id_rsa*`) and secret-like content in tracked/template files. Broad name substrings (`credentials`, `_secret`, `_token`) were removed so ordinary source files are not blocked |
| `PostToolUse` | `Write`, `Edit` | `post-write-format.sh` (formats supported source) + `post-skill-sync.sh` (keeps cross-tool skill copies in sync) |
| `PostToolUse` | `*` | superset `notify.sh` (best-effort desktop/runtime notify, no-op when unset) |
| `Stop` | — | `on-stop-handoff.sh` (runtime snapshot + tracked handoff sync) + superset `notify.sh` |
| `UserPromptSubmit` | — | superset `notify.sh` |
| `PostToolUseFailure` | `*` | superset `notify.sh` |
| `PermissionRequest` | `*` | superset `notify.sh` |

Non-hook settings that shape Claude's behavior:

- `permissions.defaultMode: "auto"` — auto-approve permitted tool calls.
- `skipAutoPermissionPrompt: true` — suppress the auto permission prompt.
- `effortLevel: "xhigh"` — maximum reasoning effort (do not lower without reason;
  this is a capability lever, not overhead).
- `theme: "dark-daltonized"`.
- `mcpServers` — local-only servers (currently `stave-local-mcp` over http).
  Hosted claude.ai connectors are not listed here; see MCP, Connectors, and Plugins.

### Codex

- Hook-capable (`codex/hooks.json`), but parity is defined by outcome, not by
  matching Claude's hook wiring detail.
- Equivalent invariants live in `codex/AGENTS.md` (Conventional Commits, secret
  protection, auto-formatting, session handoff).
- Approval enforcement is runtime-driven: `approval_policy = "on-request"` with
  `approvals_reviewer = "guardian_subagent"` (a guardian subagent reviews
  flagged actions). See the parity table and `codex/AGENTS.md`.

## Artifact Rules

### execution/

- Execution memory only
- Durable, task-specific, structured
- Required for substantial work
- Defaults to a single canonical `handoff.md` task record
- Can grow optional `plan.md`, `verification.md`, or `execution-log.md` when
  the work justifies them

### work-handoff.md

- Temporary cross-session scratch file in the active project root
- Holds the objective, current status, remaining work, recommended next actions,
  nice-to-have follow-ups, and `Active Task Path`
- Helps runtime hooks and skills locate the durable tracking task
- Never committed
- Replaced the earlier `claude-progress.txt` protocol; that file is no longer
  read or produced

### memory/

- Operational memory for cross-task reuse
- Houses patterns, troubleshooting records, playbooks, durable decisions, and
  scorecards
- Should grow through real work and retrospectives, not by speculative
  note-taking
- Curated by default; not a raw-source or transcript-ingestion layer

### evals/

- `tasks/` contains benchmark prompts
- `results/` contains run records
- Scripts scaffold and summarize results, but human judgment still matters
- Runs should stay selective and decision-linked, not become routine task logs

## Cross-Agent Parity Table (v3)

Both agents support subagents, plugins, and richer orchestration. Parity is at
the workflow level, not implementation detail.

| Concern | Claude | Codex |
|---|---|---|
| Shared policy | `claude/CLAUDE.md` -> `AGENTS.md` + `CLAUDE.md` | `codex/AGENTS.md` -> `AGENTS.md` |
| Commit validation | Hook | Hook + hard invariant as safety net |
| Secret protection | Hook | Hook + hard invariant as safety net |
| Formatting | Hook | Hook + hard invariant as safety net |
| Approval review | `permissions.defaultMode` + `skipAutoPermissionPrompt` | `approval_policy=on-request` + `approvals_reviewer=guardian_subagent` |
| Skill selection | Shared `skills/` | Shared `skills/` |
| Subagent routing | Shared `ROUTING.md` | Shared `ROUTING.md` |
| Built-in agent types | `Explore`, `Plan`, `general-purpose` (prefer over custom) | native equivalents; falls back to `subagents/*` AGENT.md |
| Custom subagent spawn | Agent tool + AGENT.md | Native subagent + AGENT.md |
| Multi-agent workflows | `Workflow` tool (pipeline/parallel/agent, token budget); opt-in | native multi-agent orchestration; opt-in |
| Scheduled / background / remote | `/loop`, `/schedule`, `ScheduleWakeup`, `CronCreate`, bg `Bash`, `isolation: remote/worktree` | native scheduling / background runs |
| Connectors / MCP | hosted claude.ai connectors via ToolSearch/deferred; local `mcpServers` in settings.json | plugins via marketplaces (`openai-curated`, `openai-bundled`, `openai-primary-runtime`) |
| Plugins / marketplace | `claude-plugins-official` (asana, context7, github, linear, playwright, serena, ...) | `slack`, `github`, `atlassian-rovo`, `browser`, `computer-use`, `sites`, documents/pdf/spreadsheets/presentations |
| Computer use | via connector/plugin when available | `computer-use@openai-bundled` enabled |
| Goals / memories | `memory/` + execution memory | native goals/memories + shared `memory/` |
| Durable execution memory | Shared `execution/` | Shared `execution/` |
| Progress scratch | Shared `work-handoff.md` format | Shared `work-handoff.md` format |
| Evals | Shared `evals/` | Shared `evals/` |
| Operational memory | Shared `memory/` | Shared `memory/` |
| Per-repo init | Shared `scripts/init-repo.sh` | Shared `scripts/init-repo.sh` |

## MCP, Connectors, and Plugins

Two distinct wiring models; do not conflate them:

- **Hosted connectors (claude.ai) load on demand.** The session auto-exposes
  connector tools as *deferred* tools (named but schema-less). Fetch a schema
  with `ToolSearch` before calling. Do not assume a connector is unavailable
  without searching first; do not hand-wire these in `settings.json`.
- **Local MCP servers are wired in `claude/settings.json` `mcpServers`.** This is
  for servers running on the machine — currently only `stave-local-mcp` over http.
- **Codex uses plugins from marketplaces**, not a settings.json MCP block:
  `openai-curated` (slack, github, atlassian-rovo), `openai-bundled` (browser,
  computer-use, sites), `openai-primary-runtime` (documents, pdf, spreadsheets,
  presentations).
- **Claude plugins** come from the `claude-plugins-official` marketplace (asana,
  context7, discord, firebase, github, gitlab, greptile, linear, playwright,
  serena, terraform, and more).

Operational selection guidance (which connector/plugin per task, and the
ToolSearch flow) lives in `memory/playbooks/connectors-and-plugins.md`. Runtime
state files (`config.toml`, `.claude.json`, caches) are not source-of-truth
policy; reflect facts in docs, do not hand-edit runtime state.

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
- When a project also ships repo-local policy files, those are consulted before global defaults: `AGENTS.md` for shared rules, plus `CLAUDE.md` or `.claude/CLAUDE.md` for Claude-specific guidance.

### What stays global (here)

- Canonical policy (AGENTS.md)
- Generic skills, subagents, operational memory
- Enforcement hooks (in global `~/.claude/settings.json`)
- Default conventions and library preferences
- Eval framework, ROADMAP, CHANGELOG

### What lives per-repo (scaffolded, committable)

- `.claude/CLAUDE.md` — project context (tech stack, commands, rules)
- `.claude/settings.json` — team-shared settings (permissions, not personal hooks)
- `.codex/AGENTS.md` — project context + base conventions
- `CONVENTIONS.override.md` — team-agreed convention overrides
- `LIBRARIES.override.md` — team-agreed library overrides
- `execution/` — default project-specific execution memory (optional)
- `.github/workflows/` — project CI (optional)

### What is gitignored (personal, per-repo)

- `.claude/settings.local.json` — personal overrides
- `work-handoff.md` — personal agent handoff scratch state
- `.claude/.claude.json`, `.claude/history.jsonl`, etc. — runtime state

### Per-repo init flow

```text
scripts/init-repo.sh <project-path> [--with-execution] [--with-ci]
  -> creates team-friendly .claude/CLAUDE.md, .codex/AGENTS.md (no personal paths)
  -> creates .claude/settings.json (empty team permissions, no hooks)
  -> creates override templates (CONVENTIONS, LIBRARIES)
  -> optionally scaffolds execution/ and CI workflows
  -> updates .gitignore with personal/runtime patterns
```

## Current Boundaries

- Skills are the main portability layer.
- Subagents are intentionally minimal and not the default path.
- Evals are still lightweight and human-scored, but now operationally supported.
- `AGENTS.md` stays short; flow detail belongs here.
- `ROADMAP.md` tracks planned evolution and architecture decisions.
