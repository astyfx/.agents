---
name: the-ipc-schema-sync
description: Prevent IPC schema drift and provider contract mismatches that cause Zod rejections, dropped events, and silent runtime failures. Use when changing runtimeOptions, IPC payloads, MessagePart shapes, provider events, NormalizedProviderEvent, preload contracts, or renderer-to-main request fields.
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

Do not use this skill for renderer-only refactors that do not cross a contract boundary.

## Six-File Contract Chain

For provider and IPC work, check the whole chain:

1. `electron/providers/types.ts`
2. `src/lib/providers/provider.types.ts`
3. `src/types/window-api.d.ts`
4. `electron/preload.ts`
5. `electron/main/ipc/schemas.ts`
6. producer and consumer call sites

If one file changes and the others do not, assume the change is incomplete.

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

## Provider Symmetry Rule

If the change is meant to be provider-agnostic, inspect both adapters.

Check:

- Claude runtime path
- Codex runtime or App Server path
- shared producer and replay paths

Do not ship a general feature wired only on one adapter unless the change is explicitly provider-specific.

### 4. Async function result passed without await to serializer

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

## Guardrails

- never trust TypeScript alone on IPC work
- never rename a discriminant in only one file
- never add a field to a renderer request without touching Zod
- never stop at `window.api` when the main schema is stricter
- never pass an async function result to a serializer without `await` — `JSON.stringify(Promise)` is `{}`

## Verification

1. Run `bun run typecheck`.
2. If runtime code changed, smoke-check both Claude and Codex entry paths when applicable.
3. If event payloads changed, verify replay and user-visible consumers.

## Output

Return:

- contract chain checked
- changed fields or events
- missing sync points
- provider symmetry status
- verification completed vs still required
