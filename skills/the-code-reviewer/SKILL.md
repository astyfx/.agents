---
name: the-code-reviewer
description: Perform a structured code review on a file, diff, or pull request. Use when the user asks for code review, PR review, asks to "review this", "이 코드 봐줘", "코드 리뷰", "check for bugs", or when the user shares a diff or file and wants feedback. Produces a prioritized review with CRITICAL / SUGGESTION / NIT ratings across correctness, security, performance, conventions, architecture, and accessibility.
compatible-tools: [claude, codex]
category: review
test-prompts:
  - "코드 리뷰해줘"
  - "review this PR"
  - "이 파일에서 버그 찾아줘"
  - "check this for security issues"
---

# The Code Reviewer

Structured code review across six axes with clear severity ratings.

## Use This Skill When

- The user shares code and asks for review, feedback, or bug-finding.
- The user asks to review a PR, diff, or set of changed files.
- The user says "코드 리뷰", "review this", "이 코드 봐줘", "check for issues".

## Do Not Use This Skill When

- The user wants you to fix code (use the fix, not review).
- The user is asking a general question about code behavior.

## Pre-Review Checklist

Before starting, check for project-specific conventions:
1. Look for `./CONVENTIONS.override.md` in the project root.
2. Look for `CONTRIBUTING.md` or linter config (`.eslintrc`, `biome.json`, etc.).
3. Apply project conventions before workspace-level conventions.

## Review Axes

Cover all six axes. Skip axes that do not apply to the code type.

### 1. Correctness
- Logic errors, off-by-one, incorrect conditions
- Missing await on async calls
- Null/undefined access without guards
- State mutation side effects
- Wrong data types or coercions

### 2. Security
- Hardcoded secrets, API keys, tokens (always CRITICAL)
- Logging secrets or sensitive data (always CRITICAL)
- SQL/command injection risk
- Missing input validation at boundaries
- Unsafe direct object references
- Missing authentication/authorization checks

### 3. Performance
- Unnecessary re-renders (React: missing memo, missing deps, new objects in JSX)
- N+1 query patterns
- Large synchronous operations on the main thread
- Missing pagination on large data fetches
- Unnecessary bundle imports (import entire library for one function)

### 4. Conventions
- Naming: follows project conventions (camelCase, snake_case, PascalCase per context)
- Commit messages: Conventional Commits format
- No magic values (use named constants)
- No silent error swallowing
- Functions stay small and single-purpose

### 5. Architecture
- Layer leakage (UI importing infrastructure directly)
- Over-coupling between modules
- Missing abstraction for repeated patterns
- God objects/components doing too much

### 6. Accessibility (frontend only)
- Missing ARIA labels on interactive elements
- Keyboard navigation gaps
- Color contrast (flag if obviously broken)
- Missing alt text on images

## Output Format

Group findings by severity. Within each group, list by axis.

```
## [CRITICAL] Must fix before merge

- **Security** `src/api/auth.ts:14` — API key hardcoded as string literal. Move to environment variable.
- **Correctness** `src/hooks/useFetch.ts:31` — `response.json()` not awaited. Returns Promise, not data.

## [SUGGESTION] Worth addressing

- **Performance** `src/components/List.tsx:8` — New array created inside JSX on every render. Memoize outside component or use useMemo.

## [NIT] Style/preference

- **Conventions** `src/utils/format.ts:5` — Magic number `86400000`. Consider `const MS_PER_DAY = 86400000`.
```

If there are no findings in a severity category, omit it.

## Done Definition

The review is complete when:
- All six axes have been checked (or explicitly noted as N/A).
- Every CRITICAL issue has file + line reference.
- The summary is actionable: the author knows exactly what to fix.
