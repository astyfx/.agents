# API Design

## REST Conventions

- Resources are plural nouns: `/users`, `/posts`, `/comments` — not `/user`, `/getPost`.
- HTTP methods: GET (read), POST (create), PUT (replace), PATCH (partial update), DELETE (remove).
- Nested resources for ownership: `/users/:id/posts` — but avoid nesting deeper than 2 levels.
- Filter/sort/paginate via query params: `GET /posts?status=published&sort=createdAt&order=desc&page=2`.

## Response Shapes

- Consistent success envelope: `{ data: T }` or just `T` — pick one and apply everywhere.
- Consistent error envelope: `{ error: { code: string, message: string, details?: Record<string, string> } }`.
- HTTP status codes matter: 200 (ok), 201 (created), 204 (no content), 400 (bad request), 401 (unauthorized), 403 (forbidden), 404 (not found), 409 (conflict), 422 (validation error), 500 (server error).
- 400 = malformed request (syntax). 422 = well-formed but semantically invalid (failed validation).

## Validation

- Validate at the boundary using Zod (TypeScript) or Pydantic (Python).
- Return all validation errors at once (not just the first one) — `{ details: { field: message } }`.
- Reject unknown fields in request bodies to prevent mass-assignment vulnerabilities.

## Authentication

- JWTs in `Authorization: Bearer <token>` header — not cookies for API-only endpoints.
- Short expiry for access tokens (15min–1hr), longer for refresh tokens (days–weeks).
- Never log the full JWT — it is a credential.
- Validate `aud` (audience) and `iss` (issuer) claims in JWT verification.

## Hono (lightweight API framework)

- `c.req.valid('json')` after `zValidator` middleware — gives typed, validated body.
- `c.json(data, status)` for responses — handles Content-Type automatically.
- Route grouping via `app.route('/prefix', subApp)` — keeps routes organized.
