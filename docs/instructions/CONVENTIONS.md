# CONVENTIONS.md

Shared engineering conventions for all projects in this workspace.
Use this as the default unless a project provides an explicit override.

## Naming

- Files and directories: `kebab-case` (unless language/tooling convention requires otherwise)
- Variables and functions: follow language convention
  - JavaScript/TypeScript: `camelCase`
  - Python/Rust: `snake_case`
- Types, classes, and components: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Boolean variables: `is*`, `has*`, `can*`, `should*`

## Git

### Branch Naming

- `feat/<scope>-<short-desc>`
- `fix/<scope>-<short-desc>`
- `refactor/<scope>-<short-desc>`
- `chore/<scope>-<short-desc>`
- `docs/<scope>-<short-desc>`
- `test/<scope>-<short-desc>`

Examples:
- `feat/auth-login-flow`
- `fix/desktop-window-crash`

### Commit Messages

Use Conventional Commits:
- `feat: ...`
- `fix: ...`
- `refactor: ...`
- `chore: ...`
- `docs: ...`
- `test: ...`

IMPORTANT: MANDATORY FOR CODEX AND CLAUDE
- NEVER create, amend, or push commits with a non-Conventional message.
- If any non-Conventional commit exists, STOP and fix it immediately before any further work.

Rules:
- Use imperative mood
- Keep subject concise (about 72 chars)
- Add body for rationale and impact when needed

## Pull Requests

Each PR should include:
- problem/background
- scope of change
- test/verification evidence
- risk and rollback plan

Also:
- explicitly mark breaking changes
- run a self-review checklist before requesting review

## Code Quality

- Prefer small, single-purpose functions
- Replace magic values with named constants
- Validate inputs at boundaries (API/IPC/file I/O)
- Do not silently swallow errors
- Add short intent comments only where logic is non-obvious

## Comments

- **Explain why, not what** — comment the intent or constraint, not a restatement of the code
- **Don't comment self-evident code** — `// increment counter` above `count++` adds noise
- Use standard tags consistently:
  - `// TODO: <what> — <why>` for known gaps (include a brief reason)
  - `// FIXME: <what>` for known bugs that need a follow-up
  - `// HACK: <what> — <why>` when a workaround trades correctness for pragmatism
- **Public API / exported functions**: add a brief doc comment (JSDoc / docstring) describing the contract — inputs, return value, and any thrown errors
- **Internal helpers**: skip the doc comment unless the signature alone is unclear
- Remove commented-out code before merging; use git history instead

## Testing

- New feature: include happy path, failure path, and edge case coverage
- Bug fix: add a regression test reproducing the issue
- Use behavior-focused test names
- Run relevant tests locally before merge

## Logging and Observability

- Log user-impacting failures
- Include minimum debugging context:
  - input identifier
  - failure reason
  - retry status
- Never log secrets or credentials

## Documentation

- Update docs when behavior or architecture changes
- Record key decisions and tradeoffs in task tracking artifacts

## Task Tracking

Use `docs/instructions/TRACKING.md` as the single source of truth for tracking structure, required files, and phase lifecycle.

## Overrides

Project-level convention override file:
- `./CONVENTIONS.override.md` (`./` means target project root)

Library override file:
- `./LIBRARIES.override.md` (`./` means target project root)

Override docs must include:
- reason
- scope
- migration/rollback note
