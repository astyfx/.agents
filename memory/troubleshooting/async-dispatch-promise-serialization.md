# Async Dispatch Promise Serialization

## Symptom

- An IPC or host-service response silently arrives as `{}` or with missing fields.
- Renderer guards fail because expected fields such as `ok`, `data`, or IDs are `undefined`.
- No obvious runtime exception is thrown.

## Affected Surfaces

- dispatch or switch layers that pass runtime function results into `respond()`
- IPC writers or any helper that serializes its payload directly
- host-service or preload bridges where a sync-looking call site wraps an async runtime function

## Root Cause

An async function result was passed to a serializer without `await`.
The serializer received a `Promise` object instead of the resolved payload.

## Workaround

- `await` the async call before passing the value to `respond()`, `writeMessage()`, or `JSON.stringify`
- when a runtime function changes from sync to async, grep all call sites immediately

## Durable Fix

- `skills/the-ipc-schema-sync/SKILL.md` now includes this as a common failure mode and guardrail
- IPC dispatch changes should be reviewed as contract-boundary work, not as local implementation details

## Prevention Notes

- do not trust TypeScript alone on serializer boundaries
- when adding a dispatch case, explicitly check whether the runtime target is async
- smoke-test the real request path after changing runtime sync/async behavior
