# Changelog

Human-written log of major harness changes. Not generated.
For micro-changes, see `git log`.

## 2026-04-11 — Frontend Director Taste Tuning

Tuned the default frontend implementation skill to match the user's preferred
product taste more closely.

### Changed
- **`skills/the-frontend-director/SKILL.md`** now biases toward minimal,
  refined product UI with Linear/Sentry-style clarity
- **`skills/the-frontend-director/SKILL.md`** now explicitly prefers existing
  repo improvement, dashboard/admin work, and Figma-backed implementation
- **`skills/the-frontend-director/SKILL.md`** now treats dated enterprise UI,
  excessive color, and readability regressions as default anti-goals
- **`skills/INDEX.md`** now describes the skill with the narrower product-UI
  focus

## 2026-04-10 — Removed ui-ux-pro-max

Removed the bundled `ui-ux-pro-max` skill after narrowing the active UI surface
to skills that fit repo-bound implementation work more directly.

### Changed
- **`skills/INDEX.md`** no longer lists `ui-ux-pro-max`

### Removed
- **`skills/ui-ux-pro-max/`**

### Decision Notes
- `the-frontend-director` remains the default UI implementation skill
- `the-figma-to-code` remains the design-handoff implementation path
- replacement exploration is better handled by targeted external skills than by
  keeping a large local reference pack that rarely matches the active workflow

## 2026-04-10 — Slack Workflow Skill Consolidation

Reduced overlap in the Slack workflow surface by collapsing planning, setup,
and execution paths into one primary skill.

### Changed
- **`skills/the-slack-thread-worker/SKILL.md`** now covers three modes:
  task extraction, Jira/resource prep, and end-to-end execution with PR output
- **`memory/playbooks/slack-thread-to-task-and-jira-setup.md`** now routes all
  Slack-driven work through the consolidated skill and documents the three-mode
  workflow
- **`skills/INDEX.md`** now lists `the-slack-thread-worker` as the single
  active Slack workflow skill
- **`skills/ui-ux-pro-max/SKILL.md`** now positions itself as a reference-heavy
  greenfield design aid rather than a default implementation skill

### Removed
- **`skills/the-slack-to-task/`**
- **`skills/the-work-prep/`**

## 2026-04-09 — Skill Reference Validation In Harness Checks

Expanded harness validation so skill renames and deletions are easier to catch
before stale playbooks or indexes drift out of sync.

### Changed
- **`scripts/check-harness.sh`** now verifies that each `SKILL.md` frontmatter
  name matches its directory name
- **`scripts/check-harness.sh`** now checks that `skills/INDEX.md` stays in
  sync with the actual installed skill set
- **`scripts/check-harness.sh`** now checks that active playbooks only mention
  skill names that still exist

## 2026-04-09 — Selective Evals And Curated Memory Guidance

Tightened the operating-model boundaries after the reboot so the harness keeps
high-signal memory and does not accumulate ceremony.

### Changed
- **`memory/README.md`** now states explicitly that `memory/` is curated
  operational memory, not a raw-source or transcript-ingestion layer
- **`learnings/README.md`** now treats `learnings/` as an archive-only legacy
  lane rather than a place to keep adding new reusable notes
- **`evals/README.md`** now defines evals as selective, decision-linked runs
  and documents when not to run them
- **`scripts/new-eval-result.sh`** now scaffolds `eval_type`,
  `change_under_test`, and `decision_target` so each result records why the run
  exists
- **`scripts/summarize-evals.py`** now reports contextualized coverage and eval
  type distribution instead of only agent-level aggregates
- **existing real eval results** were backfilled with decision context so the
  current evidence base is interpretable without chat history

### Added
- **Decision record**:
  - `memory/decisions/2026-04-09-curated-memory-and-selective-evals.md`

### Decision Notes
- Auto-ingestion remains out of scope for now; if automation is added later, it
  should draft candidate records rather than publish durable memory directly

## 2026-04-08 — Execution Path Finalization And Legacy Cleanup

Finalized the execution-memory rename by removing transitional compatibility
paths and stale scratch artifacts.

### Changed
- **`execution/`** now contains the durable task records that previously lived
  under `tracking/`
- **`scripts/new-task.sh`** is now the canonical task scaffolder; the older
  script name was retired
- **`scripts/init-repo.sh`**, **`scripts/check-harness.sh`**, and
  **`scripts/init.sh`** now assume `execution/` only and no longer advertise a
  `--with-tracking` or path-override fallback
- **`scripts/hooks/on-stop-handoff.sh`** now reads only `Active Task Path`
- **core docs, skills, playbooks, and the reboot handoff artifacts** now point
  at `execution/` and the renamed scaffolder/playbook surfaces

### Removed
- **`tracking/`** as a runtime path and compatibility lane
- **`claude-progress.txt`** as a leftover legacy scratch artifact
- **`HARNESS_TASK_ROOT`** and `--with-tracking` as migration-only escape hatches

## 2026-04-08 — Execution Memory Default + Connector Playbook

Resolved the long-standing path-name mismatch between execution semantics and
the `tracking/` directory name.

### Changed
- **`AGENTS.md`**, **`ARCHITECTURE.md`**, **`README.md`**,
  **`docs/instructions/TRACKING.md`**, and **`memory/README.md`** now treat
  `execution/` as the default execution-memory root and `tracking/` as a legacy
  compatibility lane
- **`scripts/new-task.sh`** now scaffolds `execution/sessions/...` by
  default via the new `HARNESS_TASK_ROOT` default, while preserving the old
  script name for compatibility
- **`scripts/init-repo.sh`** now supports `--with-execution` and keeps
  `--with-tracking` as a legacy alias during migration
