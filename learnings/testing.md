# Testing

## Vitest

- `vi.mock('module-path')` is hoisted to the top of the file automatically. Variables used in the mock factory must be prefixed with `mock` to avoid hoisting issues.
- `vi.spyOn(object, 'methodName')` for non-module mocks; restore with `vi.restoreAllMocks()` in `afterEach`.
- `vi.useFakeTimers()` for time-dependent tests; call `vi.runAllTimers()` or `vi.advanceTimersByTime(ms)` to progress.
- `screen.getByRole` is preferred over `getByTestId` — more resilient to implementation changes.
- `userEvent.setup()` returns an instance; call `user.click()`, `user.type()` etc. on the instance (not the old direct `userEvent.click()`).
- `waitFor` retries until the assertion passes or timeout. Use for async UI updates.

## Test Structure

- Test names should describe behavior, not implementation: `"shows error when email is invalid"` not `"tests validateEmail"`.
- AAA pattern: Arrange (setup) → Act (trigger) → Assert (verify). Separate each phase visually.
- One assertion concept per test is ideal. Multiple `expect` calls for the same behavior are fine.
- Avoid testing implementation details. Test what the user/caller would observe.

## Mocking

- Mock at the boundary (API calls, file system, timers), not inside business logic.
- `msw` (Mock Service Worker) for API mocking in integration tests — closer to real behavior than manual fetch mocks.
- Prefer `vi.fn()` return values over complex mock implementations when possible.

## Coverage

- Coverage thresholds are a floor, not a goal. 80% coverage with meaningful tests > 100% coverage with trivial tests.
- Branch coverage matters more than line coverage for business logic.
- Focus coverage on: boundary conditions, error paths, state transitions.

## pytest

- Fixtures with `scope="session"` share state across the entire test run — use carefully.
- `pytest.raises(ExceptionType, match="pattern")` asserts both the type and message.
- `monkeypatch` for environment variable overrides and temporary attribute patches.
- `tmp_path` fixture provides a temporary directory per test — prefer over manual `tempfile` usage.
