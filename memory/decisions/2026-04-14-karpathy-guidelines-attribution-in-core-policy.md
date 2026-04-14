# ADR — 2026-04-14 — Karpathy-Guidelines Attribution In Core Policy

status: accepted

## Context

The harness already had pieces of the desired behavior spread across
`AGENTS.md`, conventions, and skills:

- make assumptions explicit instead of hiding them
- avoid overbuilt solutions
- keep changes localized
- verify behavior with concrete checks

What it lacked was a short, always-on behavioral layer that expressed those
habits in one place.

The user also explicitly wanted future sessions to be able to tell that this
behavioral layer came from an external source so the adoption could be reviewed
later without archaeology.

## Source Material

- Repository: https://github.com/forrestchang/andrej-karpathy-skills
- Core document:
  https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/CLAUDE.md

The source packages four concise behavioral principles:

- Think Before Coding
- Simplicity First
- Surgical Changes
- Goal-Driven Execution

## Decision

- Add a short `Behavioral Principles` section to `AGENTS.md`.
- Keep explicit attribution to the source repository in that always-on section.
- Adapt the four principles to this harness instead of importing the external
  `CLAUDE.md` verbatim.
- Keep user instructions and hard safety invariants above these principles in
  precedence.
- Use this ADR as the durable review record for why the principles were adopted
  and where they came from.

## Consequences

- Future sessions can identify the source quickly by reading either the policy
  or this ADR.
- The harness gains a compact behavioral layer without replacing its thin-core
  structure.
- The adopted guidance remains reviewable as an adaptation, not an opaque local
  rewrite.

## Review Triggers

Revisit this decision if any of the following show up repeatedly:

- the agent asks too many blocking clarifications on trivial work
- the policy starts duplicating more detailed skill or convention guidance
- verification language becomes rigid enough to slow obviously low-risk edits
- a better compact behavioral source replaces this one

## Follow-Up Work

- Prefer adapting future external prompt ideas with explicit provenance instead
  of copying them anonymously.
- If this behavioral section grows beyond a compact summary, move detail back
  out of `AGENTS.md` and keep only the pointer plus attribution.
