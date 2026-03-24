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
- Respect the project's established patterns. Do not blindly overwrite them with this policy set.
- Apply `~/.agents/` policies only where the project has no explicit convention or where the user instructs otherwise.
- Check for project-level override files (`./CONVENTIONS.override.md`, `./LIBRARIES.override.md`) in the project root before falling back to this policy set.

## Tracking Trigger

- Treat work as substantial when it spans multiple files, changes behavior across components, introduces or refactors a feature, requires phased execution, or couples code and docs/process updates.
- For small one-file fixes, quick questions, or isolated doc edits, formal tracking artifacts are optional unless the user asks for them.

## Prompt Routing Default

- When the user is still shaping work (PRDs, specs, planning docs, fuzzy ideas) rather than requesting immediate execution, use `~/.agents/skills/the-refine-prompt/SKILL.md`.
- Do not force refinement for direct, concrete execution requests (bug fixes with logs, targeted code changes, clear debugging).
- See the skill file for detailed routing rules.

## Document Map & Core Rules

| Document | Purpose |
|----------|---------|
| `~/.agents/docs/instructions/CONVENTIONS.md` | Coding, git, PR, testing, logging, documentation conventions — **follow for all implementation** |
| `~/.agents/docs/instructions/LIBRARIES.md` | Preferred libraries and dependency selection — **follow before adding dependencies** |
| `~/.agents/docs/instructions/TRACKING.md` | Plan/phase/task artifact structure and lifecycle — **follow for substantial work** |
| `~/.agents/docs/instructions/ENGINEERING_GROWTH.md` | Coaching rules for agentic engineering skill development — **apply per-task** |
| `~/.agents/CLAUDE.md` | Claude-specific settings (applies only inside the `.agents` workspace) |
| `~/.agents/skills/`, `~/.agents/subagents/` | Shared reusable assets |

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
