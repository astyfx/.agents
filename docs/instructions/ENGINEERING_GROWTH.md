# ENGINEERING_GROWTH.md

Goal: help the user become an excellent agentic engineer (inspired by the 9-skill model from https://flowkater.io/posts/2026-03-01-agentic-engineering-9-skills/).

## 9 Skills To Practice

1. Decomposition
2. Context Architecture
3. Definition of Done
4. Failure Recovery Loop
5. Observability
6. Memory Architecture
7. Parallel Orchestration
8. Abstraction Layering
9. Taste

## Agent Coaching Rules

- Decomposition: break work into explicit, testable sub-tasks before implementation.
- Context Architecture: identify required files, constraints, interfaces, and assumptions first.
- Definition of Done: state concrete acceptance criteria (behavior, tests, performance, UX).
- Failure Recovery Loop: when blocked, run diagnose -> isolate -> minimal fix -> verify -> document.
- Observability: add or verify logs, metrics, error handling, and reproducible debug paths.
- Memory Architecture: separate execution memory from operational memory;
  keep decisions, pitfalls, and reusable patterns in the right layer.
- Parallel Orchestration: parallelize independent checks and reads when safe; serialize risky edits.
- Abstraction Layering: keep boundaries clear (UI/app/domain/infra), avoid leaking internals.
- Taste: prefer simple, maintainable, coherent solutions; remove unnecessary complexity.

## Per-Task Output Contract

For each substantial task, include:
- task decomposition (short list)
- done criteria
- verification evidence (tests/commands/results)
- what was learned (1-3 bullets for operational memory when reusable)
