# Harness Roadmap

Living document for `.agents` harness evolution.
Updated by humans and agents. Read this before starting harness work.

**Last updated**: 2026-04-08
**Current phase**: Phase 5 complete: operating-model reboot finalized on `execution/`.

---

## Context

This roadmap was derived from analyzing OpenAI Codex use cases against the current
harness state, filtered through the lens of a SaaS frontend/backend engineer & manager
whose work includes:
- SaaS product feature development
- Internal tooling (stave, agentize)
- Team-level tooling (Linear-like, agent orchestration workflows)
- Large-scale refactoring and product separation

All initial build-out phases were completed, but the next constraint is no
longer missing surface area. The operating loop itself needed reassessment:
`learnings/` was static, `evals/` was not feeding decisions, and the roadmap
had to govern active iteration again instead of only recording completed
construction work.

The first implementation slice of that reassessment is now underway:
- thin-core context-loading rules
- operational memory scaffolding under `memory/`
- a troubleshooting-first capture model
- an initial harness scorecard baseline
- removal of the `python3` dependency from tracked-task handoff seeding

---

## Architecture Decisions

### AD-1: Global vs Per-Repo Separation

The `.agents` repo is a **personal harness** — it holds global defaults, not project-specific config.
Projects get their own config via a scaffolding script.

| Stays in .agents (global) | Goes to each repo (per-repo) |
|---|---|
| AGENTS.md (canonical policy) | `.claude/CLAUDE.md` (project context + global pointer) |
| Generic skills (TDD, code-review, etc.) | `CONVENTIONS.override.md` |
| Generic subagents (researcher, reviewer) | `LIBRARIES.override.md` |
| Enforcement hooks (commit, secrets, format) | `execution/` (project-specific tasks) |
| Operational memory (patterns, troubleshooting, decisions) | `work-handoff.md` (project working state) |
| Eval framework | `.github/workflows/` (project CI) |
| CONVENTIONS.md, LIBRARIES.md (defaults) | Project-specific hooks/settings |
| ROADMAP.md, CHANGELOG.md | Codebase map (generated per-repo) |

**Rationale**: The harness should be portable across machines and not couple personal
preferences into team repos. Per-repo config lets each project override what it needs.

### AD-2: Codex Parity Model (v2)

Assumes Codex now supports subagents and plugins.

| Concern | Before (v1) | After (v2) |
|---|---|---|
| Enforcement | Claude: hooks / Codex: invariants only | Both: hooks + invariants as safety net |
| Subagents | Text references only for Codex | Both reference same AGENT.md definitions |
| MCP/Plugins | Claude only (Figma, GitHub, Slack) | Both can wire equivalent plugins |
| Routing | Identical ROUTING.md, different spawn syntax | Unified spawn syntax section |

### AD-3: Role-Based Skill Audit

Priority assessment for SaaS frontend/backend engineer & manager:

| Skill | Priority | Rationale |
|---|---|---|
| the-pr-reviewer (NEW) | P0 | Team workflow: automated PR review via GitHub MCP |
| the-refactoring-planner (NEW) | P0 | Product separation, large-scale refactoring — primary work |
| the-codebase-mapper (NEW) | P1 | Onboard to unfamiliar code, map modules before refactoring |
| the-improvement-loop (NEW) | P1 | Scored iteration pattern — quality, perf, coverage |
| the-api-migrator (NEW) | P2 | Dependency upgrades, API version migrations |
| the-figma-to-code (NEW) | P2 | Figma MCP → code with visual verification |
| the-slack-thread-worker (NEW) | P2 | Slack thread → task extraction, Jira prep, or end-to-end execution |
| the-data-analyst (NEW) | P3 | Data analysis & reporting — less frequent need |

Subagent additions:

| Subagent | Priority | Rationale |
|---|---|---|
| planner (NEW) | P1 | Architecture planning for refactoring/separation — structured output |
| qa-engineer (NEW) | P2 | Spec → test cases, regression coverage |

### AD-4: Thin Core, Thick On-Demand Context

The default prompt surface should stay minimal. Durable detail should move into
indexed, on-demand modules such as skills, playbooks, troubleshooting guides,
and operational memory.

