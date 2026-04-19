---
name: the-tui-designer
description: "Design and build terminal UIs (TUIs) with Ink (React for terminal) for Node/TypeScript projects — layout, focus management, keyboard input, raw-mode discipline, non-TTY fallbacks, and graceful exit. Use when building an interactive terminal experience (a dashboard, a prompt flow, a live view of agent activity), picking between Ink and alternatives, handling keyboard/signal/resize events, or when the user says 'tui 만들어', 'interactive terminal ui', 'ink으로 대시보드', 'terminal dashboard', '라이브 뷰 터미널', 'keypress 처리', 'non-tty fallback'. Pair with the-cli-designer for the command surface around the TUI."
compatible-tools: [claude, codex]
category: cli
test-prompts:
  - "terminal ui 만들어줘"
  - "ink으로 dashboard 만들기"
  - "tui 설계"
  - "interactive terminal prompt flow"
  - "라이브 뷰 터미널"
  - "keypress event 처리"
  - "non-tty 환경 fallback"
  - "terminal resize 처리"
---

# The TUI Designer

A TUI is a live, interactive surface in the terminal. Different from a
one-shot CLI: focus, keyboard events, redraw on resize, signal handling,
and — importantly — a fallback for when stdout is not a TTY (CI, pipe,
agent invocation).

For Node/TypeScript, default to **Ink** (React for the terminal). It gives
you a familiar render model, hooks, and a mature ecosystem of components.

## Use This Skill When

- Building a live terminal dashboard (processes, tasks, agent activity).
- An interactive prompt flow with multi-step navigation.
- Anything that needs to redraw on input / events / resize.
- Adding a TUI layer on top of an existing CLI (run `stave dash` to watch
  workspaces).

## Do Not Use This Skill When

- The interaction is a single question → answer (use `prompts` / `clack`
  or a flag on the CLI).
- The tool's primary consumer is an LLM agent (use `the-agent-cli`).
- Output is fine as streaming log lines (use plain stdout).

## Stack (Node/TypeScript default)

