# Tasks

## Research & Synthesis (this session)

- [x] 2026-03-24 Read Claude's proposed plan
- [x] 2026-03-24 Read Codex's tracking artifacts (plan.md, phases.md, tasks.md)
- [x] 2026-03-24 Build comparison matrix across 9 dimensions
- [x] 2026-03-24 Identify best-of-both on each dimension
- [x] 2026-03-24 Apply user constraint: memory = generic tech/arch, not project-specific
- [x] 2026-03-24 Write merged plan.md
- [x] 2026-03-24 Write phases.md, tasks.md, handoff.md

## Implementation Tasks (future sessions)

### Phase 0 — Security (Day 1)
- [x] 2026-03-24 Move GitHub PAT from settings.json to GITHUB_MCP_TOKEN env var
- [x] 2026-03-24 Add env var export to scripts/init.sh
- [ ] Verify MCP server still connects after change (manual — requires GITHUB_MCP_TOKEN to be set in shell)

### Phase 1 — Evals (Week 1)
- [x] 2026-03-24 Create evals/ directory with README.md (scoring rubric)
- [x] 2026-03-24 Write 10 task files (01 through 10)
- [ ] Run at least one task on Claude and one on Codex to validate format
- [ ] Document first results in evals/results/

### Phase 2 — Guardrails (Week 1-2)
- [x] 2026-03-24 Write scripts/hooks/pre-commit-lint.sh
- [x] 2026-03-24 Write scripts/hooks/pre-write-secrets.sh
- [x] 2026-03-24 Write scripts/hooks/post-write-format.sh
- [x] 2026-03-24 Write scripts/hooks/on-stop-handoff.sh
- [x] 2026-03-24 Wire all 4 hooks in claude/settings.json
- [x] 2026-03-24 Extend codex/AGENTS.md with equivalent invariant rules
- [x] 2026-03-24 Write scripts/check-harness.sh
- [x] 2026-03-24 Write scripts/new-tracked-task.sh
- [ ] Test: make bad commit, verify hook blocks (manual verification)

### Phase 3 — Skill System (Week 2-3)
- [x] 2026-03-24 Define skill frontmatter schema (add compatible-tools, category, test-prompts fields)
- [x] 2026-03-24 Retroactively update all 7 existing skills with new fields
- [x] 2026-03-24 Create skills/INDEX.md
- [x] 2026-03-24 Update the-skill-creator to maintain INDEX.md on new skill creation
- [x] 2026-03-24 Write the-code-reviewer/SKILL.md
- [x] 2026-03-24 Write the-tdd/SKILL.md
- [x] 2026-03-24 Write the-build-fixer/SKILL.md (+ scripts/classify-error.sh)
- [x] 2026-03-24 Write the-progress-tracker/SKILL.md

### Phase 4 — Learnings (Week 3)
- [x] 2026-03-24 Create learnings/ directory with README.md
- [x] 2026-03-24 Write seed content for react-patterns.md
- [x] 2026-03-24 Write seed content for typescript.md
- [x] 2026-03-24 Write seed content for testing.md
- [x] 2026-03-24 Write seed content for architecture.md
- [x] 2026-03-24 Write seed content for build-tooling.md, api-design.md, debugging.md
- [x] 2026-03-24 Define claude-progress.txt format (in the-progress-tracker SKILL.md)
- [x] 2026-03-24 Add .gitignore entry for claude-progress.txt

### Phase 5 — Subagents (Week 4)
- [x] 2026-03-24 Write subagents/researcher/AGENT.md
- [x] 2026-03-24 Write subagents/reviewer/AGENT.md
- [x] 2026-03-24 Write docs/instructions/ROUTING.md

### Phase 6 — Platform (Week 4+)
- [x] 2026-03-24 Write ARCHITECTURE.md (layer map + design principles)
- [x] 2026-03-24 Create CHANGELOG.md
- [x] 2026-03-24 Extend scripts/init.sh with health check section
- [x] 2026-03-24 check-harness.sh: ALL CHECKS PASSED

Owner: jacob.kim
