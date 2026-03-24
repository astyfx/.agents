# Architecture

## Layering

- Clear layer order: UI → Application → Domain → Infrastructure. Each layer only imports from layers below it.
- UI components do not import infrastructure (database clients, HTTP clients) directly. Go through application layer.
- Domain logic does not import UI or framework code. It is framework-agnostic.
- Infrastructure (DB, HTTP, file system) is injected, not imported — makes testing and swapping easier.

## Component / Module Design

- Single Responsibility: each module does one thing. If you need "and" to describe it, split it.
- Explicit interfaces: define what a module accepts and returns. Avoid passing large config objects when a few named params suffice.
- Avoid premature abstraction: wait for the third occurrence before extracting. Two usages = coincidence, three = pattern.
- Co-locate: keep tests, types, and implementation together unless cross-cutting concerns require separation.

## State

- Lift state only as high as needed. Avoid global state for local concerns.
- Server state (remote data) and client state (UI state) are different problems. Use react-query for server state, Zustand/useState for client state.
- Derived state: compute from source of truth, do not sync separately maintained copies.

## API Design

- Resources are nouns, actions are HTTP methods: `GET /users` not `GET /getUsers`.
- Consistent error envelope: `{ error: { code, message, details? } }` — same shape everywhere.
- Pagination: prefer cursor-based over offset-based for large/changing datasets.
- Versioning: `/api/v1/` prefix for breaking changes. Internal tools can often skip versioning.

## Boundaries

- Validate at the boundary: incoming HTTP requests, IPC messages, file inputs. Trust internal data after validation.
- Fail explicitly: throw or return error at the point of failure. Do not silently return defaults that hide problems.
- Idempotency: design mutations to be safely retried. Use unique IDs for create operations.

## Refactoring

- "Make it work, make it right, make it fast" — in that order.
- Refactor with tests green. Never refactor and change behavior simultaneously.
- Small steps: one rename, one extraction, one move per commit. Easier to review, easier to revert.