- **Renderer**: [Ink](https://github.com/vadimdemedes/ink) — React reconciler for terminal.
- **Components**: `ink-text-input`, `ink-select-input`, `ink-spinner`,
  `ink-table` where they fit. Roll your own when a component forces a
  style you don't want.
- **Input**: Ink's `useInput`, plus raw `process.stdin` when you need
  escape-sequence detail.
- **Layout**: Ink uses Yoga (flexbox). Think in `<Box>` rows/columns with
  `flexGrow`, `flexShrink`, `width`, `height`.
- **State**: zustand or React's own state depending on scope.

Alternatives to know (not default):

- **blessed** / **neo-blessed**: heavier, no React model, more low-level
  control. Pick only if Ink's flexbox is wrong for your layout.
- **clack**: great for guided prompt flows (wizard style), not for
  persistent dashboards.
- **prompts** / **enquirer**: one-shot prompts, not TUIs.

## Non-TTY Fallback (Mandatory)

Every TUI must detect `!process.stdout.isTTY` at startup and:

1. Refuse to render the interactive UI, or
2. Fall through to a plain, streamable representation (log lines, a single
   final table, NDJSON for agent consumption).

```ts
if (!process.stdout.isTTY) {
  await runHeadless();
  return;
}
await renderTui();
```

Skipping this breaks CI runs, SSH pipes, and any agent that tries to call
your tool without allocating a PTY.

## Layout Discipline

### L1 — Think in regions, not lines

Split the screen into named regions (header, sidebar, main, footer) and
keep each component's responsibility inside one region. A component that
reaches across regions is a future bug.

```
┌ header ─────────────────────────┐
│ stave · workspaces · 03:12      │
├─ sidebar ────┬─ main ──────────┤
│ > workspace1 │ task: build     │
│   workspace2 │ status: running │
│   workspace3 │ log:            │
│              │ ...             │
├─ footer ─────┴─────────────────┤
│ q quit  tab switch  / search   │
└────────────────────────────────┘
```

### L2 — Minimum viable width

Decide the minimum terminal width the UI supports (80 cols is a good
floor). Below that, render a "terminal too narrow" notice rather than a
broken layout.

### L3 — Resize is an event, not an afterthought

Subscribe to `process.stdout` `'resize'`. Re-measure in a useEffect so
Yoga re-lays out. Test by actually resizing the terminal during dev.

### L4 — Content scrolls, chrome doesn't

Header / sidebar / footer stay fixed. The main region is the only thing
that can scroll. Use a viewport component with its own scroll state, not
raw `\n` appends.

## Input Handling

### I1 — Focus is explicit

One focused region at a time. `Tab` / `Shift+Tab` moves between regions.
Inside a region, arrow keys move within.

Expose a `useFocus` hook pattern:

```ts
const { isFocused } = useFocus({ id: 'sidebar' });
useInput((input, key) => {
  if (!isFocused) return;
  if (key.upArrow) moveUp();
  if (key.downArrow) moveDown();
}, { isActive: isFocused });
```

Never handle global keys inside a focused region (conflicts with text input).

### I2 — Always bind quit

`q` and `Ctrl+C` must exit cleanly. Print a final one-line summary on exit
so the user sees a landing, not a half-erased screen.

### I3 — Text input stays in raw mode briefly

Ink manages raw mode automatically. If you drop to `process.stdin.setRawMode`
directly, restore it on every exit path (including crash). Use a
`finally` or `process.on('exit')` hook.

### I4 — Escape sequences are not your friend

Don't rely on specific terminal escape sequences for cursor positioning.
Let Ink redraw. Low-level escapes break on Windows Terminal, tmux, and
SSH with different TERM values.

## Rendering Discipline

### R1 — Bounded redraws

Ink re-renders on every state change. Put live data behind a throttled
source (subscribe, don't poll in a tight loop). 5–10 fps is plenty for a
dashboard.

### R2 — Truncate, don't overflow

Every Box with potentially-long content needs an explicit `width` and a
`textWrap="truncate"` or similar. Overflowing content pushes the chrome
around and looks broken.

### R3 — Color sparingly

Use color for status (green ok, red fail, yellow warn) and for the one
currently-selected row. Everything else stays in the default foreground.
Respect `NO_COLOR=1`.

### R4 — Unicode with a fallback

Box-drawing, braille spinners, emojis — assume some terminals render them
wrong. Expose a `--ascii` flag that swaps in plain characters.

## Signals and Lifecycle

- `SIGINT` → graceful exit. Render a goodbye line, flush, exit 0.
- `SIGTERM` → same, but exit 143.
- Background subscriptions (file watchers, event streams, IPC) must
  unsubscribe on unmount. Leaks become ghost processes.
- On crash: restore cursor visibility, clear alternate screen buffer,
  print the error. Users should never need to `reset(1)` their terminal
  after your TUI dies.

## Keyboard Cheatsheet Convention

Show an always-visible footer with the current context's 3–5 most useful
bindings. Full cheatsheet on `?` opens a modal/overlay.

```
footer: q quit · tab switch · enter select · / search · ? help
```

Unknown keys are silently ignored (never beep).

## Testing a TUI

- **Unit test the state reducers** independent of the renderer.
- **Snapshot test the rendered frames** with `ink-testing-library` —
  `render(<App />).lastFrame()`.
- **Manual matrix**: macOS Terminal, iTerm2, Windows Terminal, tmux,
  VSCode terminal. Resize each. Pipe output.

## Stave-Specific TUI Ideas

- `stave dash` — live overview of workspaces, active tasks, recent
  events. Good Ink candidate.
- `stave task watch <id>` — follow a running task's events with a
  sticky footer showing elapsed/tokens/status.
- `stave shell` — interactive REPL for calling CLI subcommands with
  history and completion.

When these also need to work non-TTY (agent invocation), route through
`the-agent-cli` for the headless code path.

## Anti-Patterns

- Rendering continuously in a `setInterval(tick, 16)` — burns CPU, makes
  logs unreadable.
- Hiding the cursor and forgetting to restore it.
- Handling `Ctrl+C` but still leaving subprocesses alive.
- Styling that assumes a dark background.
- Modal dialogs without a clear dismiss key.

## Integration with Other Skills

- `the-cli-designer`: the CLI surface that launches into the TUI.
- `the-agent-cli`: headless fallback for non-TTY and agent use.
- `the-terminal-surface-guard` (Stave): when the TUI is the Stave
  renderer's terminal surface, not a standalone binary.

## Done Definition

- Non-TTY fallback path exists and is tested.
- Resize handler reflows the layout.
- `q` and `Ctrl+C` exit cleanly; cursor is restored.
- Minimum-width notice shows below the chosen floor.
- Footer shows context-relevant bindings.
- `NO_COLOR` respected; `--ascii` flag available.
- Snapshot tests cover at least the main layout states.