- **`scripts/init.sh`**, **`scripts/check-harness.sh`**, and
  **`skills/the-progress-tracker`** now reflect the execution-memory default
- **`skills/the-slack-to-task`** and the affected playbooks now refer to
  execution memory rather than treating `tracking/` as the default future path

### Added
- **Decision record**:
  - `memory/decisions/2026-04-08-execution-memory-default-path.md`
- **Connector-heavy playbook**:
  - `memory/playbooks/figma-design-to-implementation-and-visual-verification.md`
- **Scorecard snapshot**:
  - `memory/scorecard/2026-04-08-execution-default-and-figma-playbook.md`

### Decision Notes
- The next validation gap is real connector-heavy workflow evidence, not naming

## 2026-04-07 — Operating Model Reboot Slice 1

First implementation slice of the harness operating-model reboot.

### Changed
- **`AGENTS.md`** now defines a thinner core, explicit context-loading rules,
  and a clearer memory model (`tracking/` for execution memory, `memory/` for
  operational memory)
- **`ARCHITECTURE.md`**, **`ROADMAP.md`**, **`README.md`**, and
  **`docs/instructions/TRACKING.md`** now treat `memory/` as the primary
  durable knowledge layer and `learnings/` as legacy compatibility
- **`scripts/new-task.sh`** no longer depends on `python3` to seed or
  update `work-handoff.md`, fixing a real failure mode on machines where
  `/usr/bin/python3` is only the Command Line Tools bootstrap stub
- **`scripts/check-harness.sh`** now validates the new context-loading and
  operational-memory surfaces
- **`skills/the-progress-tracker`** and **`docs/instructions/ENGINEERING_GROWTH.md`**
  now reflect the execution-memory vs operational-memory split

### Added
- **`docs/instructions/CONTEXT_LOADING.md`**: thin-core, index-first loading rules
- **`memory/`**:
  - `README.md` for the operational-memory model
  - `decisions/` for durable harness decisions
  - `troubleshooting/` for recurring failure modes
  - `playbooks/` for repeatable workflows and integrations
  - `patterns/` for stable cross-project guidance
  - `scorecard/` for measurable harness baselines
- **Initial decision record** for the operating-model reboot
- **Initial troubleshooting record** for the `python3` bootstrap-stub issue
- **Initial scorecard baseline** for future comparison

### Decision Notes
- The reboot remains additive-first: `learnings/` still exists, but new durable
  knowledge should land in `memory/`
- `tracking/` keeps its path for now, but its semantics are now explicitly
  limited to execution memory
- Real failure modes are now expected to become either troubleshooting records
  or direct harness fixes, not just chat history

## 2026-04-06 — Lightweight Tracking Refactor

Refactored tracking from a mandatory multi-file bundle into a lite-by-default
task record model.

### Changed
- **`docs/instructions/TRACKING.md`** now defines a one-file default:
  `tracking/.../handoff.md` is the canonical durable record for most tasks
- **`scripts/new-task.sh`** now scaffolds only `handoff.md` by default
  and links `work-handoff.md` to that task
- **`scripts/new-task.sh --mode expanded`** now scaffolds the optional
  deep artifacts when a task truly needs them
- **`ARCHITECTURE.md`**, **`AGENTS.md`**, and **`README.md`** now describe
  tracking as lightweight by default rather than a mandatory audit bundle
- **`the-progress-tracker`**, **`the-refactoring-planner`**,
  **`the-build-fixer`**, **`the-slack-to-task`**, **`ROUTING.md`**, and the
  reviewer subagent now treat `handoff.md` as the default durable artifact

### Decision Notes
- The default now mirrors the lighter patterns used by popular agent workflows:
  one canonical task record, optional deeper artifacts
- Detailed plans and verification logs are still supported, but only when the
  work is large enough to justify them

## 2026-04-02 — Work Handoff Scratch Refresh

Refined the cross-session scratch protocol to feel like a clean handoff instead
of a model-specific progress dump.

### Changed
- **Primary scratch artifact renamed** from `claude-progress.txt` to
  `work-handoff.md`
- **`the-progress-tracker`** now describes a handoff-oriented format with
  remaining work, recommended next actions, and nice-to-have follow-ups
- **`new-task.sh`** now seeds `work-handoff.md` and can migrate from a
  legacy `claude-progress.txt`
- **`on-stop-handoff.sh`** and **`check-harness.sh`** now prefer
  `work-handoff.md` while still tolerating legacy scratch files
- **`init-repo.sh`**, **`init.sh`**, **`ARCHITECTURE.md`**, and eval docs now
  describe the new model-neutral artifact

### Decision Notes
- The durable source of truth remains `tracking/.../handoff.md`
- Legacy `claude-progress.txt` support is retained only as a compatibility path
- The new format emphasizes handoff quality over raw progress logging

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
- **Progress/task link support** in the scratch handoff file via the active task path field

### Changed
- **`ARCHITECTURE.md`** rewritten as the authoritative harness structure guide with current flow diagrams
- **`AGENTS.md`** now requires future harness work to read and update `ARCHITECTURE.md`
- **`pre-write-secrets.sh`** strengthened from filename-only blocking to content- and tracked-file-aware checks
- **Claude hooks** now protect both `Write` and `Edit` for secret-sensitive changes
- **`on-stop-handoff.sh`** now attempts durable handoff sync when an active tracking task is known
- **`new-task.sh`** no longer hardcodes the owner and can seed/update the scratch handoff file
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
- **Utility scripts**: `scripts/check-harness.sh` (health validation), `scripts/new-task.sh` (task scaffolding)
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
