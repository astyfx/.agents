# End-to-End Path Verification and Reversible State

Stable guidance for changes that touch async state, cleanup, lifecycle
transitions, or any flow the user can enter, undo, and quickly re-enter.

## Use This Pattern When

- a fix changes state transitions, refs, caches, guards, or cleanup logic
- a feature can be entered and then reversed by the user
- async work can still be in flight while the user changes direction
- a "simple optimization" tries to skip cleanup, re-attach, or re-sync work

## Core Rule

Do not verify only the reported path. Verify every user-reachable path that
touches the changed code and trace the real producer-consumer state through each
one.

## Minimum Path Set

For affected flows, enumerate at least:

1. forward path
2. reverse path
3. rapid reversal before async work settles
4. concurrent or overlapping operations when applicable

If one of these paths does not apply, say why.

## Path-Tracing Standard

For each path, write the concrete sequence:

1. which state, ref, cache, or promise is written
2. which later code reads it
3. what guard conditions run
4. what clears or replaces the state
5. what the next user action sees

"This should work" is not enough. The trace should show the actual sequence in
code.

## Reversible-State Checks

Use this checklist when the change includes cleanup, detach, unsubscribe,
backgrounding, teardown, or any ref-tracked routing state:

1. Paired operations stay symmetric in side effects and error handling.
2. Cleanup clears the full local state associated with the key or instance.
3. Async cleanup does not clear local routing state before the remote change settles unless the code intentionally preserves delivery across that gap.
4. Follow-up operations after cleanup still pass their guards with the cleaned state.
5. Optimizations that skip a round-trip do not create producer-consumer disagreement across paths.

## Pre-Commit Quality Pass

Before commit, quickly check:

1. repeated new logic should already be a helper if reuse is real
2. internal formats, prefixes, and state shapes are not leaking across module boundaries
3. temporary names and dead code from the iteration are removed
4. verification notes cover the real path set, not only the originally reported failure

## Preferred Outcome

Prefer the smallest correct behavior model, not the smallest local diff.
A larger but coherent round-trip is better than a shortcut that only works in
one path.
