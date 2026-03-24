# ROUTING.md

When to stay single-agent vs when to spawn subagents.

## Single-Agent (Default)

Stay in the main session for:
- Any task that involves writing production code (needs full context)
- Multi-file refactors with interdependencies (subagent isolation breaks cohesion)
- Tasks estimated < 30 minutes
- Anything where the implementer needs to understand their own earlier decisions

## Spawn a Researcher Subagent

Use `subagents/researcher/` when the **Discover phase** involves:
- Understanding > 5 unfamiliar files before implementation can begin
- Mapping an unknown codebase area (where does X live? what pattern does this use?)
- Identifying all locations that need to change for a refactor
- Any task where "I don't know what I don't know" is the main risk

The researcher returns a structured report. The main session reads the report and implements.

**How to spawn** (Claude): use the `subagents/researcher/AGENT.md` agent definition.
**How to spawn** (Codex): create a new task with restricted scope — Read/Grep only, no Write.

## Spawn a Reviewer Subagent

Use `subagents/reviewer/` when the **Verify phase** would benefit from independent review:
- Substantial implementation (> 3 files changed)
- Security-sensitive code
- Public API or interface changes
- When the implementer wants a "fresh eyes" perspective

The reviewer has no context of implementation decisions — it reads the code cold.
This catches issues the implementer is blind to because they know why they wrote it that way.

**How to spawn**: provide the list of changed files and the verification.md path.

## Do Not Spawn a Subagent

- To save context window space for trivial tasks (overhead not worth it)
- When the task is < 30 min and single-file
- When the subagent would need to write code (wrong role)
- When the researcher/reviewer would need the same context as the main session anyway

## Escalation

If a subagent hits a blocker (needs to write, needs context it does not have), it should:
1. Stop and report the blocker clearly
2. NOT try to work around its restrictions
3. Hand back to the main session with a clear description of what is needed
