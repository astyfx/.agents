# .agents

Unified home for Claude and Codex configuration.

## Layout

- `AGENTS.md`: shared cross-agent operating guidance.
- `ARCHITECTURE.md`: authoritative guide to the harness structure and execution flow.
- `CLAUDE.md`: Claude-specific supplemental behavioral guidance loaded by the Claude runtime bridge.
- `docs/instructions/CONVENTIONS.md`: shared engineering conventions.
- `docs/instructions/CONTEXT_LOADING.md`: thin-core prompt and on-demand context rules.
- `docs/instructions/RESPONSE_STYLE.md`: default response brevity and clarity rules.
- `docs/instructions/LIBRARIES.md`: preferred libraries and dependency policy.
- `docs/instructions/TRACKING.md`: lightweight execution-memory and handoff standard.
- `docs/instructions/ENGINEERING_GROWTH.md`: agentic engineering coaching rules.
- `execution/`: default execution-memory root for future substantial tasks.
- `memory/`: operational memory for patterns, troubleshooting, playbooks, decisions, and scorecards.
- `learnings/`: archived older reusable notes.
- `skills/`: shared skill library.
- `subagents/`: shared subagent definitions.
- `claude/`: Claude runtime directory; `claude/CLAUDE.md` is the global entry point that loads `AGENTS.md` and `CLAUDE.md`.
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
- `~/.agents/memory/` as the durable operational memory layer
- thin Claude/Codex bridge files in the runtime directories for agent-specific entry

## Bootstrap

Run `scripts/init.sh` on a new device after cloning this repo.
It configures shell env vars, creates baseline files, migrates any existing
runtime state into `~/.agents`, and recreates `~/.claude` / `~/.codex` as
symlinks.
