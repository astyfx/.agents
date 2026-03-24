# Build Tooling

## Bun

- `bun install` is faster than npm/yarn for fresh installs; lockfile is `bun.lockb` (binary, not human-readable).
- `bun run` executes scripts from package.json; `bunx` runs package binaries without global install.
- Bun's bundler (`bun build`) is fast but less mature than Vite for complex setups — use Vite for production web apps.
- `bun test` uses Jest-compatible API but is not Vitest — check which runner your project uses.

## Vite

- HMR (Hot Module Replacement) breaks on circular imports — resolve circles before assuming HMR is broken.
- `import.meta.env.VITE_*` variables are replaced at build time — changing them requires a rebuild, not a restart.
- `resolve.alias` in vite.config must match `paths` in tsconfig.json — both need updating when adding path aliases.
- Vite's dev server proxies API calls via `server.proxy` — use this instead of hardcoding dev API URLs.

## TypeScript Build

- `tsc --noEmit` validates types without producing output — use in CI to catch type errors cheaply.
- `tsconfig.json` `include`/`exclude` paths are relative to the tsconfig location, not the project root.
- `composite: true` enables project references — needed for monorepo setups with `tsc -b`.

## Next.js

- `.env.local` is not committed and overrides `.env` locally. `.env.production` is for production-specific values.
- `NEXT_PUBLIC_*` variables are exposed to the browser at build time. All other `process.env` vars are server-only.
- Incremental Static Regeneration (ISR): `revalidate` in `fetch` options, not `next.revalidate` in route config.
- Turbopack (`--turbo` flag) is faster for dev but may behave differently from webpack — test before enabling in CI.
