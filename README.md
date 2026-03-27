# .agents

Unified home for Claude and Codex configuration.

## Layout

- `AGENTS.md`: shared cross-agent operating guidance.
- `ARCHITECTURE.md`: authoritative guide to the harness structure and execution flow.
- `CLAUDE.md`: Claude-specific guidance when working inside the `.agents` repository.
- `docs/instructions/CONVENTIONS.md`: shared engineering conventions.
- `docs/instructions/LIBRARIES.md`: preferred libraries and dependency policy.
- `docs/instructions/TRACKING.md`: persistent plan/phase/task tracking standard.
- `docs/instructions/ENGINEERING_GROWTH.md`: agentic engineering coaching rules.
- `skills/`: shared skill library.
- `subagents/`: shared subagent definitions.
- `claude/`: Claude runtime directory; `claude/CLAUDE.md` is the global entry point that delegates to `AGENTS.md`.
- `codex/`: Codex runtime directory; `codex/AGENTS.md` delegates to `AGENTS.md`.

## Notes

This repository is intentionally initialized with a clean baseline.
The intended steady-state layout is:

- real Claude runtime data under `~/.agents/claude`
- real Codex runtime data under `~/.agents/codex`
- `~/.claude` as a symlink to `~/.agents/claude`
- `~/.codex` as a symlink to `~/.agents/codex`
- `~/.agents/AGENTS.md` as the canonical shared policy
- `~/.agents/ARCHITECTURE.md` as the structure and flow reference for harness maintenance
- thin Claude/Codex bridge files in the runtime directories for agent-specific entry

## Bootstrap

Run `scripts/init.sh` on a new device after cloning this repo.
It configures shell env vars, creates baseline files, migrates any existing
runtime state into `~/.agents`, and recreates `~/.claude` / `~/.codex` as
symlinks.
