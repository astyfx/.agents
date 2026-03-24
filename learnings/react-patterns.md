# React Patterns

## Server Components (RSC / Next.js App Router)

- Server Components cannot use `useState`, `useEffect`, or any browser APIs. Move state to a Client Component wrapper.
- `"use client"` propagates down: if a parent is a Client Component, all its children become client too.
- Async Server Components can `await` directly in the function body — no `useEffect` needed for data fetching.
- `params` and `searchParams` in App Router page components are now Promises in Next.js 15+ — must be awaited.
- Server Actions (`"use server"`) run on the server regardless of where they are called from.

## Data Fetching

- `@tanstack/react-query` `staleTime` controls when a refetch is triggered; `gcTime` controls when cached data is garbage collected. They are independent.
- Parallel queries: use `Promise.all` in Server Components; use `useQueries` in Client Components.
- Avoid waterfalls: fetch data as high in the tree as possible, then pass down as props.

## State Management

- Zustand store slices: keep each slice focused. Avoid a single giant store.
- Zustand with `immer`: use `produce` for nested state mutations; do not mutate directly.
- `useReducer` over `useState` when state transitions have more than 2-3 cases or have inter-dependencies.

## Performance

- `React.memo` prevents re-renders when props are reference-equal. Useless if parent passes new objects/arrays on every render.
- `useMemo` is for expensive computations, not just "I want to memoize this". Profile before adding.
- `useCallback` is only needed when passing callbacks to memoized children or as effect deps.
- Keys in lists must be stable and unique. Using array index as key breaks re-ordering and state.

## Rendering Patterns

- Conditional rendering with `&&`: `0 && <Component/>` renders `0`. Use ternary or explicit `!!condition`.
- Avoid creating component definitions inside render (new component reference every render, breaks reconciliation).
- `Suspense` boundaries: place them as close to the async component as possible, not at the root.

## Forms

- `react-hook-form` + `zod`: define schema first, infer types with `z.infer<typeof schema>`, pass to `useForm<T>`.
- `Controller` wraps controlled components (shadcn/ui inputs, Select, etc.); `register` works for native inputs.
- `formState.errors` only contains fields with errors — safe to check `errors.fieldName?.message`.

## Electron

- IPC handlers must be registered in the main process **before** `BrowserWindow` is created.
- Use `contextBridge.exposeInMainWorld` to expose safe APIs to renderer — never expose `ipcRenderer` directly.
- `webContents.send` from main to renderer; `ipcRenderer.invoke` / `ipcMain.handle` for async request-response.
