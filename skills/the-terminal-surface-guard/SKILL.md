---
name: the-terminal-surface-guard
description: Prevent terminal and PTY surface regressions in Electron desktop apps by enforcing shell/runtime separation, attach-detach lifecycle discipline, session restore safety, viewport recovery, and bounded async runtime behavior. Use when changing terminal UI, dock or panel shells, PTY session lifecycle, terminal focus, resize, transcript replay, session resume across workspace or app restarts, slot or attachment identity, native session IDs, or host-service terminal runtime code.
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
- changing reattach, restore, backlog hydration, or viewport recovery
- changing `slotKey`, `attachmentId`, or `nativeSessionId` flow
- editing host-service terminal runtime code

Do not use this skill for generic text editors or non-PTY output panes.

## Three-Layer Model

Treat terminal work as three layers with explicit ownership:

- PTY session lifecycle: host-service or backend runtime
- I/O transport and restore gating: renderer hooks plus IPC contract
- viewport rendering: Ghostty or xterm instance lifecycle in the renderer

Do not collapse these into one hook or component just because the UI looks simple.

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

## Restore Contract

The restore path should stay explicit:

1. create or locate the session identity
2. attach to the active session
3. hydrate canonical state (`screenState`, backlog, transcript, or equivalent)
4. resume live stream delivery

Guardrails:

- renderer unmount should usually detach, not kill
- explicit tab close or workspace teardown is what kills PTY state
- restore should use a host snapshot or bounded backlog as the source of truth, not stale DOM state
- hidden CLI surfaces should rebuild their renderer and reattach later; hidden dock surfaces may keep the renderer alive only when the surface model explicitly allows it
- workspace switch and app restart should not create duplicate sessions for the same slot

If a change blurs attach, restore, and resume into one opaque effect, assume regressions are likely.

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

## Identity Rules

- `slotKey` is a shared helper contract, not an ad hoc string
- `attachmentId` exists to prevent stale detach or stale resume from tearing down the active viewer
- `nativeSessionId` is part of restart and provider-resume behavior; if it changes shape or persistence, follow the IPC chain all the way through

When adding session metadata, verify that dock and CLI flows agree on identity semantics.

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
- bounded transcript persistence and deferred flush work only
- explicit abort or cancellation path for long-lived async work
- no fire-and-forget async on mutable session state
- no unhandled rejection in host-service or main
- no heavy PTY or stream work in Electron main when a worker or host-service can own it
- no broad broadcast when workspace- or session-targeted delivery is enough
- no resume path that can unlock stream delivery before restore state is applied

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
- restore or hydration hook
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
6. Reattach or reopen a session and verify scrollback plus visible viewport restore correctly.
7. If the change touches persistence, restart the app and verify the session resumes with the expected identity and backlog.

## Reference Stance

Patterns worth borrowing from stronger terminal implementations:

- explicit lifecycle boundaries and restore phases
- clear identity separation for UI slot vs runtime session vs attachment
- restore-specific verification instead of only happy-path typing checks

For Stave-like architectures, prefer server-side snapshot or backlog restore with source-side gating over ad hoc client-only event ordering hacks unless the transport boundary proves otherwise.

## Output

Return:

- shell/runtime ownership status
- restore and identity risks
- keep-alive risks
- focus or resize risks
- runtime hardening gaps
- verification completed vs still required
