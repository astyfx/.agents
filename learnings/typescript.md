# TypeScript

## Type System

- `string | undefined` vs `string | null`: use `undefined` for optional values, `null` for intentional absence.
- `??` (nullish coalescing) checks for `null | undefined` only. `||` also catches `0`, `""`, `false`.
- Optional chaining `?.` short-circuits on `null | undefined` and returns `undefined` — make sure downstream code handles it.
- `as const` narrows a value to its literal type: `["a", "b"] as const` → `readonly ["a", "b"]`, not `string[]`.
- `satisfies` operator validates a value matches a type without widening it — useful for config objects.

## Utility Types

- `Partial<T>`: all properties optional. Use for patch/update payloads.
- `Required<T>`: all properties required. Inverse of Partial.
- `Pick<T, Keys>` / `Omit<T, Keys>`: extract or remove specific properties.
- `ReturnType<typeof fn>`: infer a function's return type without repeating it.
- `Parameters<typeof fn>`: infer a function's parameter types.
- `Awaited<T>`: unwrap a Promise type — `Awaited<Promise<string>>` → `string`.

## Common Errors and Fixes

- `Type 'X | undefined' is not assignable to type 'X'`: add `?? defaultValue` or guard with early return.
- `Property does not exist on type`: add the property to the interface, or use type narrowing.
- `Object is possibly null`: use optional chaining or explicit null check before access.
- `Argument of type 'string' is not assignable to parameter of type 'number'`: trace the source — usually a form input value that needs `parseInt`/`Number()`.
- `No overload matches this call`: function is overloaded — check which overload applies and match the argument types.

## Patterns

- Discriminated unions: add a `type` or `kind` field to each union member for safe narrowing.
- Type guards: `function isUser(x: unknown): x is User { return ... }` — narrows type in branches.
- Branded types: `type UserId = string & { __brand: 'UserId' }` — prevents accidental mixing of same-primitive IDs.
- `Zod` inferred types: `type FormData = z.infer<typeof formSchema>` — single source of truth for schema + type.

## Configuration

- `strict: true` in tsconfig enables all strict checks. Strongly recommended.
- `moduleResolution: "bundler"` for projects using Vite/Bun — more permissive than Node resolution.
- Path aliases (`@/*`): configure in both `tsconfig.json` (for types) and `vite.config.ts` / `bun.config.ts` (for bundler).
