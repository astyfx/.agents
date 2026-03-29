# Changelog

Human-written log of major harness changes. Not generated.
For micro-changes, see `git log`.

## 2026-03-29 — Codex Parity & Expansion (v3)

Major expansion driven by OpenAI Codex use cases analysis, filtered through SaaS engineer/manager role.

### Architecture Decisions
- **AD-1: Global vs Per-Repo Split** — `.agents` stays global; per-repo config scaffolded via `init-repo.sh`
- **AD-2: Codex Parity v2** — assumes Codex subagent/plugin support; hook wiring section added to `codex/AGENTS.md`
- **AD-3: Role-Based Skill Audit** — prioritized skills for SaaS frontend/backend engineer & manager workflow

### Added
- **ROADMAP.md**: living evolution plan with phases, architecture decisions, and priorities
- **scripts/init-repo.sh**: per-repo scaffolding (`.claude/`, `.codex/`, override templates, optional tracking/CI)
- **8 new skills**:
  - `the-pr-reviewer` (review): automated PR review with GitHub integration
  - `the-improvement-loop` (workflow): scored iterative refinement
  - `the-codebase-mapper` (workflow): module maps, request flows, onboarding guides
  - `the-refactoring-planner` (workflow): large-scale refactoring and product separation plans
  - `the-figma-to-code` (ui): Figma MCP → code with visual verification loop
  - `the-slack-to-task` (workflow): Slack conversations → tracked tasks + Jira
  - `the-api-migrator` (workflow): API/dependency migration with TDD
  - `the-data-analyst` (workflow): dataset analysis, visualization, insight reports
- **2 new subagents**:
  - `planner`: architecture planning for refactoring/separation
  - `qa-engineer`: test case generation from specs/PRs
- **9 new eval tasks**: 11-pr-auto-review through 19-data-analysis

### Changed
- **ARCHITECTURE.md**: added Per-Repo model section, Codex Parity Table v2, init-repo in directory responsibilities
- **AGENTS.md**: added ROADMAP.md to document map and harness maintenance rules
- **codex/AGENTS.md**: added hook wiring section (v2) and subagent definitions section
- **ROUTING.md**: unified Claude/Codex spawn syntax, added planner and qa-engineer spawn rules
- **check-harness.sh**: validates ROADMAP.md, init-repo.sh presence and executability
- **skills/INDEX.md**: updated with all 19 skills

### Tested
- `init-repo.sh` verified on `~/workspace/stave` and `~/workspace/agentize`
- All harness health checks pass

### Decision Notes
- All phases (0–4) from ROADMAP.md delivered in a single session
- Skills designed for cross-agent parity (Claude + Codex compatible where possible)
- Per-repo init tested on real projects to validate scaffolding
- Memory system initialized with user role and evolution plan context

## 2026-03-25 — Harness Hardening Pass

Focused hardening pass after the v2 expansion.

### Added
- **Eval operations scripts**:
  - `scripts/new-eval-result.sh` to scaffold result files
  - `scripts/summarize-evals.py` to aggregate pass rate, rework, and policy compliance
- **Progress/task link support** in `claude-progress.txt` via `Tracking Task Path`

### Changed
- **`ARCHITECTURE.md`** rewritten as the authoritative harness structure guide with current flow diagrams
- **`AGENTS.md`** now requires future harness work to read and update `ARCHITECTURE.md`
- **`pre-write-secrets.sh`** strengthened from filename-only blocking to content- and tracked-file-aware checks
- **Claude hooks** now protect both `Write` and `Edit` for secret-sensitive changes
- **`on-stop-handoff.sh`** now attempts durable handoff sync when an active tracking task is known
- **`new-tracked-task.sh`** no longer hardcodes the owner and can seed/update `claude-progress.txt`
- **`check-harness.sh`** now validates more semantic wiring instead of only file presence
- **`evals/README.md`** now documents the result scaffolding and summary workflow

### Decision Notes
- No new skills or subagents were added in this pass
- The focus was wiring, enforcement, and operability rather than more surface area
- `ARCHITECTURE.md` is now the required reference doc for future harness maintenance

## 2026-03-24 — Harness Evolution v2

Major upgrade: added enforcement layer, evals, 4 new skills, learnings, subagents, and platform docs.

### Added
- **Hook system** (Claude): `scripts/hooks/` with 4 hooks wired in `claude/settings.json`
  - `pre-commit-lint.sh`: blocks non-Conventional Commits at the tool level
  - `pre-write-secrets.sh`: blocks writes to secret file patterns
  - `post-write-format.sh`: auto-formats after Write/Edit
  - `on-stop-handoff.sh`: creates session snapshot on Stop
- **Codex invariants**: extended `codex/AGENTS.md` with equivalent enforcement rules for hook-less Codex
- **Utility scripts**: `scripts/check-harness.sh` (health validation), `scripts/new-tracked-task.sh` (task scaffolding)
- **Evals**: `evals/` with 10 benchmark tasks for agent comparison
- **Skill schema**: added `compatible-tools`, `category`, `test-prompts` to all skill frontmatter
- **skills/INDEX.md**: discovery table for all registered skills
- **New skills**: `the-code-reviewer`, `the-tdd`, `the-build-fixer`, `the-progress-tracker`
- **Learnings**: `learnings/` with 7 generic tech/architecture knowledge files
- **Subagents**: `subagents/researcher/` and `subagents/reviewer/` definitions
- **Routing guide**: `docs/instructions/ROUTING.md` for subagent spawn decisions
- **Platform docs**: `ARCHITECTURE.md` (layer map + design principles), `CHANGELOG.md` (this file)

### Changed
- `claude/settings.json`: GitHub PAT moved from hardcoded value to `$GITHUB_MCP_TOKEN` env var
- `scripts/init.sh`: added `GITHUB_MCP_TOKEN` guidance and health check section
- `codex/AGENTS.md`: extended from 3-line delegate to full Codex-specific invariants

### Decision Notes
- Evals prioritized over more skills (Codex plan insight): measure before building
- Memory designed as generic tech knowledge (not project-specific) per user requirement
- Cross-agent parity via artifact format (plain markdown), not mechanism uniformity
- AGENTS.md unchanged: still under 300 lines, still human-written

---

## 2026-03-16 to 2026-03-24 — Initial Foundation (v1)

See `git log` for detailed history. Summary:
- Unified Claude and Codex runtimes under `~/.agents/`
- Established symlink architecture (`~/.claude` → `~/.agents/claude`)
- Wrote canonical `AGENTS.md` policy
- Documented conventions, libraries, tracking, engineering growth
- Added 7 initial skills (UI/design focused)
- Created `scripts/init.sh` bootstrap
