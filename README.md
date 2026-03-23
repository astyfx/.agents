# .agents

Unified home for Claude and Codex configuration.

## Layout

- `AGENTS.md`: shared cross-agent operating guidance.
- `CLAUDE.md`: Claude-specific guidance.
- `docs/instructions/CONVENTIONS.md`: shared engineering conventions.
- `docs/instructions/LIBRARIES.md`: preferred libraries and dependency policy.
- `docs/instructions/TRACKING.md`: persistent plan/phase/task tracking standard.
- `docs/instructions/ENGINEERING_GROWTH.md`: agentic engineering coaching rules.
- `skills/`: shared skill library.
- `subagents/`: shared subagent definitions.
- `claude/`: local runtime/state directory (not managed as repository policy).
- `codex/`: local runtime/state directory (not managed as repository policy).

## Notes

This repository is intentionally initialized with a clean baseline.
The intended steady-state layout is:

- real Claude runtime data under `~/.agents/claude`
- real Codex runtime data under `~/.agents/codex`
- `~/.claude` as a symlink to `~/.agents/claude`
- `~/.codex` as a symlink to `~/.agents/codex`

## Bootstrap

Run `scripts/init.sh` on a new device after cloning this repo.
It configures shell env vars, creates baseline files, migrates any existing
runtime state into `~/.agents`, and recreates `~/.claude` / `~/.codex` as
symlinks.
