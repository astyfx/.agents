---
name: the-tdd
description: Guide test-driven development using the red-green-refactor cycle. Use when the user says "TDD", "테스트 먼저 작성", "red-green-refactor", "write tests first", or asks to implement a feature following TDD discipline. Enforces writing the failing test before any implementation code.
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "TDD로 구현해줘"
  - "write tests first"
  - "red-green-refactor"
  - "테스트 먼저 작성"
---

# The TDD Skill

Enforce the red-green-refactor cycle. Test first, always.

## Use This Skill When

- The user says "TDD", "test-driven", "write tests first", "테스트 먼저".
- The user asks to implement a feature with testing discipline.
- The user wants to practice or enforce TDD methodology.

## Do Not Use This Skill When

- The user has existing code and just wants tests added (use normal test writing).
- The user wants to fix a bug with a regression test (that is a different workflow).
- The user explicitly says they want implementation first.

## The TDD Cycle

Follow this order strictly. Do not skip steps.

### Step 1 — Red: Write the Failing Test

Before writing any production code:
1. Detect the test framework from the project (check package.json/pyproject.toml/Cargo.toml):
   - TypeScript/JavaScript: vitest (preferred), jest
   - Python: pytest
   - Rust: cargo test (inline or in tests/)
2. Write a test that specifies the expected behavior.
3. The test must fail at this point (the function/module does not exist yet).
4. Run the test and show the failure output. Do not proceed without showing the red state.

Minimum test coverage per feature:
- Happy path: normal input → expected output
- Failure path: invalid/missing input → expected error or fallback
- Edge case: boundary condition or unusual but valid input

### Step 2 — Green: Write Minimum Implementation

Write the smallest production code that makes the test pass.
- Do not add features beyond what the test requires.
- Do not optimize yet.
- Run the tests and show the passing output.

### Step 3 — Refactor: Clean Without Changing Behavior

After tests are green:
- Remove duplication
- Improve naming
- Simplify logic
- Run tests again to confirm they still pass after refactoring.
- If nothing needs refactoring, say so explicitly.

## Framework-Specific Notes

### Vitest (TypeScript/JavaScript)
- Use `describe` + `it` or `test` blocks
- Use `expect(...).toBe()`, `toEqual()`, `toThrow()`, `rejects.toThrow()` as appropriate
- For React components: use `@testing-library/react` with `render` + `screen` + `userEvent`
- Async: use `async/await` in test body, `vi.mock()` for module mocks

### pytest (Python)
- Use `def test_*` naming
- Use `pytest.raises(ExceptionType)` for error cases
- Fixtures for shared setup

### Rust (cargo test)
- Use `#[cfg(test)]` module with `#[test]` functions
- Use `assert_eq!`, `assert!`, `should_panic` as appropriate

## Done Definition

The TDD cycle is complete when:
- Red state was demonstrated (failing test shown).
- Green state was demonstrated (passing test shown).
- Refactor step was completed or explicitly skipped with reason.
- All specified coverage cases (happy, failure, edge) are present.
