# AGENTS.md

Shared rules for both Claude and Codex.

## Purpose

- This file is the policy hub for agent behavior.
- Keep settings minimal and explicit.
- Prefer reproducible, versioned configuration.

## Document Map

- `docs/instructions/CONVENTIONS.md`: coding, git, PR, testing, logging, documentation conventions
- `docs/instructions/LIBRARIES.md`: preferred libraries and dependency selection policy
- `docs/instructions/TRACKING.md`: required plan/phase/task artifact structure and lifecycle
- `docs/instructions/ENGINEERING_GROWTH.md`: coaching rules for agentic engineering skill development
- `CLAUDE.md` and `claude/`: Claude-specific guidance and settings
- `codex/`: Codex-specific guidance and settings
- `skills/` and `subagents/`: shared reusable assets

## Policy Precedence

1. User direct instruction
2. Project-level override files (`./CONVENTIONS.override.md`, `./LIBRARIES.override.md`) in the target project root (`./` means the current work/project root, not the `.agents` repo root)
3. This repository policy set (`AGENTS.md` + linked docs)
4. Agent default judgment

## Core Rules

- Follow `docs/instructions/CONVENTIONS.md` for implementation and collaboration conventions.
- Follow `docs/instructions/LIBRARIES.md` for dependency and framework choices.
- Follow `docs/instructions/TRACKING.md` for persistent plan/phase/task management.
- Follow `docs/instructions/ENGINEERING_GROWTH.md` to coach toward agentic engineering skills.
