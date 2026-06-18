# ROUTING.md

How to pick the right execution shape: stay single-agent, spawn a built-in or
custom subagent, run a multi-agent Workflow, or schedule recurring/background work.

Read this when considering orchestration. Default to the cheapest shape that fits.

## Decision Spectrum (cheapest first)

1. **Single agent (main session)** — default for almost everything.
2. **Built-in agent type** (`Explore`, `Plan`, `general-purpose`) — read-heavy
   fan-out or planning you want off the main context.
3. **Custom subagent** (`subagents/*`) — only when you need a fixed output shape
   or a hard tool restriction the built-ins do not give you.
4. **Workflow** (deterministic multi-agent orchestration) — opt-in only; many
   independent units of work that benefit from fan-out + verification.
5. **Scheduled / background / remote** — recurring, long-running, or detached work.

Pick the lowest item on this list that still fits the task. Escalate only when
the cheaper shape genuinely cannot do the job.

## 1. Single-Agent (Default)

Stay in the main session for:
- Any task that involves writing production code (needs full context)
- Multi-file refactors with interdependencies (subagent isolation breaks cohesion)
- Tasks estimated < 30 minutes
- Anything where the implementer needs to understand their own earlier decisions

## 2. Built-In Agent Types (prefer over custom subagents)

The runtime ships agent types that cover the most common spawn cases. Prefer
these before reaching for a custom `subagents/` definition:

| Built-in | Use for | Replaces custom |
|---|---|---|
| `Explore` | Broad read-only search across many files/dirs; "where does X live?", convention sweeps. Returns conclusions, not file dumps. | the read/search default |
| `Plan` | Design an implementation/refactoring strategy; step-by-step plan with trade-offs and critical files. | the planning default |
| `general-purpose` | Open-ended multi-step research/search when match confidence is low. | — |

- Launch multiple Explore agents in one message for independent search areas.
- These run with their own context, so the main session stays lean.
- The agent's final message is the result — relay what matters, not the transcript.

## 3. Custom Subagents (`subagents/*`)

Use a custom subagent only when a built-in does not give you what you need —
specifically a **fixed structured output shape** or a **hard tool restriction**.
Custom definitions also keep Claude/Codex parity (Codex spawns the same `AGENT.md`).

| Subagent | Spawn when | Why not a built-in |
|---|---|---|
| `reviewer` | Independent post-implementation review (>3 files, security-sensitive, public API/interface change). Reads code cold. | Fixed six-axis review contract; no built-in equivalent. |
| `qa-engineer` | Verify phase needs a structured test plan (complex logic, security-sensitive, >5 files). Produces a plan, not test code. | Fixed test-plan output shape; no built-in equivalent. |

For read/search and planning, use the built-in `Explore` and `Plan` directly — there are no custom research/plan subagents.

**How to spawn**:
- Claude: pass the `subagents/<name>/AGENT.md` definition via the Agent tool
  (`agentType`), or use the matching built-in type when the structured contract
  is not required.
- Codex: spawn a native subagent referencing `~/.agents/subagents/<name>/AGENT.md`
  and apply the same tool restrictions declared in its frontmatter.

## 4. Workflows (deterministic multi-agent orchestration)

A `Workflow` runs many subagents under a script you control (fan-out, pipeline,
parallel, loop-until-done, adversarial verify). Use it to be comprehensive
(decompose + cover in parallel), confident (independent verification before
committing), or to take on scale one context cannot hold.

**Opt-in only.** Do NOT start a Workflow unless one of these holds:
- the user typed `ultracode`, or ultracode is on for the session,
- the user asked for multi-agent orchestration / a workflow in their own words,
- a skill or command instructs you to run one.

For any other task that would merely benefit from parallelism, describe what a
workflow could do (and rough cost) and let the user opt in.

**When it fits**: review across dimensions then verify each finding, migrate many
call-sites, audit/research sweeps, design panels (N approaches → judge → synthesize).

**Defaults when you do run one**:
- `pipeline()` is the default; reach for a `parallel()` barrier only when a stage
  genuinely needs all prior results at once (dedup/merge, early-exit on zero).
- Scout inline first (list files/channels/diff), then pipeline over the work-list.
- Scale to the ask: a few finders for "find a bug"; larger pools + 3–5 vote
  adversarial verify + synthesis for "thoroughly audit".

Detailed authoring patterns: `memory/playbooks/workflows-and-orchestration.md`.

## 5. Scheduled / Background / Remote

For recurring, long-running, or detached work — `/loop`, `/schedule`
(cron routines), `ScheduleWakeup`, `CronCreate`, background `Bash`, and
`isolation: remote`/`worktree` agents.

Routing rules and anti-patterns: `memory/playbooks/scheduled-and-background-agents.md`.

## Do Not Spawn / Orchestrate

- To save context on trivial tasks (spawn overhead not worth it).
- Single-file tasks under ~30 min.
- When the helper would need to write code (Explore/Plan are read-only).
- When the helper needs the same full context the main session already has.
- A Workflow without an explicit opt-in (see §4).

## Escalation

If a subagent hits a blocker (needs to write, needs context it does not have):
1. Stop and report the blocker clearly.
2. Do NOT work around tool restrictions.
3. Hand back to the main session with a precise description of what is needed.
