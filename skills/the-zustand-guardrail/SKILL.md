---
name: the-zustand-guardrail
description: Prevent Zustand selector and subscription anti-patterns that cause React runtime loops, hot-surface rerender storms, and stale UI. Use when editing useAppStore, useStore, useShallow, selector logic, list rendering, row subscriptions, task/workspace switching surfaces, or debugging Maximum update depth exceeded.
compatible-tools: [claude, codex]
category: safety
test-prompts:
  - "fix this Zustand selector"
  - "useAppStore selector 정리"
  - "workspace list rerender 줄여줘"
---

# The Zustand Guardrail

Treat selector shape as a runtime correctness issue.

## Use This Skill When

- adding or changing `useAppStore(...)`, `useStore(...)`, or `useShallow(...)`
- deriving list data from store state
- wiring row, tab, tree, sidebar, or chat subscriptions
- debugging `Maximum update depth exceeded`
- changing task switching, workspace switching, or streaming UI

Do not use this skill for state machines or reducers that do not involve Zustand subscriptions.

## Core Rule

Selectors read store state. They should not manufacture new containers on every render.

Safe by default:

- primitives
- existing object references from store state
- existing array references from store state
- tuple selectors wrapped with `useShallow` when each item is stable

Suspicious by default:

- `{ ... }`
- `[ ... ]` without `useShallow`
- `.map(...)`, `.filter(...)`, `.slice(...)` inside selectors
- `new Map(...)`, `new Set(...)`
- inline callbacks
- `?? []`, `?? {}`

## Five Killer Patterns

### 1. Fresh array in selector

Bad:

```tsx
const visibleMessages = useAppStore((state) =>
  (state.messagesByTask[state.activeTaskId] ?? []).filter((m) => !m.hidden),
);
```

Good:

```tsx
const EMPTY_MESSAGES: ChatMessage[] = [];

const messages = useAppStore((state) => state.messagesByTask[state.activeTaskId] ?? EMPTY_MESSAGES);
const visibleMessages = useMemo(() => messages.filter((m) => !m.hidden), [messages]);
```

### 2. Fresh object in selector

Bad:

```tsx
const runtimeState = useAppStore((state) => ({
  activeTaskId: state.activeTaskId,
  hasDraft: Boolean(state.draftsByTask[state.activeTaskId]),
}));
```

Good:

```tsx
const [activeTaskId, hasDraft] = useAppStore(useShallow((state) => [
  state.activeTaskId,
  Boolean(state.draftsByTask[state.activeTaskId]),
] as const));
```

### 3. Inline fallback allocation

Bad:

```tsx
const messages = useAppStore((state) => state.messagesByTask[taskId] ?? []);
```

Good:

```tsx
const EMPTY_MESSAGES: ChatMessage[] = [];
const messages = useAppStore((state) => state.messagesByTask[taskId] ?? EMPTY_MESSAGES);
```

### 4. Mapping inside selector

Bad:

```tsx
const tabIds = useAppStore((state) => state.tabs.map((tab) => tab.id));
```

Good:

```tsx
const tabs = useAppStore((state) => state.tabs);
const tabIds = useMemo(() => tabs.map((tab) => tab.id), [tabs]);
```

### 5. Broad map subscription in parent list

Bad:

```tsx
const runtimeByWorkspaceId = useAppStore((state) => state.workspaceRuntimeCacheById);
return workspaces.map((workspace) => (
  <WorkspaceRow key={workspace.id} runtime={runtimeByWorkspaceId[workspace.id] ?? null} />
));
```

Good:

```tsx
function WorkspaceRow({ workspaceId }: { workspaceId: string }) {
  const runtime = useAppStore((state) => state.workspaceRuntimeCacheById[workspaceId] ?? null);
  return <WorkspaceRowView runtime={runtime} />;
}
```

## Hot Surfaces

Be extra strict on:

- `ChatInput`
- `PlanViewer`
- `ChatPanel`
- `ProjectWorkspaceSidebar`
- `WorkspaceTaskTabs`
- task switching
- workspace switching
- streaming UI
- replay drawers

## Shipping Checklist

1. Does any selector return a fresh object, array, function, `Map`, or `Set`?
2. Does any selector use `?? []` or `?? {}`?
3. Is any `.map()`, `.filter()`, or `.slice()` happening inside a selector?
4. If multiple values are returned, is `useShallow` used?
5. Can derived data move to `useMemo` after subscription?
6. Is a parent list subscribed to a large mutable registry?
7. Can row-local keyed subscriptions reduce rerender fan-out?
8. After the change, did you check the real hot flow, not just typecheck?

## Output

Return:

- suspicious selectors found
- hot surfaces affected
- exact bad → good rewrite plan
- verification still required

