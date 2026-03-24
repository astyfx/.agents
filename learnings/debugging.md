# Debugging

## TypeScript / JavaScript

- `console.log` of an object prints the live reference — the value may have changed by the time you inspect it. Use `JSON.parse(JSON.stringify(obj))` or `structuredClone(obj)` to snapshot.
- `undefined` in output often means: optional chaining short-circuited, missing async await, or wrong object path.
- `NaN` propagates silently — `NaN === NaN` is `false`. Check with `Number.isNaN()`.
- Async error swallowing: unhandled promise rejections don't crash in all environments. Add `.catch()` or `try/catch` around all `await` calls.

## React

- Infinite re-render loops: usually caused by `useEffect` with a dependency that changes on every render (new object/array reference). Memoize the dependency or restructure the effect.
- Stale closure in `useEffect`: the effect captures variables at the time it was created. Include all used variables in the deps array, or use `useRef` for values you want to read without re-running.
- Missing key warning in lists: React uses keys to track element identity. Duplicate or missing keys cause incorrect reconciliation.
- Component not updating: check if the state setter is being called (not just mutating the state value), and that the component is actually subscribed to the store/context.

## Network

- CORS errors in browser: the issue is on the SERVER (missing headers), not the client. Add `Access-Control-Allow-Origin` to the API response.
- 401 vs 403: 401 = not authenticated (no valid credentials), 403 = authenticated but not authorized (wrong permissions).
- Timeout errors: distinguish between connection timeout (server unreachable) and read timeout (server slow to respond).

## Build / Environment

- "Works on my machine": check Node/Bun version, installed packages (`node_modules`), environment variables, and OS-specific path separators.
- Cache issues: try deleting `.next/`, `dist/`, `node_modules/.cache/` before assuming the code is broken.
- Environment variables not loading: check file name (`.env.local` vs `.env`), variable prefix (`NEXT_PUBLIC_` for client-side), and whether the server was restarted after adding them.
