# CONTEXT_LOADING.md

Rules for keeping the default prompt surface thin and loading detail on demand.

## Goal

- Keep the always-on core small enough for everyday work.
- Move situational guidance into targeted docs, skills, playbooks, or memory
  records.
- Preserve quality by loading the right module at the right time instead of
  front-loading everything.

## Thin Core Default

Treat these as the default always-on context:

- `AGENTS.md`
- `docs/instructions/RESPONSE_STYLE.md`
- repo-local policy files when they exist

Everything else should be loaded because the task needs it, not by default.

## Load On Demand

- `docs/instructions/CONVENTIONS.md`
  - when implementing or reviewing code
- `docs/instructions/LIBRARIES.md`
  - before adding or switching dependencies
- `docs/instructions/TRACKING.md`
  - for substantial work or multi-session execution
- `docs/instructions/ROUTING.md`
  - when considering subagents or orchestration changes
- `ARCHITECTURE.md` and `ROADMAP.md`
  - before changing the harness itself
- `memory/`
  - when a reusable pattern, troubleshooting note, playbook, or decision is
    relevant
- `evals/README.md`
  - when validating harness changes or comparing outcomes

## Budget Rules

- If guidance is not needed for most tasks, it does not belong in the core.
- Do not duplicate the same rule across multiple always-on files.
- Prefer index-first docs that point to the exact deeper artifact.
- Prefer additive migration over disruptive moves when shrinking the core.
- When a repeated chat explanation would help future tasks, capture it in
  `memory/` instead of expanding `AGENTS.md`.

## Update Triggers

Update this file when:

- the always-on file set changes
- a new memory lane is introduced
- a repeated prompt-loading mistake is discovered
- a harness change moves guidance out of or into the core
