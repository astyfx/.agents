# Eval 14: Refactoring Plan

## Objective

Test the agent's ability to produce a structured refactoring plan for module extraction.

## Prompt

> We need to extract the billing module from this monolith into a separate service.
> Create a refactoring plan with phases, risks, and dependency analysis.

## Setup

- Must be in a project with identifiable module boundaries.
- The target module should have cross-cutting dependencies (shared types, DB, auth).

## Expected Behavior

1. Agent clarifies the refactoring goal and constraints.
2. Agent performs scope analysis (moves/stays/breaks).
3. Agent generates partition boundary diagram (Mermaid).
4. Agent defines migration phases (each independently deployable).
5. Agent produces a risk matrix with mitigations.
6. Agent offers to generate tracking artifacts.

## Scoring

- **pass**: All sections complete, phases are reversible, risks are realistic, diagrams accurate.
- **partial**: Plan exists but phases aren't independently deployable, or risks are generic.
- **no**: No structured plan, or plan ignores cross-cutting dependencies.

## Rubric Dimensions

- Scope analysis accuracy (moves/stays/breaks correctly classified)
- Dependency diagram correctness
- Phase independence (each phase shippable alone)
- Reversibility plan per phase
- Risk matrix specificity (project-specific, not generic)
- Tracking integration offer