**Rationale**:
- Lower token overhead for everyday work
- Better separation between always-on policy and situational guidance
- Easier cross-agent parity because the contract is artifact-based, not
  monolithic-prompt-based

---

## Phase Plan

### Phase 0: Foundation — Global/Per-Repo Split + Codex Parity

**Goal**: Establish the scaffolding system and update parity model before adding new skills.

**Deliverables**:
1. `scripts/init-repo.sh` — per-repo scaffolding script
   - Creates `.claude/CLAUDE.md` (project context + global delegate)
   - Creates `.codex/AGENTS.md` (project context + global delegate)
   - Creates `CONVENTIONS.override.md` template
   - Creates `LIBRARIES.override.md` template
   - `--with-execution` flag: creates `execution/` directory
   - `--with-ci` flag: creates `.github/workflows/` with PR review template
2. Update `codex/AGENTS.md` — add hook wiring section (matching Claude's model)
3. Update `ARCHITECTURE.md` — add per-repo layer, update parity table for v2
4. Update `ROUTING.md` — unified Codex spawn syntax
5. Update `check-harness.sh` — validate init-repo template files exist

**Eval**: None (infrastructure phase)

### Phase 1: Automation & Review Pipeline

**Goal**: Automated PR review and scored improvement loops.

**Deliverables**:
1. `skills/the-pr-reviewer/SKILL.md`
   - Reads PR diff via GitHub MCP or `gh` CLI
   - Runs 6-axis review (reuses the-code-reviewer rubric)
   - Posts review comments to GitHub PR
   - CRITICAL findings → request changes; SUGGESTION/NIT → comment
   - Compatible: Claude, Codex
2. `skills/the-improvement-loop/SKILL.md`
   - Define rubric (configurable per domain)
   - Implement → score → delta analysis → refine cycle
   - Max iterations with best-effort fallback
   - Domains: code quality, test coverage, performance, accessibility
   - Compatible: Claude, Codex
3. Eval tasks: `11-pr-auto-review.md`, `12-improvement-loop.md`

### Phase 2: Codebase Comprehension & Refactoring

**Goal**: Skills for large-scale code understanding and refactoring planning.

**Deliverables**:
1. `skills/the-codebase-mapper/SKILL.md`
   - Module dependency map (Mermaid diagrams)
   - Request flow tracing (API → service → DB)
   - Entry points, config, and key abstractions
   - Tech debt and risk annotations
   - Onboarding guide generation
   - Compatible: Claude, Codex
2. `skills/the-refactoring-planner/SKILL.md`
   - Scope analysis (what moves, what stays, what breaks)
   - Dependency graph partitioning
   - Migration plan with phases and rollback points
   - Risk matrix (data, API contracts, shared state)
   - Integration with tracking system (auto-creates task structure)
   - Compatible: Claude, Codex
3. `subagents/planner/AGENT.md`
   - Architecture planning role
   - Tools: Read, Glob, Grep, Bash (read-only)
   - Output: structured plan with Mermaid diagrams
4. Update `ROUTING.md` with planner spawn rules
5. Eval tasks: `13-codebase-onboarding.md`, `14-refactoring-plan.md`

### Phase 3: Workflow Integration & Design Pipeline

**Goal**: Connect Slack/Figma/Jira into agent workflows.

**Deliverables**:
1. `skills/the-figma-to-code/SKILL.md`
   - Figma MCP → design token/layout extraction
   - the-frontend-director for implementation
   - Playwright screenshot → visual comparison checklist
   - Iteration loop until visual match
   - Compatible: Claude, Codex (if MCP available)
2. `skills/the-slack-thread-worker/SKILL.md`
   - Slack MCP → thread content extraction
   - Task decomposition with acceptance criteria
   - Jira/resource prep and optional Stave registration
   - optional repo execution, verification, and PR creation
   - Compatible: Claude, Codex
3. `skills/the-api-migrator/SKILL.md`
   - Audit current usage (grep + AST-level scan)
   - Breaking change mapping (changelog/migration guide parsing)
   - TDD-first migration (uses the-tdd)
   - Verification (uses the-build-fixer for error recovery)
   - Compatible: Claude, Codex
4. Eval tasks: `15-figma-to-code.md`, `16-slack-thread-worker.md`, `17-api-migration.md`

### Phase 4: Multi-Role Expansion & Analytics

**Goal**: Expand orchestration roles and add data analysis.

**Deliverables**:
1. `subagents/qa-engineer/AGENT.md`
   - Spec/PR → test cases (happy, failure, edge, regression)
   - Uses the-tdd for execution
   - Output: structured test plan + generated test files
2. `skills/the-data-analyst/SKILL.md`
   - Data loading (CSV, JSON, API responses)
   - Exploratory analysis (summary stats, distributions, outliers)
   - Visualization generation (Recharts/ECharts components)
   - Insight report (structured markdown)
   - Compatible: Claude, Codex
3. Update `ROUTING.md` with qa-engineer spawn rules
4. Eval tasks: `18-qa-test-generation.md`, `19-data-analysis.md`

### Phase 5: Operating Model Reassessment (Complete)

**Goal**: Reorganize the harness around a thinner core, clearer memory layers,
and an active improvement loop that compounds through real use.

**Tracked plan**:
- `execution/sessions/2026-04-07_harness-reassessment/features/operating-model/tasks/reboot-plan/plan.md`

**Planned deliverables**:
1. Thin-core prompt reduction
   - Move bulky default guidance behind index-first routing where possible
   - Define a context-budget rule for future docs and skills
2. Memory model redesign
   - Promote `execution/` as the durable execution-memory path
   - Replace or restructure `learnings/` into a maintained operational memory
     system
   - Add recurring-failure and troubleshooting capture
3. Workflow and integration playbooks
   - Turn high-value MCP/tool flows into reusable operating playbooks
4. Active improvement loop
   - Require real eval runs for significant harness changes
   - Add a lightweight harness scorecard tied to roadmap decisions
5. Adoption and migration cleanup
   - Update docs, scripts, and repo-init flows to match the new model

**Initial slice delivered (2026-04-07)**:
1. `docs/instructions/CONTEXT_LOADING.md`
   - defines thin-core and index-first loading rules
2. `memory/`
   - scaffolds decisions, troubleshooting, playbooks, patterns, and scorecards
3. `scripts/new-task.sh`
   - no longer depends on `python3` to seed or update `work-handoff.md`
4. Core docs
   - now define `execution/` as execution memory and `memory/` as operational memory
5. Harness scorecard baseline
   - records the reboot starting point for future comparison

**Final outcome (2026-04-08)**:
- `execution/` is the only durable task-state root used by the harness
- `scripts/new-task.sh` and `scripts/init-repo.sh --with-execution` are the
  canonical scaffolding path
- `memory/` now contains 7 active playbooks and 2 decision records
- `evals/results/` now contains 4 real eval runs with aggregate pass coverage
- the active init, hook, scaffolding, and eval-summary path is python-free

**Why this phase exists**:
- Tracking was successfully reduced, but that only removed paperwork
- Learnings still do not grow naturally
- Evals exist but are not yet steering evolution
- The user needs the harness to support engineering, management, documentation,
  communication, and integrations as a compounding system

---

## Sustainability Mechanisms

### How future sessions find this plan
1. **ROADMAP.md** (this file) — referenced from AGENTS.md Document Map
2. **CHANGELOG.md** — records what was actually delivered per phase
3. **Memory** — operational memory records and scorecards point back to this file
4. **check-harness.sh** — validates ROADMAP.md exists and is referenced

### How to update this roadmap
- Mark phases as done when all deliverables are complete
- Add new phases at the end
- Update "Current phase" at the top
- Update CHANGELOG.md with actual changes
- Keep decisions in the Architecture Decisions section

### Phase status tracking
- ⬜ Not started
- 🔨 In progress
- ✅ Complete

| Phase | Status | Target |
|---|---|---|
| Phase 0: Foundation | ✅ | 2026-03-29 |
| Phase 1: Automation | ✅ | 2026-03-29 |
| Phase 2: Comprehension | ✅ | 2026-03-29 |
| Phase 3: Integration | ✅ | 2026-03-29 |
| Phase 4: Expansion | ✅ | 2026-03-29 |
| Phase 5: Operating Model Reassessment | ✅ | 2026-04-08 |
