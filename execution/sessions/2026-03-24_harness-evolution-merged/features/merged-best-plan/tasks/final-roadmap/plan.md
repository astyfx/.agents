# Plan — Harness Evolution: Merged Best Practices

## Scope

Synthesize Claude's plan and Codex's plan into a single, superior harness evolution roadmap.
Primary goal: Claude and Codex provide a near-identical authoring experience.
Secondary goal: generic, tech/architecture-level learning rather than project-specific memory.

## Inputs

- Claude plan: analyzed current repo, proposed hooks, skills, memory, subagents
- Codex plan: `execution/sessions/2026-03-24_harness-evolution-research/...`
- User constraint: memory/learning = generic patterns (tech, architecture, structure), not project facts

## Assumptions

- Both agents use the same `~/.agents/AGENTS.md`, skills, tracking, and convention files.
- Hooks exist only on the Claude side; Codex gets equivalent enforcement via explicit AGENTS.md rules.
- Parity means same workflow, same artifacts, same skill set — not same internal mechanism.
- AGENTS.md stays under 300 lines. Complexity goes into skills, scripts, subagents.

## Plan Comparison Matrix

| Dimension              | Claude plan                            | Codex plan                              | Winner / Merge |
|------------------------|----------------------------------------|------------------------------------------|----------------|
| Priority order         | Hooks → Skills → Memory → Subagents   | Evals → Guardrails → Skills → Memory    | **Codex** — measure before building |
| Guardrail framing      | Hooks (concrete, Claude-only)          | "Deterministic mechanisms" (abstract)   | **Both** — concrete hooks + Codex prompt equivalent |
| Skill portability      | INDEX.md, new skills                   | Schema + test prompts + classification  | **Codex** — schema-first is better |
| Memory design          | agent-memory.md (project-level)        | Scoped structured memory (no dumps)     | **Both** + user constraint = generic tech/arch only |
| Subagents              | researcher, reviewer, routing guide    | researcher, reviewer, implementer, checker | Similar, merge |
| New utility scripts    | hooks scripts only                     | new-task.sh + check-harness.sh | **Codex** — both scripts are high value |
| Harness as platform    | Not in plan                            | Architecture doc + changelog + self-check | **Codex** |
| Security               | GitHub PAT → env var (specific fix)    | Not mentioned                           | **Claude** |
| Cross-agent handoff    | File-based protocol (progress.txt)     | Not explicit                            | **Claude** |

## Key Architectural Decision

Parity does not mean identical mechanism. It means identical workflow:

```
Claude path:  hooks enforce → skill guides → tracking records → learnings accumulate
Codex path:   AGENTS.md rules enforce → skill guides → tracking records → learnings accumulate
```

The artifact format (progress.txt, agent-memory.md, tracking/, learnings/) is the
portable layer. Any agent can read and write it. Enforcement mechanisms differ per tool.

## Done Criteria

- [ ] Merged roadmap written to plan.md (this file)
- [ ] phases.md with week-by-week breakdown
- [ ] tasks.md with concrete deliverables
- [ ] Key files identified for each phase
- [ ] Generic memory spec written
- [ ] Cross-agent parity design documented

---

# Merged Roadmap

## Non-Negotiables (never change)

1. `AGENTS.md` stays minimal and human-written (< 300 lines).
2. Runtime bridge files (`claude/CLAUDE.md`, `codex/AGENTS.md`) stay thin.
3. Skills stay modular: one `SKILL.md` per skill, optional `scripts/`, `references/`, `assets/`.
4. Tracking artifacts created for all substantial work.
5. Every file readable and writable by any agent (no tool-specific binary formats).

---

## Phase 0 — Security Fix (Day 1, < 30 min)

Not in Codex's plan. Immediate risk.

### 0-1. GitHub PAT → environment variable

`claude/settings.json` currently has a GitHub PAT hardcoded in the MCP server headers.
Even though this file is gitignored, it is a credential management antipattern.

Fix: replace inline token with `$GITHUB_MCP_TOKEN` env var reference.
Add the env var export to `scripts/init.sh`.

---

## Phase 1 — Evals First (Week 1)

**Codex's core insight**: measuring before building. Every subsequent change
(new skill, new hook, new subagent) can now be validated against a baseline.

### 1-1. `evals/` directory structure

```
evals/
├── README.md             — scoring rubric, how to run, column definitions
├── tasks/
│   ├── 01-component-build.md       — build a data table with sort + filter
│   ├── 02-tdd-cycle.md             — write failing test first, then implement
│   ├── 03-commit-convention.md     — make a non-conventional commit, verify it is caught
│   ├── 04-code-review-bugs.md      — review file with 3 planted issues, find all
│   ├── 05-build-fix-tsc.md         — fix a TypeScript error from pasted output
│   ├── 06-cross-session-resume.md  — pick up a task from progress.txt
│   ├── 07-skill-creation.md        — create a new skill following schema
│   ├── 08-multifile-refactor.md    — refactor across 3+ files without breaking tests
│   ├── 09-secret-detection.md      — attempt to write a .env file, verify it is blocked
│   └── 10-prompt-refinement.md     — refine a vague spec into an executable brief
└── results/
    └── YYYY-MM-DD_<agent>_<task-id>.md   — one file per run
```

