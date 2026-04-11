---
name: the-terminal-surface-guard
description: Prevent terminal and PTY surface regressions in Electron desktop apps by enforcing shell/runtime separation, keep-alive safety, focus recovery, resize discipline, and bounded async runtime behavior. Use when changing terminal UI, dock or panel shells, PTY session lifecycle, terminal focus, resize, transcript replay, or host-service terminal runtime code.
compatible-tools: [claude, codex]
category: safety
test-prompts:
  - "terminal resize 버그 고쳐줘"
  - "CLI session focus 회복"
  - "PTY lifecycle 점검"
---

# The Terminal Surface Guard

Treat the integrated terminal as a platform boundary, not a normal panel.

## Use This Skill When

- editing terminal dock or CLI session shells
- changing PTY lifecycle, slot reuse, or delivery mode
- touching terminal focus or keyboard behavior
- changing resize handling or transcript replay
- editing host-service terminal runtime code

Do not use this skill for generic text editors or non-PTY output panes.

## Shell / Runtime Split

Keep shell components responsible for:

- headers
- buttons
- labels
- badges
- layout chrome

Keep runtime hooks or services responsible for:

- session creation
- restore and keep-alive
- resize and output delivery
- focus recovery
- transcript replay
- push/poll buffering

Do not let shell components own PTY lifecycle.

## Keep-Alive Contract

- bootstrap identity must stay stable
- visibility changes must not recreate the session identity
- hidden surfaces must not spawn or reconnect sessions eagerly

Bad:

```tsx
useEffect(() => {
  bootstrapSession();
}, [workspaceId, visible]);
```

Good:

```tsx
useEffect(() => {
  bootstrapSession();
}, [workspaceId]);
```

Visibility belongs in session gating, not bootstrap identity.

## Focus Cascade

Preferred focus recovery order:

1. terminal runtime surface
2. hidden textarea or input target
3. container fallback

If focus is timing-sensitive, use a small RAF retry path. Do not scatter ad hoc `querySelector("textarea")` calls across shell components.

## Resize Discipline

- PTY or backend resize is the source of truth
- coalesce repeated resize events
- keep at most one in-flight resize and one latest pending resize
- only mark local resize state as settled after backend success
- failed resize must not permanently suppress later retries

## Runtime Hardening Rules

- bounded output buffers only
- explicit abort or cancellation path for long-lived async work
- no fire-and-forget async on mutable session state
- no unhandled rejection in host-service or main
- no heavy PTY or stream work in Electron main when a worker or host-service can own it
- no broad broadcast when workspace- or session-targeted delivery is enough

## Session Gating

Hidden or inactive surfaces should not create real sessions unless there is an explicit restore contract.

Check:

- dock hidden
- task switched away
- workspace changed
- CLI tab inactive

## Required Files and Tests

Review the nearest equivalents of:

- runtime hook or adapter
- shell chrome component
- terminal styling helper
- store restore semantics
- renderer-to-main terminal contract
- host-service or worker runtime
- terminal-focused tests

## Verification

1. Open the terminal and type.
2. Switch task or workspace and return.
3. Verify focus still works.
4. Resize aggressively and verify no freeze or stale PTY geometry.
5. Confirm hidden surfaces did not create duplicate sessions.

## Output

Return:

- shell/runtime ownership status
- keep-alive risks
- focus or resize risks
- runtime hardening gaps
- verification completed vs still required

