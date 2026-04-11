# Execution Memory Default Path

## Status

Accepted

## Context

The harness had already narrowed `tracking/` to execution-memory semantics, but
the path name still implied a broader tracking or audit function. The user
explicitly said the long-term `tracking` name was unnecessary and later also
said the compatibility layer itself was unnecessary.

## Decision

- Use `execution/` as the durable root for task state.
- Move existing durable task artifacts from `tracking/` into `execution/`.
- Use `scripts/new-task.sh` as the canonical scaffolder.
- Remove `--with-tracking`, `HARNESS_TASK_ROOT`, and `claude-progress.txt`.
- Keep `work-handoff.md` and stop-time automation keyed only on
  `Active Task Path`.

## Consequences

- The harness uses one execution-memory path instead of a transitional pair.
- Docs, skills, hooks, and scaffolding are easier to explain and verify.
- Historical notes may still mention the old name, but the live harness no
  longer depends on it.
