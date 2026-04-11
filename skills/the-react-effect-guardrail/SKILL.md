---
name: the-react-effect-guardrail
description: Prevent React effect, ref, and dependency anti-patterns that cause stale closures, identity loops, duplicate listeners, and keep-alive regressions. Use when editing useEffect, useMemo, useCallback, useRef, observers, timers, IPC listeners, or long-lived callbacks in React and Electron renderer code.
compatible-tools: [claude, codex]
category: safety
test-prompts:
  - "useEffect 정리"
  - "ResizeObserver stale closure 고쳐줘"
  - "listener cleanup 확인"
---

# The React Effect Guardrail

Effects are for synchronization, not general control flow.

## Use This Skill When

- editing `useEffect`, `useMemo`, `useCallback`, or `useRef`
- wiring `ResizeObserver`, `MutationObserver`, `IntersectionObserver`, timers, or IPC listeners
- debugging stale closures or repeated subscriptions
- changing keep-alive or bootstrap behavior
- fixing focus, resize, or streaming UI behavior

Do not use this skill for pure render-only components with no long-lived callbacks or subscriptions.

## High-Risk Patterns

### 1. Stale closure in long-lived observer

Bad:

```tsx
useEffect(() => {
  const observer = new ResizeObserver(() => {
    resizeSession(sessionId, cols, rows);
  });
  observer.observe(container);
  return () => observer.disconnect();
}, []);
```

Good:

```tsx
const latestSizeRef = useRef({ cols, rows });
latestSizeRef.current = { cols, rows };

useEffect(() => {
  const observer = new ResizeObserver(() => {
    const { cols, rows } = latestSizeRef.current;
    resizeSession(sessionId, cols, rows);
  });
  observer.observe(container);
  return () => observer.disconnect();
}, [sessionId]);
```

### 2. Object identity in dependency arrays

Bad:

```tsx
useEffect(() => {
  tabManager.register(id);
  return () => tabManager.unregister(id);
}, [tabManager, id]);
```

If `tabManager` is recreated, this effect churns even when the underlying methods did not change.

Good:

```tsx
const { register, unregister } = tabManager;

useEffect(() => {
  register(id);
  return () => unregister(id);
}, [register, unregister, id]);
```

### 3. keep-alive invalidation through bootstrap deps

Bad:

```tsx
useEffect(() => {
  bootstrapSession();
}, [workspaceId, visible]);
```

If `visible` toggles often, this can recreate or disturb keep-alive state.

Good:

```tsx
useEffect(() => {
  bootstrapSession();
}, [workspaceId]);
```

Gate visibility in the runtime logic, not in the bootstrap identity.

## Cleanup Rules

Every effect that installs one of these must return cleanup:

- IPC listener
- DOM event listener
- observer
- interval
- timeout
- async polling loop with abort support

If there is no cleanup, assume the effect is wrong until proven otherwise.

## Ref Rules

Use refs for:

- latest props or callbacks read by long-lived observers
- transient values that change often but should not retrigger effects
- in-flight guards and latest-request coalescing

Do not use refs to hide missing state transitions or to bypass real dependencies.

## React 19 + StrictMode Gotcha

In development, React may double-invoke effects. That exposes:

- missing cleanup
- non-idempotent bootstrap logic
- duplicate listener registration
- duplicate timers

If the code only works outside StrictMode, it is probably wrong.

## Composition Guard

Before adding more booleans or effect branches, ask:

- is the component mixing shell chrome and runtime behavior?
- should variant state be explicit instead of inferred from many booleans?
- can the runtime logic move into a hook and the component stay declarative?

This prevents effect complexity from becoming structural debt.

## Verification

1. Check dependency arrays for object identity and accidental broad deps.
2. Check all installed listeners and observers for cleanup.
3. Check long-lived callbacks for stale props or state.
4. Smoke-test the real interaction flow, not just the initial mount.

## Output

Return:

- stale closure risks
- identity loop risks
- missing cleanup points
- shell/runtime split concerns
- verification completed vs still required

