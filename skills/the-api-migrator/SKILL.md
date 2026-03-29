---
name: the-api-migrator
description: Audit and migrate API integrations — detects deprecated usage, plans migration, implements with TDD. Use when the user says "API 업그레이드해줘", "migrate API", "deprecated API 정리", "upgrade dependencies", or when a library/API version upgrade requires code changes.
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "API 업그레이드해줘"
  - "migrate to the new API"
  - "deprecated API 정리"
  - "upgrade this dependency"
---

# The API Migrator

Structured API/dependency migration: audit → plan → implement → verify.

## Use This Skill When

- Upgrading a library or API to a new major version.
- Migrating from one API/SDK to another (e.g., REST → GraphQL, v1 → v2).
- Cleaning up deprecated API usage flagged by linters or build warnings.
- The user says "API 업그레이드", "migrate", "deprecated 정리".

## Do Not Use This Skill When

- The upgrade is a patch version with no breaking changes (just bump the version).
- The user wants a code review of existing API usage (use the-code-reviewer).

## Workflow

### Step 1 — Audit Current Usage

Scan the codebase for all usage of the target API/library:

1. **Find imports**:
   ```
   grep -r "import.*from.*{library}" --include="*.ts" --include="*.tsx"
   grep -r "require.*{library}" --include="*.js"
   ```

2. **Find API calls**: search for specific function/method names from the changelog.

3. **Count usage**:
   ```
   ## API Audit: {library} v{current} → v{target}

   ### Import Locations
   | File | Import | Usage count |
   |---|---|---|
   | src/api/client.ts | { createClient } | 3 calls |
   | src/hooks/useData.ts | { query } | 12 calls |

   ### Deprecated API Usage
   | Deprecated | Replacement | Occurrences | Files |
   |---|---|---|---|
   | client.fetch() | client.request() | 8 | 4 files |
   | QueryOptions.enabled | QueryOptions.condition | 3 | 2 files |

   ### Breaking Changes (from changelog)
   | Change | Impact | Affected files |
   |---|---|---|
   | Removed default export | Must use named import | 6 files |
   | Changed return type | Promise<T> → AsyncResult<T> | 4 files |
   ```

### Step 2 — Migration Plan

```
## Migration Plan

### Strategy: {big bang | incremental | adapter pattern}

### Phase 1: Non-breaking preparation
- [ ] Add compatibility layer / adapter if needed
- [ ] Update type definitions
- [ ] Add tests for current behavior at migration boundaries

### Phase 2: API migration
- [ ] {file}: migrate {old} → {new}
- [ ] {file}: migrate {old} → {new}
- [ ] ...

### Phase 3: Cleanup
- [ ] Remove compatibility layer
- [ ] Remove old type definitions
- [ ] Update documentation

### Rollback Plan
- Revert to previous version by: {specific steps}
```

Choose strategy based on:
- **Big bang**: < 10 occurrences, low risk, good test coverage
- **Incremental**: > 10 occurrences, can use both old and new simultaneously
- **Adapter pattern**: many occurrences, old and new APIs are fundamentally different

### Step 3 — Implement with TDD

For each migration point:

1. **Write test** for expected new behavior (red).
2. **Migrate** the code (green).
3. **Refactor** if the new API enables cleaner patterns.
4. **Verify** existing tests still pass.

Use the-tdd skill principles but focused on migration:
- Test the new API contract, not internal implementation.
- Test edge cases where old and new APIs differ.

### Step 4 — Verify

```
## Migration Verification

### Test Results
- Unit tests: {pass/fail count}
- Integration tests: {pass/fail count}
- Type check: {pass/fail}

### Build Verification
- `tsc --noEmit`: {pass/fail}
- `bun build`: {pass/fail}

### Deprecated Usage Remaining
{grep result — should be zero}

### Manual Verification
- [ ] {critical flow 1} works correctly
- [ ] {critical flow 2} works correctly
```

### Step 5 — Report

```
## Migration Complete: {library} v{old} → v{new}

### Summary
- Files changed: {count}
- API calls migrated: {count}
- Tests added: {count}
- Breaking changes resolved: {count}

### Remaining Items
- {any deferred items or follow-ups}
```

## Integration with Other Skills

- **the-tdd**: TDD cycle for each migration point
- **the-build-fixer**: Fix build errors during migration
- **the-code-reviewer**: Review the migration PR
- **the-codebase-mapper**: Map usage before audit if codebase is unfamiliar

## Done Definition

The migration is complete when:
- All deprecated/old API usage is replaced (grep returns zero).
- All tests pass (existing + new migration tests).
- Build succeeds with no type errors.
- User has reviewed the migration summary.
