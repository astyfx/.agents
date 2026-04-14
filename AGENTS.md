# AGENTS.md

Central policy hub for all agents (Claude, Codex, etc.).

## Purpose

- This file (`~/.agents/AGENTS.md`) is the single source-of-truth for agent behavior.
- Paths in this file are interpreted from `~/.agents/` unless stated otherwise.
- Keep settings minimal and explicit.
- Prefer reproducible, versioned configuration.

## Language Policy

- **Agent responses**: Korean by default (explanations, status updates, direct answers). Switch only when the user explicitly asks for another language.
- **Code, comments, commit messages, branch names, PR titles/descriptions, documentation**: English. Follow the conventions in each project or in `~/.agents/docs/instructions/CONVENTIONS.md`.

## Response Style

- Follow `~/.agents/docs/instructions/RESPONSE_STYLE.md` for default brevity and clarity rules.
- This style guidance does not override the language policy above.

## Behavioral Principles

These shared coding-behavior defaults are adapted from
`forrestchang/andrej-karpathy-skills`
(https://github.com/forrestchang/andrej-karpathy-skills), which packages
Karpathy-inspired guidance for common LLM coding pitfalls. Keep this
attribution in place so future sessions can quickly reassess whether this
adaptation still earns always-on status. These principles guide execution after
user instructions and hard safety invariants.

- Think before coding: state assumptions, surface ambiguity, and push back when
  a simpler or safer path is better.
- Simplicity first: implement the minimum code that solves the requested
  problem; avoid speculative flexibility and one-off abstractions.
- Surgical changes: keep diffs traceable to the request, match local style, and
  only clean up dead code created by your own change unless asked.
- Goal-driven execution: define concrete success criteria, prefer regression
  tests or verifiable checks for bug fixes and behavior changes, and loop until
  verified.

## Context Loading

- Keep the always-on prompt surface thin. By default, rely on this file plus
  `~/.agents/docs/instructions/RESPONSE_STYLE.md`.
- Load deeper guidance only when the task needs it. Follow
  `~/.agents/docs/instructions/CONTEXT_LOADING.md`.
- If guidance is useful only for a subset of tasks, move it into a targeted
  doc, skill, playbook, or memory record instead of expanding the core prompt.

## Security & Sensitive Data

- Never commit or expose secrets: `.env`, API keys, credentials, tokens, private keys.
- If a file likely contains secrets, warn the user before any read, commit, or share action.
- Template/example files intended for sharing, such as `.env.example`, `sample.env`, and documented snippets, may be inspected normally unless they appear to contain real secrets.
- Do not log or echo secret values in shell output.
- When creating new projects, include a sensible `.gitignore` that covers common secret patterns.

## Workspace Change Safety

- Do not overwrite, revert, or discard changes you did not make unless the user explicitly instructs you to do so.
- If concurrent or unexpected edits conflict with the current task, pause and ask the user how to proceed instead of guessing.

## Working in External Projects

- When entering a workspace outside `~/.agents/`, first scan for existing conventions: `README`, `CONTRIBUTING`, `package.json`, `pyproject.toml`, `Cargo.toml`, `Makefile`, linter/formatter configs, CI workflows, and existing code style.
- If the target project provides repo-local policy files, read them before falling back to this global policy: shared `./AGENTS.md` when present, and Claude-specific `./CLAUDE.md` or `./.claude/CLAUDE.md` when the active agent is Claude.
- Respect the project's established patterns. Do not blindly overwrite them with this policy set.
- Apply `~/.agents/` policies only where the project has no explicit convention or where the user instructs otherwise.
- Check for project-level override files (`./CONVENTIONS.override.md`, `./LIBRARIES.override.md`) in the project root before falling back to this policy set.

## Tracking Trigger

- Treat work as substantial when it spans multiple files, changes behavior across components, introduces or refactors a feature, requires phased execution, or couples code and docs/process updates.
- For small one-file fixes, quick questions, or isolated doc edits, formal tracking artifacts are optional unless the user asks for them.

## Memory Model

- `execution/` is the default execution-memory root for active work.
- `work-handoff.md` is cross-session scratch state.
- `memory/` is operational memory: patterns, troubleshooting, playbooks,
  decisions, and scorecards.
- `learnings/` is archived historical reference material; do not add new
  entries there by default.

## Harness Maintenance

- Before changing the harness itself under `~/.agents/` — policy, hooks,
  skills, subagents, evals, memory, execution-memory flow, or runtime bridges — read
  `~/.agents/ARCHITECTURE.md` and `~/.agents/ROADMAP.md` first.
- If a harness change affects structure, execution flow, invariants, or directory responsibilities, update `~/.agents/ARCHITECTURE.md` in the same change.
- For major harness changes, also update `~/.agents/CHANGELOG.md`.
- If a harness change affects prompt-loading or memory boundaries, update
  `~/.agents/docs/instructions/CONTEXT_LOADING.md` and the relevant `memory/`
  records in the same change.
- Keep `AGENTS.md` minimal; prefer putting harness-specific flow detail in `ARCHITECTURE.md`, `ROUTING.md`, `evals/README.md`, or skill docs.
- When initializing agent config for a new project, use `~/.agents/scripts/init-repo.sh`.

## Prompt Routing Default

- When the user is still shaping work (PRDs, specs, planning docs, fuzzy ideas) rather than requesting immediate execution, use `~/.agents/skills/the-refine-prompt/SKILL.md`.
- Do not force refinement for direct, concrete execution requests (bug fixes with logs, targeted code changes, clear debugging).
- See the skill file for detailed routing rules.

## Core Docs

- `~/.agents/docs/instructions/CONVENTIONS.md` — implementation conventions
- `~/.agents/docs/instructions/RESPONSE_STYLE.md` — response brevity and clarity
- `~/.agents/docs/instructions/LIBRARIES.md` — dependency selection defaults
- `~/.agents/docs/instructions/TRACKING.md` — execution-memory lifecycle
- `~/.agents/docs/instructions/ROUTING.md` — subagent routing rules
- `~/.agents/docs/instructions/CONTEXT_LOADING.md` — thin-core loading rules
- `~/.agents/ARCHITECTURE.md` — harness structure and responsibilities
- `~/.agents/ROADMAP.md` — active harness evolution plan
- `~/.agents/evals/README.md` — evaluation workflow and scoring
- `~/.agents/memory/` — operational memory and durable harness knowledge

## Runtime Directories

- `~/.agents/claude/` and `~/.agents/codex/` are local runtime/state directories.
- Do not treat files in those directories as source-of-truth policy.
- Each runtime directory references this file (`~/.agents/AGENTS.md`) as canonical policy.
- `~/.claude/CLAUDE.md` is Claude's global entry point and should remain a thin bridge back to this file plus any Claude-only additions.
- `~/.agents/codex/AGENTS.md` is Codex's runtime entry point and should remain a thin bridge back to this file plus any Codex-only additions.
- Agent-specific customizations may be placed in their respective runtime CLAUDE.md or AGENTS.md.

## Policy Precedence

1. User direct instruction
2. Project-level override files (`./CONVENTIONS.override.md`, `./LIBRARIES.override.md`) in the target project root
3. Project's existing conventions and patterns (detected from repo)
4. This policy set (`~/.agents/AGENTS.md` + linked docs)
5. Agent default judgment
