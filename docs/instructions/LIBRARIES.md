# LIBRARIES.md

Preferred libraries and frameworks for projects in this workspace.
Agents should follow this file before introducing new dependencies.

## Selection Rules

- Use this explicit precedence for dependency decisions:
  1. User direct instruction
  2. Project override (`./LIBRARIES.override.md` in target project root)
  3. Existing installed/used libraries in the target project
  4. This policy file (`docs/instructions/LIBRARIES.md`)
  5. Agent default choice
- Prefer libraries listed here over alternatives when no higher-precedence rule applies.
- Before implementation, detect currently installed/used libraries from manifests and code imports.
- Use existing installed/used libraries first; do not introduce new ones unless required.
- Reuse existing project dependencies when possible.
- If a required category is not listed, choose a minimal, well-maintained option and document it.
- Avoid adding overlapping libraries for the same responsibility.

## JavaScript / TypeScript

### Runtime / Package Manager

- `bun` (preferred)
- `npm` (fallback)

### Frontend Framework

- `react`

### UI

- `tailwindcss`
- `shadcn/ui`

### State Management

- `zustand`

### Forms / Validation

- `react-hook-form`
- `zod`

### Data Fetching

- `@tanstack/react-query`
- `axios`

### Web API

- `hono` (preferred for lightweight API/serverless)
- `fastify` (fallback for Node server apps)

### Testing

- `vitest`
- `playwright` (e2e)

### Desktop

- `electron`

## Python

### Environment / Tooling

- `uv` (preferred)
- `pip` + `venv` (fallback)

### Web API

- `fastapi`

### Testing

- `pytest`

## Rust

### App / Backend

- `tokio`
- `axum`
- `serde`

### Testing

- `cargo test` (standard)

## Notes

- Add project-specific overrides in each project README when necessary.
- Keep this file updated when team standards change.

## Project Overrides

Projects may define `./LIBRARIES.override.md` for local exceptions (`./` means target project root).

### Override Template

```md
# LIBRARIES.override.md

## Scope
- Project/Module:
- Effective date:

## Overrides
- Category:
- Preferred library:
- Replaces:

## Rationale
- Why override is needed:

## Safety
- Migration plan:
- Rollback plan:
```

### Precedence

1. User direct instruction
2. `./LIBRARIES.override.md`
3. Repository policy file `docs/instructions/LIBRARIES.md`
4. Agent default choice
