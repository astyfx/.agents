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
| `researcher` | `Explore` | you need the exact research-report contract, or running under Codex |
| `planner` | `Plan` | you need the architecture-plan + Mermaid contract, or running under Codex |
| `reviewer` | — (no built-in equivalent) | always: fixed six-axis cold review |
| `qa-engineer` | — (no built-in equivalent) | always: fixed structured test plan |

Routing details: `docs/instructions/ROUTING.md`.
