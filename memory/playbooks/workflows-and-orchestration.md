# Workflows and Multi-Agent Orchestration

## Trigger

Use when a task is large enough that one context cannot hold it well, or quality
demands independent verification: comprehensive audits/reviews, broad migrations,
multi-source research, or design panels. A `Workflow` runs many subagents under a
deterministic script you control (fan-out, pipeline, loop, adversarial verify).

## Opt-in rule (do not skip)

A Workflow can spawn dozens of agents and spend a large token budget, so start one
**only** when one of these holds:

- the user typed `ultracode`, or ultracode is on for the session,
- the user asked for multi-agent orchestration / a workflow in their own words,
- a skill or command instructs you to run one.

For any other task that would merely benefit from parallelism, describe what a
workflow could do and the rough cost, and let the user opt in. Use a single
`Agent` spawn (built-in `Explore`/`Plan` or a custom subagent) for ordinary
fan-out — see `docs/instructions/ROUTING.md`.

## Inputs

- a work-list you can enumerate (files, call-sites, dimensions, questions)
- a success definition per item (what "done" or "confirmed" means)
- the scale the user asked for (quick check vs. thorough audit)

## Core building blocks

- `agent(prompt, opts)` — one subagent. With `schema` (JSON Schema) it returns a
  validated object instead of text. `opts`: `label`, `phase`, `schema`, `model`,
  `effort`, `isolation: 'worktree'`, `agentType`.
- `pipeline(items, stage1, stage2, ...)` — **the default.** Each item flows
  through all stages independently, no barrier between stages. Wall-clock is the
  slowest single chain, not sum-of-slowest-per-stage.
- `parallel(thunks)` — a barrier: awaits all thunks. Use **only** when a stage
  genuinely needs every prior result at once (dedup/merge, early-exit on zero).
- `phase(title)` / `log(msg)` — progress grouping and narration.
- `budget` — `budget.total`, `budget.spent()`, `budget.remaining()` for scaling
  depth to a token directive.

## Steps

1. **Scout inline first.** List the files/channels/diff in the main session to
   discover the work-list. Do not orchestrate before you know the shape of the work.
2. **Pick the shape.** Default to `pipeline()`. Reach for a `parallel()` barrier
   only when cross-item context is required before the next stage.
3. **Author `meta` as a pure literal** (`name`, `description`, `phases`) — no
   variables or interpolation.
4. **Force structure where it matters.** Give finder/verifier stages a `schema`
   so results are validated objects, not parsed text.
5. **Verify adversarially.** For findings that must be correct, spawn N skeptics
   prompted to refute; keep only what survives a majority. Use diverse lenses
   (correctness, security, repro) when a finding can fail in more than one way.
6. **Scale to the ask.** A few finders + single-vote verify for "find a bug";
   larger finder pool + 3-5 vote adversarial pass + synthesis for "thoroughly audit".
7. **Read each result and decide the next phase.** Run several smaller workflows
   in sequence (understand -> design -> implement -> review) rather than one
   monolith, so you stay in the loop.

## Quality patterns

- **Adversarial verify** — N independent skeptics per claim, default-to-refuted.
- **Loop-until-dry** — keep spawning finders until K consecutive rounds find
  nothing new; dedup against everything seen, not just confirmed.
- **Judge panel** — N independent attempts from different angles, scored by
  parallel judges, synthesized from the winner.
- **Completeness critic** — a final agent that asks "what modality/claim/source
  did we skip?"; its answer becomes the next round.
- **No silent caps** — if you bound coverage (top-N, sampling, no-retry),
  `log()` what was dropped so it is not read as full coverage.

## Anti-patterns

- A barrier (`parallel` between stages) "because it is cleaner" — if the middle
  transform is just flatten/map/filter with no cross-item dependency, it belongs
  inside a pipeline stage.
- Running a Workflow without an explicit opt-in.
- One giant workflow that hides intermediate results from you — prefer a chain of
  scoped phases you read between.

## Expected artifacts

- a deterministic script (auto-persisted under the session dir; iterate via
  `scriptPath`) and a synthesized result the main session relays.

## Verification / rollback

- Confirm verified findings survived the adversarial pass before acting on them.
- If a workflow stalls or over-spends, kill it and resume from its `runId`
  (unchanged `agent()` calls return cached results); narrow scope and rerun.
