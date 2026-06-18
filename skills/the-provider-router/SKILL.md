---
name: the-provider-router
description: "Design reference and change discipline for Stave's provider routing layer — intent classification, orchestration, model resolution, fallback, Stave Auto. Use when designing how Stave turns a turn into provider calls, adding/renaming intents/roles/providers, changing Stave Auto logic, or editing electron/providers/stave-* or the model resolver."
compatible-tools: [claude, codex]
category: architecture
test-prompts:
  - "stave auto 동작 바꾸고 싶어"
  - "redesign the provider router"
  - "intent classification 다시 짜려고"
  - "orchestration 없애고 단순화"
  - "Stave Auto에 새 모드 추가"
  - "provider routing을 role-based에서 graph-based로 바꾸자"
  - "model resolver 전면 개편"
  - "add a new intent and wire it through routing"
---

# The Provider Router (Stave Auto)

Stave's provider routing layer is what turns `providerId: "stave"` (Stave Auto)
into concrete model calls. It sits between user intent and the provider SDKs.

This skill is for anyone working on that layer — whether the change is a
small extension or a full redesign. It does two things:

1. **Map the current system** so the change is informed, not accidental.
2. **Enforce a "break the rules on purpose" discipline** so intentional
   departures from the current design leave a trail instead of silent drift.

It is not a guardrail. If the current design is wrong, the skill is here to
help you replace it cleanly.

## Use This Skill When

- Designing or redesigning Stave Auto's routing logic.
- Changing intent classification strategy (labels, model, prompt, or the
  decision to classify at all).
- Changing orchestration (adding/removing roles, switching sequential →
  graph-based, collapsing the supervisor).
- Adding, removing, or reordering providers in the fallback chain.
- Changing how `permissionMode`, `sandbox`, `thinking`, or `dangerous_skip`
  propagate.
- Adding a new model, role, or intent that must be wired through.

## Do Not Use This Skill When

- The change is inside a single provider SDK wrapper (Claude or Codex
  internals) with no effect on routing.
- UI-only work that consumes routing events without changing them.

## Map: What's Currently Load-Bearing

Know these pieces before deciding what to change. Each one exists for a
concrete reason — if you remove or rewrite it, do so knowing what it was
doing.

### M1 — Intent preprocessor

A lightweight classifier labels the turn (plan, analyze, implement,
quick_edit, general) or escalates to orchestration. Load-bearing because:

- downstream routing keys off the label
- telemetry aggregates by intent
- some permissions default from intent (plan → read-only sandbox)

Replacing it: if you remove classification, explicitly decide what replaces
those three functions (routing key, telemetry dimension, default permissions).

### M2 — Direct routing path

For classified intents, `resolveModelForIntent(intent, ctx)` returns a
`(providerId, modelId)` tuple and the runtime re-enters the provider layer.
Load-bearing because it is the fast path — most turns take it.

Replacing it: the replacement must still produce an auditable
`(provider, model)` decision per turn; agents downstream read it from the
routing log.

### M3 — Orchestration supervisor

For escalated turns, a supervisor decomposes the turn into role-based
subtasks (plan / analyze / implement / verify), resolves each to a model,
runs them in sequence, and synthesizes. Load-bearing because:

- it is the only path that can use multiple models on one turn
- the synthesizer's input contract is coupled to the role list
- role budgets (tokens, turns) are the cost control for complex turns

Replacing it: a graph, a DAG, a planner-actor loop — all valid replacements.
Whatever you pick must preserve (a) per-role budget enforcement,
(b) structured hand-off between stages, (c) a single final artifact for the
renderer to consume.

### M4 — Fallback chain

When the preferred provider is unavailable (auth, rate limit, transient),
the chain walks to the next provider. Load-bearing because it is the only
reason Stave Auto keeps working during outages.

Replacing it: if you switch to retries, circuit-breakers, or provider pools,
keep the property that "the user's turn completes or surfaces a clear
terminal error" — silent degradation is the failure mode to avoid.

### M5 — Permission / sandbox propagation

`permissionMode`, `sandbox`, `thinking`, `dangerous_skip` flow from the
user's turn through routing to the SDK call. Some roles override (plan
forces read-only sandbox). Load-bearing because these are the safety
contract users trust.

Replacing it: any redesign must still let a user say "plan only, no writes"
and have that survive routing.

### M6 — Routing log

Every turn writes a routing decision record (intent, roles, models,
fallbacks triggered, synthesizer model). Load-bearing because:

- the UI shows it ("Stave decided to use ...")
- telemetry reads it
- debugging production incidents depends on it

Replacing it: same shape or a successor with a migration. Do not silently
drop fields consumers are reading.

## Change Protocol

When you know what you want to change, follow this order.

### Step 1 — State the intent

Write one sentence at the top of the PR / plan that names what you're
changing and why. Example:

> Replace role-sequential orchestration with a DAG supervisor so analyze and
> implement can run in parallel when the plan allows it.

This becomes the anchor for reviewers and for future editors.

### Step 2 — Mark which map item(s) you're changing

From M1–M6, list which ones you're replacing, extending, or removing. If
you're removing one, explicitly name what absorbs each of its
responsibilities (see each item above).

### Step 3 — Schema and events first

Routing state crosses IPC to the renderer. Before touching logic:

- update Zod schemas / type unions for events and routing decisions
- bump the routing-log schema version if the shape changes
- update any renderer selector that reads routing state

Invoke `the-ipc-schema-sync` if events cross IPC boundaries.

### Step 4 — Add alongside, then cut over

For non-trivial changes, add the new path next to the old, gate by a flag
(env var, setting, or workspace flag). Run both in shadow if the cost
allows, compare routing decisions, then cut over. Remove the old path in a
follow-up.

### Step 5 — Preserve the audit trail

Every turn must still produce a routing decision record someone can read
later. Redesigns often break this by accident — verify a representative
turn end-to-end before and after.

### Step 6 — Document the new rules

If your redesign retires an invariant from the old system (e.g. "we no
longer classify intent up front"), add a short note to the router's inline
doc block explaining what replaced it. The next editor will read that block.

## Decisions Worth Recording

When redesigning, keep a short decision log — in the PR, in an ADR, or in
the router's doc block. Minimum:

- what changed
- what load-bearing item(s) from M1–M6 it replaces
- what it explicitly stops guaranteeing (if anything)
- one example turn before/after

This is what keeps the layer coherent across redesigns instead of slowly
turning into a pile of special cases.

## Integration with Other Skills

- `the-ipc-schema-sync`: when routing events cross IPC boundaries.
- `the-zustand-guardrail`: when renderer selectors read routing state.
- `the-build-fixer`: typecheck across electron/, host-service, renderer.
- `the-refactoring-planner`: for multi-phase redesigns that span sprints.

## Done Definition

- The change's intent is written down in one sentence.
- The affected map items (M1–M6) are listed with what absorbs their
  responsibilities.
- Schemas/events updated before logic; IPC consumers still parse clean.
- A representative turn produces a routing decision record before and
  after; renderer shows it correctly.
- Decision log (PR body or ADR or doc block) captures what the router now
  does and does not guarantee.
