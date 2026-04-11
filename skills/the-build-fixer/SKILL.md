---
name: the-build-fixer
description: >-
  Diagnose and fix build failures, TypeScript errors, CI failures, and
  dependency issues. Use when the user pastes error output from tsc, bun build,
  npm run build, vitest, eslint, or CI logs, or says "빌드 실패", "CI failed",
  "tsc error", "build is broken", "fix this error". Applies the failure
  recovery loop: classify → isolate → minimal fix → verify.
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "빌드 실패했어"
  - "fix this TypeScript error"
  - "CI failed"
  - "tsc error 고쳐줘"
  - "build is broken"
---

# The Build Fixer

Diagnose build failures with root-cause analysis, not guess-and-check.

## Use This Skill When

- The user pastes compiler/bundler/linter error output.
- The user says "빌드 실패", "CI failed", "tsc error", "build is broken".
- A previous fix attempt failed and the error changed.

## The Recovery Loop

Follow this sequence. Do not skip directly to applying a fix.

### Step 1 — Classify the Error

Read the full error output and classify it:

| Class | Signals |
|---|---|
| TypeScript type error | `TS2xxx` error codes, "is not assignable to", "does not exist on type" |
| Missing dependency | "Cannot find module", "Module not found", "package not found" |
| Environment mismatch | "command not found", wrong Node/Bun/Python version, missing env var |
| Test failure | "AssertionError", "Expected ... to be ...", test runner output |
| Lint error | ESLint/Biome rule names, "no-unused-vars", "no-explicit-any" |
| Runtime crash | Uncaught error, stack trace from running process |
| Build config | Vite/webpack config errors, tsconfig issues |

State the classification explicitly before proceeding.

### Step 2 — Isolate the Root Cause

Do not fix the symptom. Find why the error exists:
- For type errors: what type is actually present vs what is expected? Trace where the value comes from.
- For missing dependencies: is it uninstalled, wrong import path, or a circular dependency?
- For env issues: what does the environment actually have vs what is expected?
- For test failures: does the implementation have a logic error, or is the test expectation wrong?

State the root cause in one sentence before writing any fix.

### Step 3 — Apply the Minimal Fix

Write the smallest change that resolves the root cause.
- Do not refactor unrelated code.
- Do not change behavior beyond what is needed to fix the error.
- Prefer explicit fixes over type assertions (`as Type` or `!`) unless the assertion is genuinely correct.
- For `any` type escapes: use them only as last resort and add a `// TODO: type this properly` comment.

### Step 4 — Verify

After applying the fix:
- Run the failing command again (or ask the user to run it).
- Confirm the specific error is gone.
- Check for new errors introduced by the fix.

### Step 5 — Document

If the project has an active tracking task, document the fix in the task
record. By default, add it to `handoff.md` under `Progress`, `Verification`, or
`Notes`. If the task already uses expanded tracking and has `execution-log.md`,
append there instead:
```
[fix] <error class>: <root cause in one line> — resolved by <fix summary>
```

## TypeScript-Specific Guidance

Common patterns and correct fixes:

| Error | Common Root Cause | Fix |
|---|---|---|
| `Type 'X \| undefined' is not assignable to 'X'` | Optional chaining produces undefined | Add `?? defaultValue` or guard with `if (x === undefined)` |
| `Property does not exist on type` | Missing type definition | Add property to interface/type |
| `Object is possibly undefined` | No null check | Add optional chaining or explicit guard |
| `Argument of type 'string' is not assignable to parameter of type 'number'` | Wrong type passed | Check the data source, not just the call site |

## Done Definition

Fix is complete when:
- Error is classified and root cause is stated.
- Minimal fix is applied.
- Verification confirms the error is resolved.
- No new errors were introduced.