### 1-2. Scoring taxonomy (from Codex plan, made concrete)

Each task result records:
- `pass`: yes / no / partial
- `rework_count`: how many user corrections were needed
- `verification_quality`: did the agent verify its own work?
- `policy_compliance`: conventional commits, no secrets, tracking created?
- `notes`: freeform observation

No automation needed. Manual runs with honest recording build the most useful signal.

### 1-3. Why this is Phase 1

Without a baseline, adding hooks, skills, and memory will feel useful but be unverifiable.
The evals directory costs < 2 hours to create and pays dividends on every subsequent change.

---

## Phase 2 — Deterministic Guardrails (Week 1-2)

**Codex framing** (correct): "move hard guarantees from prompts into deterministic mechanisms."
**Claude's contribution**: concrete implementations for each mechanism.

The key insight: `AGENTS.md` should express *preferences*. Invariants belong in enforcement layers.

### 2-1. Claude side: hooks

Four hooks, all living under `scripts/hooks/`:

| Hook file | Event | Purpose |
|---|---|---|
| `pre-commit-lint.sh` | PreToolUse:Bash | Block non-Conventional Commits |
| `pre-write-secrets.sh` | PreToolUse:Write | Block writes to .env/key/token files |
| `post-write-format.sh` | PostToolUse:Write,Edit | Auto-run formatter after file saves |
| `on-stop-handoff.sh` | Stop | Write session snapshot to `claude/session-snapshots/` |

All hooks fail-safe except the two PreToolUse blocks (which should exit non-zero to block).
Hook scripts receive event data via stdin as JSON (not env vars — common gotcha).

Wire into `claude/settings.json` under `"hooks": { ... }`.

### 2-2. Codex side: equivalent rules in `codex/AGENTS.md`

Since Codex has no hook system, the same invariants become explicit instructions:

```markdown
## Invariants (always enforce, no exceptions)

- Never create a commit with a non-Conventional Commits message.
  If you would violate this, stop and ask the user how to proceed.
- Never write secrets, API keys, or tokens to files that will be tracked.
  Check for .env, *_key, *secret*, *token* patterns before any Write.
- After writing or editing source files, run the project's formatter
  (prettier, ruff, rustfmt) if it is configured. Do not skip this step.
- When stopping work on a substantial task, write a brief handoff note
  to the tracking task's handoff.md before finishing.
```

These mirror hook behavior via instruction rather than mechanism. Same outcome, different path.

### 2-3. `scripts/check-harness.sh` (from Codex plan)

```bash
# Validate harness health on any machine
# - required policy files exist
# - skills have valid frontmatter (name + description)
# - tracking active sessions have required files
# - hooks are wired in settings.json
# - no broken symlinks
```

Run this after init.sh and after major harness changes.

### 2-4. `scripts/new-task.sh` (from Codex plan)

```bash
# Usage: new-task.sh <session-slug> <feature-slug> <task-slug>
# Creates the full tracking directory tree with template files:
# execution/sessions/YYYY-MM-DD_<session>/features/<feature>/tasks/<task>/
#   plan.md, phases.md, tasks.md, execution-log.md, verification.md, handoff.md
```

Replaces the mental overhead of "what files do I need to create?" with one command.

---

## Phase 3 — Skill System Upgrade (Week 2-3)

**Codex's insight**: skills need schema, classification, and test prompts to become a real portability layer.
**Claude's contribution**: INDEX.md for discovery, 4 specific new skills needed.

### 3-1. Skill frontmatter schema

Add `compatible-tools` and `test-prompts` to every SKILL.md frontmatter:

```yaml
---
name: the-skill-name
description: >
  When and why to trigger this skill (the primary discovery surface).
compatible-tools: [claude, codex]   # or [claude] if hooks/subagents are required
category: workflow | ui | research | review | planning
test-prompts:
  - "Sample trigger phrase 1"
  - "Sample trigger phrase 2"
---
```

`check-harness.sh` validates that all SKILL.md files have valid frontmatter.

### 3-2. `skills/INDEX.md`

One table, auto-maintained by `the-skill-creator` skill:

```markdown
| Name | Category | Compatible | Trigger (summary) |
|---|---|---|---|
| the-refine-prompt | planning | claude, codex | rough prompts, vague specs |
| the-frontend-director | ui | claude, codex | components, pages, dashboards |
| ... | | | |
```

### 3-3. New skills needed (to balance the current UI/design bias)

Current: 7 skills, all UI/design/frontend.
Missing: development workflow skills.

| Skill | Category | Trigger |
|---|---|---|
| `the-code-reviewer` | review | "코드 리뷰", "review this", "PR 리뷰" |
| `the-tdd` | workflow | "TDD", "테스트 먼저", "red-green-refactor" |
| `the-build-fixer` | workflow | "빌드 실패", "CI failed", "tsc error" |
| `the-progress-tracker` | workflow | "이어서 작업", "resume", "어디까지 했지" |

