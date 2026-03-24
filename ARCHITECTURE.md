# Harness Architecture

Single-page reference for how `~/.agents` is structured and why.

## Layer Map

```
┌─────────────────────────────────────────────────────────────┐
│                        Policy Layer                          │
│  AGENTS.md (canonical) + docs/instructions/ (detail)         │
│  Human-written. Versioned. < 300 lines total in AGENTS.md.  │
└───────────────────────────┬─────────────────────────────────┘
                            │ reads
┌───────────────────────────▼─────────────────────────────────┐
│                     Enforcement Layer                         │
│  Claude: hooks in settings.json → scripts/hooks/*.sh         │
│  Codex:  explicit invariant rules in codex/AGENTS.md         │
│  Both:   same outcome (commit lint, secret block, format)    │
└───────────────────────────┬─────────────────────────────────┘
                            │ guides
┌───────────────────────────▼─────────────────────────────────┐
│                       Skills Layer                            │
│  skills/<name>/SKILL.md — on-demand context injection        │
│  skills/INDEX.md — discovery table                           │
│  Compatible with: Claude, Codex (see compatible-tools field)  │
└───────────────────────────┬─────────────────────────────────┘
                            │ delegates to
┌───────────────────────────▼─────────────────────────────────┐
│                     Subagents Layer                           │
│  subagents/researcher/ — Discover phase exploration          │
│  subagents/reviewer/   — Verify phase code review           │
│  docs/instructions/ROUTING.md — when to spawn subagents     │
└───────────────────────────┬─────────────────────────────────┘
                            │ records to
┌───────────────────────────▼─────────────────────────────────┐
│                      Memory Layer                             │
│  tracking/sessions/ — per-task audit log (temporary)         │
│  learnings/ — generic tech/arch knowledge (permanent)        │
│  ./claude-progress.txt — cross-session handoff (scratch)     │
│  evals/results/ — benchmark run history                      │
└───────────────────────────┬─────────────────────────────────┘
                            │ bootstrapped by
┌───────────────────────────▼─────────────────────────────────┐
│                     Runtime Layer                             │
│  claude/ → ~/.claude (symlink) — Claude runtime state        │
│  codex/ → ~/.codex (symlink)  — Codex runtime state          │
│  scripts/init.sh — idempotent setup for new machines         │
│  scripts/check-harness.sh — health validation                │
└─────────────────────────────────────────────────────────────┘
```

## Design Principles

1. **Policy is human-written and versioned.** AGENTS.md is readable, auditable, and git-tracked.
2. **Enforcement is mechanical, not prompting.** Invariants live in hooks or explicit instructions, not in "please remember to..." prose.
3. **Skills are the portability layer.** A skill works the same way in Claude and Codex unless it requires tool-specific APIs.
4. **Artifacts are agent-agnostic.** tracking/, learnings/, and claude-progress.txt are plain markdown readable by any agent.
5. **Measure before adding.** evals/ provides evidence that changes actually improve outcomes.
6. **Runtime state is ephemeral.** claude/ and codex/ are gitignored. Policy and skills are committed.

## Key File Locations

| Purpose | Path |
|---|---|
| Canonical policy | `~/.agents/AGENTS.md` |
| Skill index | `~/.agents/skills/INDEX.md` |
| Subagent routing rules | `~/.agents/docs/instructions/ROUTING.md` |
| Claude hook scripts | `~/.agents/scripts/hooks/` |
| Harness health check | `~/.agents/scripts/check-harness.sh` |
| New task scaffolding | `~/.agents/scripts/new-tracked-task.sh` |
| Generic tech learnings | `~/.agents/learnings/` |
| Benchmark tasks | `~/.agents/evals/tasks/` |
| Bootstrap script | `~/.agents/scripts/init.sh` |

## Cross-Agent Parity

The same workflow in Claude and Codex:

| Step | Claude | Codex |
|---|---|---|
| Commit validation | pre-commit-lint.sh hook blocks bad commits | Explicit invariant in codex/AGENTS.md |
| Secret protection | pre-write-secrets.sh hook blocks Write | Explicit invariant in codex/AGENTS.md |
| Auto-format | post-write-format.sh hook runs after Write/Edit | Explicit invariant in codex/AGENTS.md |
| Session handoff | on-stop-handoff.sh + the-progress-tracker skill | the-progress-tracker skill |
| Skill access | skills/*.SKILL.md loaded by Claude | skills/*.SKILL.md loaded by Codex |
| Tracking | tracking/ directory, TRACKING.md rules | tracking/ directory, TRACKING.md rules |
