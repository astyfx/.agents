---
name: the-ipc-schema-sync
description: Prevent IPC schema drift and provider or host-service contract mismatches that cause Zod rejections, dropped events, silent runtime failures, or broken terminal/session restore flows. Use when changing runtimeOptions, IPC payloads, MessagePart shapes, provider events, NormalizedProviderEvent, preload contracts, host-service request or response fields, renderer-to-main terminal/session APIs, or window-api request fields.
compatible-tools: [claude, codex]
category: safety
test-prompts:
  - "runtimeOptions 필드 추가"
  - "window.api payload 변경"
  - "provider event rename"
---

# The IPC Schema Sync

Treat IPC and provider payload changes as end-to-end contract changes.

## Use This Skill When

- adding or renaming provider runtime options
- changing request or response payloads across preload and main
- touching `MessagePart`, canonical conversation parts, or replay payloads
- adding, renaming, or deleting normalized provider events
- changing approval, MCP, or tool-execution payload shapes
- changing host-service terminal/session request or response fields such as `slotKey`, `attachmentId`, `screenState`, `backlog`, or `nativeSessionId`

Do not use this skill for renderer-only refactors that do not cross a contract boundary.

## Contract Chains

### Provider / assistant chain

For provider and general IPC work, check the whole chain:

1. `electron/providers/types.ts`
2. `src/lib/providers/provider.types.ts`
3. `src/types/window-api.d.ts`
4. `electron/preload.ts`
5. `electron/main/ipc/schemas.ts`
6. producer and consumer call sites

If one file changes and the others do not, assume the change is incomplete.

### Terminal / host-service chain

For terminal/session IPC work, check the whole chain:

1. `electron/host-service/protocol.ts`
2. host-service dispatch or runtime entry points such as `electron/host-service.ts`
3. `electron/main/ipc/schemas.ts`
4. `electron/main/ipc/terminal.ts`
5. `electron/preload.ts`
6. `src/types/window-api.d.ts`
7. renderer hooks, store, and terminal shell call sites
8. focused tests such as schema, runtime, and restore regressions

If a terminal/session field changes in only one layer, assume resume or restore is broken until proven otherwise.

## Normalized Event Rule

`NormalizedProviderEvent` and the matching Zod schema must move together.

Whenever you:

- add a new event
- rename an event type string
- change an event payload field

you must update:

- the TypeScript union
- the Zod schema
- provider emitters
- replay consumers
- diagnostics if user-visible

## Common Failure Modes

### 1. New field added in TypeScript only

```typescript
// BAD — added to TS type but not Zod
// types.ts
interface RuntimeOptions { reasoningBudget?: number; }
// schemas.ts — unchanged, field missing
const RuntimeOptionsSchema = z.object({ maxTokens: z.number().optional() });
// → Zod silently strips reasoningBudget at the IPC boundary

// GOOD — both updated together
// types.ts
interface RuntimeOptions { reasoningBudget?: number; }
// schemas.ts
const RuntimeOptionsSchema = z.object({
  maxTokens: z.number().optional(),
  reasoningBudget: z.number().optional(),
});
```

### 2. New event added without Zod entry

```typescript
// BAD — TS union has it, Zod schema doesn't
// provider.types.ts
type NormalizedProviderEvent =
  | { type: 'message'; content: string }
  | { type: 'execution_plan'; plan: Plan }; // NEW

// schemas.ts — no matching z.object({ type: z.literal('execution_plan'), ... })
// → parseNormalizedEvent() drops the event, renderer never sees it

// GOOD — add Zod entry in the same change
const ExecutionPlanEventSchema = z.object({
  type: z.literal('execution_plan'),
  plan: PlanSchema,
});
```

### 3. Event renamed on one side only

```typescript
// BAD — renamed in TS but not in Zod literal
// provider.types.ts
| { type: 'execution_processing'; ... } // was 'execution_plan'
// schemas.ts
z.literal('execution_plan') // ← still old string
// → no type error in some files, but events silently vanish

// GOOD — rename literal in both TS union and Zod schema simultaneously
```

### 4. Host-service response field added in protocol only

```typescript
// BAD — protocol knows about nativeSessionId, but schema and preload do not
// protocol.ts
type HostTerminalCreateSessionResult = {
  ok: boolean;
  sessionId?: string;
  nativeSessionId?: string;
};

// schemas.ts or preload.ts — unchanged
// → renderer never sees nativeSessionId even though runtime returns it

// GOOD — thread the field through protocol, Zod schema, preload, d.ts, and consumer state
```

## Provider Symmetry Rule

If the change is meant to be provider-agnostic, inspect both adapters.

Check:

- Claude runtime path
- Codex runtime or App Server path
- shared producer and replay paths

Do not ship a general feature wired only on one adapter unless the change is explicitly provider-specific.

### 5. Async function result passed without await to serializer

```typescript
// BAD — attachSession is async, Promise serializes as {}
case "terminal.attach-session":
  await respond(request.id, terminalRuntime.attachSession(request.params));
  // respond() calls JSON.stringify(Promise) → {} → renderer gets { ok: undefined }

// GOOD — await the async call before passing to respond
case "terminal.attach-session":
  await respond(request.id, await terminalRuntime.attachSession(request.params));
```

TypeScript may not catch this at generic serializer boundaries. Do not rely on the compiler to reject a bare `Promise` being handed to `respond()`, IPC writers, or JSON serialization.
When adding a dispatch case or changing a function from sync to async, grep for `async function` in the runtime and ensure every async call is `await`ed at the dispatch site.

### 6. Terminal request added without renderer boundary updates

```typescript
// BAD — new terminal request exists in host-service protocol only
"terminal.get-session-resume-info": { sessionId: string }

// preload.ts / window-api.d.ts / renderer hooks — unchanged
// → main path compiles, renderer path cannot call it or silently drops fields
```

Treat new terminal/session calls as end-to-end boundary changes, not local runtime helpers.

## Guardrails

- never trust TypeScript alone on IPC work
- never rename a discriminant in only one file
- never add a field to a renderer request without touching Zod
- never stop at `window.api` when the main schema is stricter
- never add a host-service terminal field in `protocol.ts` without checking schemas, preload, `window-api.d.ts`, renderer hooks, and tests
- never pass an async function result to a serializer without `await` — `JSON.stringify(Promise)` is `{}`

## Verification

1. Run `bun run typecheck`.
2. If runtime code changed, smoke-check both Claude and Codex entry paths when applicable.
3. If event payloads changed, verify replay and user-visible consumers.
4. If terminal/session IPC changed, run the narrowest relevant schema/runtime/restore tests before stopping.

## Output

Return:

- contract chain checked
- changed fields or events
- missing sync points
- provider symmetry status
- verification completed vs still required