All four are `compatible-tools: [claude, codex]` — pure prompt instructions, no Claude-specific APIs.

### 3-4. Skill classification for existing skills

Retroactively add `category` and `compatible-tools` to existing 7 skills.
Update INDEX.md.

---

## Phase 4 — Generic Memory Architecture (Week 3)

**User constraint**: memory = generic tech/architecture/patterns, NOT project-specific facts.

This is the most important design decision in the merged plan. The memory layer should function
like a technical knowledge base that any agent can consult, not a per-project diary.

### What belongs in memory (generic, transferable)

```
✅ "React Server Components cannot use useState or useEffect directly"
✅ "Zod's .transform() runs at parse time, not validation time — affects error shape"
✅ "When IPC is involved in Electron, register handlers before BrowserWindow is created"
✅ "TanStack Query's staleTime vs gcTime distinction — common source of cache bugs"
✅ "shadcn/ui components copy into the project — do not import from node_modules"
```

```
❌ "stave project has a bug in the auth module"
❌ "agentize repo uses snake_case for API responses"
❌ "yesterday's session got to step 3 of the login refactor"
```

Project-specific facts belong in `./agent-memory.md` at the project root if the user wants them.
The global learnings layer is for distilled, reusable technical knowledge.

### 4-1. `learnings/` directory structure

```
~/.agents/learnings/
├── README.md            — what this is, how to add, how to use
├── react-patterns.md    — RSC patterns, state management, rendering behavior
├── typescript.md        — type system gotchas, utility types, error patterns
├── testing.md           — vitest patterns, mock strategies, async testing
├── api-design.md        — REST conventions, error shapes, auth patterns
├── build-tooling.md     — bun/vite/webpack patterns, bundle gotchas
├── architecture.md      — layering rules, boundary patterns, abstraction heuristics
└── debugging.md         — common error patterns and their root causes
```

Each file: bullet-point format, one insight per bullet, < 20 lines per topic area.

### 4-2. Cross-agent progress protocol

For handoff between sessions (and between agents), use file-based protocol:

**`./claude-progress.txt`** at project root (note: "claude" in name is historical — any agent reads/writes it):

```markdown
# Progress

## Task
<what we are working on>

## Status
<current phase: Discover | Plan | Implement | Verify | Handoff>

## Last Completed Step
<what was just finished>

## Next Action
<the exact next step>

## Open Questions
<anything blocking or uncertain>

## Changed Files
<list of modified files since start>
```

Written by `the-progress-tracker` skill. Read by any agent at session start.
Excluded from commits via .gitignore.

### 4-3. `the-progress-tracker` skill

Triggers: "이어서 작업", "resume", "어디까지 했지", "continue", "pick up where we left off"

At session start: reads `./claude-progress.txt` + `tracking/.../handoff.md` → briefing.
During work: updates progress.txt at each milestone.
At session end: finalizes progress.txt + handoff.md.

This skill is the main mechanism for cross-session and cross-agent continuity.

---

## Phase 5 — Subagents (Week 4)

### 5-1. `subagents/researcher/AGENT.md`

Role: Discover phase exploration.
Tools: Read, Glob, Grep, Bash (read-only: ls, cat, git log).
Output: structured findings report (relevant files, patterns, constraints, risks).
Value: keeps exploration out of main context window.

### 5-2. `subagents/reviewer/AGENT.md`

Role: Post-implementation code review.
Tools: Read, Glob, Grep only.
Skill: uses `the-code-reviewer`.
Output: review report saved to `tracking/.../verification.md`.

### 5-3. `docs/instructions/ROUTING.md` (task-based, not agent-based)

Not "use Claude for X" or "use Codex for Y" — the user decides that.
Instead: "use a subagent when..." and "stay single-agent when...".

Criteria for spawning a subagent:
- Discover phase with > 5 unknown files → researcher subagent
- Implement complete, need independent review → reviewer subagent
- Task requires only reads → any restricted subagent

Keep single-agent when:
- Writing production code (needs full context)
- Multi-file refactors with interdependencies
- Work < 30 min estimated

---

## Phase 6 — Harness as Platform (Week 4+)

From Codex plan. Lower urgency, high long-term value.

- `ARCHITECTURE.md`: one-page diagram + narrative of all harness layers
- `CHANGELOG.md`: human-written log of major harness decisions (not generated)
- `scripts/init.sh` extended with check-harness.sh validation at end
- Skill export path for future portability (n-skills format, agentskills.io)

---

## Final Priority Order

1. Security fix (PAT → env var) — Day 1, 30 min
2. Evals (10 tasks) — Week 1, 2 hours
3. Guardrails (hooks + Codex AGENTS.md rules + scripts) — Week 1-2, 3 hours
4. Skill schema + INDEX.md + 4 new skills — Week 2-3, 4 hours
5. Learnings/ + progress protocol + the-progress-tracker — Week 3, 2 hours
6. Subagents + ROUTING.md — Week 4, 3 hours
7. Harness platform layer — Week 4+, ongoing

## Total estimated effort: ~15 hours across 4 weeks
