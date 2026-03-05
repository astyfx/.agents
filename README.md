# .agents

Unified home for Claude and Codex configuration.

## Layout

- `AGENTS.md`: shared cross-agent operating guidance.
- `CLAUDE.md`: Claude-specific guidance.
- `docs/instructions/CONVENTIONS.md`: shared engineering conventions.
- `docs/instructions/LIBRARIES.md`: preferred libraries and dependency policy.
- `docs/instructions/TRACKING.md`: persistent plan/phase/task tracking standard.
- `docs/instructions/ENGINEERING_GROWTH.md`: agentic engineering coaching rules.
- `claude/`: runtime/settings root used via `CLAUDE_CONFIG_DIR`.
- `codex/`: runtime/settings root used via `CODEX_HOME`.
- `skills/`: shared skill library.
- `subagents/`: shared subagent definitions.

## Notes

This repository is intentionally initialized with a clean baseline.
Existing `~/.claude` and `~/.codex` are not copied here.

## Bootstrap

Run `scripts/init.sh` on a new device after cloning this repo.
It configures shell env vars and creates clean baseline files.
