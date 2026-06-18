# Task 02 — TDD Cycle

## Category
Test-driven development

## Input Prompt

Use TDD to implement a `formatCurrency(amount: number, locale: string, currency: string): string` utility function.

Rules:
- Write the failing test first using vitest. Show the test output (red).
- Then write the minimum implementation to make it pass (green).
- Then refactor if anything can be cleaner.
- Tests must cover: positive amounts, zero, negative amounts, different locales (en-US, ko-KR), large numbers.
- Do not use any external currency library. Use Intl.NumberFormat.

## Success Criteria

- [ ] Test file written before implementation file
- [ ] Failing test output shown before implementation
- [ ] All specified cases covered (positive, zero, negative, two locales, large number)
- [ ] Implementation uses Intl.NumberFormat correctly
- [ ] All tests pass after implementation
- [ ] Refactor step produces cleaner code (or agent explains why no refactor is needed)

## Scoring Notes

Rework +1 for: skipping to implementation without showing red state, missing test cases, incorrect Intl usage.
