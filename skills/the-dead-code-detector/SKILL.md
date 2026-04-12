---
name: the-dead-code-detector
description: Detect unused, unreachable, or stale code before cleanup or refactoring. Use when the user asks to find dead code, unused files, unused exports, stale components, old feature flags, or says "dead code", "unused code", "안쓰는 코드", "안쓰는 파일", "unused export", "remove stale code", or "cleanup legacy paths". Produces evidence-ranked candidates, separates safe-delete items from review-needed items, and uses repo-native tooling such as knip, ts-prune, depcheck, or lint rules when available.
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "dead code 찾아줘"
  - "unused files 있는지 봐줘"
  - "안쓰는 컴포넌트 정리해줘"
  - "find stale code paths before this refactor"
  - "unused exports cleanup"
---

# The Dead Code Detector

Find dead code with evidence, not vibes.

## Use This Skill When

- The user asks to find or remove dead code, unused files, unused exports, stale components, abandoned routes, or old feature flags.
- A refactor or migration likely left legacy paths behind.
- Bundle size, maintenance cost, or repo clutter is the concern.
- The user wants a cleanup pass before deleting modules or consolidating features.

## Do Not Use This Skill When

- The task is just one compiler or lint error such as `no-unused-vars`; use the focused fixer path instead.
- The user only wants general code review.
- The target code is known to be dynamic and the task has no room for repo-specific verification.

## Detection Order

Follow this order. Do not jump straight to deletion.

### Step 1 — Define Scope

State the search scope explicitly:
- whole repo
- a directory or feature area
- a module family such as components, hooks, routes, or API handlers

If the user did not specify scope, choose the smallest scope that still matches the request.

### Step 2 — Prefer Repo-Native Signals

Check for existing tools or conventions before improvising:
- `knip`
- `ts-prune`
- `depcheck`
- ESLint or Biome unused rules
- framework-specific route or file-system conventions
- monorepo package boundaries and public API contracts

Use the project's native signal first when available. Use `rg` and code tracing to confirm, not to replace, stronger signals.

### Step 3 — Gather Evidence

For each candidate, collect the strongest available evidence:
- no imports or call sites
- exported but never consumed
- file is shadowed by a newer implementation
- route or command is no longer wired
- feature flag is permanently on or permanently off
- config entry, registry entry, or navigation item was removed upstream

Always check for hidden usage:
- dynamic imports
- string-based lookups
- reflection or plugin registration
- tests that intentionally keep compatibility surfaces alive
- public package exports consumed outside the current package

### Step 4 — Classify Risk

Put each finding in one of these buckets:

- `Safe delete`
  - private implementation with no references
  - duplicate legacy file fully replaced elsewhere
  - stale fixture, mock, or helper with no inbound usage
- `Review needed`
  - dynamic registration or string-based references might exist
  - exported API may be consumed externally
  - migration is incomplete or naming is ambiguous
- `Not dead`
  - still wired through runtime, config, tests, or external contract

### Step 5 — Decide Action Mode

If the user asked to **detect only**:
- report findings with bucket, evidence, and confidence
- do not delete code

If the user asked to **clean up**:
- remove only `Safe delete` candidates
- leave `Review needed` items in the report unless the user explicitly approves
- verify after removal with the most relevant local checks

## Output Format

When reporting findings, use this structure:

```md
## Safe delete

- `src/legacy/foo.ts` — no imports, no dynamic references found, replaced by `src/core/foo.ts`

## Review needed

- `src/routes/admin-old.tsx` — no static imports, but route names are assembled from strings in `src/router/buildRoutes.ts`

## Not dead

- `packages/sdk/index.ts` — export appears unused in-repo, but this package exposes a public API surface
```

Keep the evidence short but specific.

## Verification

After any deletion or cleanup:
- run the most relevant local check available
- prefer targeted test/build/lint commands over broad guesswork
- confirm the removed path is not referenced anymore

If verification cannot be run, state that explicitly.

## Documentation

If the project has an active tracking task, record either:
- the detection summary, if this was an audit only
- or the deleted paths plus verification, if cleanup was executed

Use `handoff.md` by default unless the task already has a deeper artifact.

## Done Definition

The work is complete when:
- scope is explicit
- evidence exists for each candidate
- safe-delete vs review-needed is clearly separated
- any executed cleanup is verified or the lack of verification is stated
