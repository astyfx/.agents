# Changelog

Human-written log of major harness changes. Not generated.
For micro-changes, see `git log`.

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
