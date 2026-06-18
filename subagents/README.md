# subagents

Reusable custom subagent definitions.

## Built-in types come first

The runtime ships built-in agent types (`Explore`, `Plan`, `general-purpose`)
that cover most spawn cases with more capability and better integration than a
custom definition. Reach for a custom subagent here **only** when you need
something a built-in does not give you:

- a fixed structured-output contract (e.g. the reviewer's six-axis report, the
  qa-engineer's test-plan shape), or
- Claude/Codex parity (Codex spawns these same `AGENT.md` files).

| Custom subagent | Prefer built-in instead | Keep custom when |
|---|---|---|
| `reviewer` | — (no built-in equivalent) | always: fixed six-axis cold review |
| `qa-engineer` | — (no built-in equivalent) | always: fixed structured test plan |

For read/search and planning, use the built-in `Explore` and `Plan` directly —
the former `researcher` and `planner` subagents were removed as redundant.

Routing details: `docs/instructions/ROUTING.md`.
