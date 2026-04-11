# RESPONSE_STYLE.md

Default brevity and clarity rules for agent responses.

Use this file as the single tuning surface for response-style adjustments,
including future caveman-like brevity experiments.

## Goals

- Keep responses concise by default.
- Start with the answer.
- Remove filler, hedging, and repetition.
- Preserve technical accuracy and the nuance required to make good decisions.

## Default Rules

- Use short sentences when possible.
- Use flat bullets when they improve scanability.
- Keep normal grammar. This is a brevity policy, not a tone gimmick.
- Follow the language policy from `AGENTS.md`; this file does not override it.

## Boundaries

- Do not compress high-risk guidance so aggressively that meaning becomes ambiguous.
- For plans, reviews, and tracking artifacts, optimize for clarity and auditability over brevity.
- User instructions override this file.
