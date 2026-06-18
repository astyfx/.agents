---
name: the-subprocess-orchestrator
description: "Spawn and supervise child processes safely from Node/Bun — lifecycle, stdio streaming, timeout, kill tree, signals, backpressure, PTY vs pipe, zombie prevention. Use when building CLI/host-service code that shells out to git, docker, test runners, or user scripts, or when the user says 'subprocess 관리', 'child process spawn', 'kill tree', 'pty로 실행', 'zombie 방지'."
compatible-tools: [claude, codex]
category: cli
test-prompts:
  - "subprocess 제대로 관리"
  - "spawn a child process with timeout and kill tree"
  - "stdio streaming 백프레셔"
  - "pty vs pipe 어떤 거 써야 해"
  - "zombie process 방지"
  - "user script를 안전하게 실행"
  - "git을 shell out 해서 실행"
  - "kill 자식 프로세스 전부"
---

# The Subprocess Orchestrator

Shelling out looks easy until it deadlocks a CLI, leaks a zombie, or kills
the wrong process tree. This skill is the checklist for doing it correctly
in Node/Bun — for CLIs that call helpers, host-services that run user
scripts, and agents that need clean exit semantics.

## Use This Skill When

- A CLI subcommand shells out (git, codex, claude, docker, tests).
- A host-service runs user-defined scripts or long-running tasks.
- You need timeout, cancellation, or streaming output.
- You're choosing between `spawn`, `exec`, `execFile`, and a PTY library.

## Do Not Use This Skill When

- The work can stay in-process (a library call, not a binary).
- You need a task queue / scheduler (use a job runner, not ad-hoc spawn).

## Spawn API Choice

| API | Use when | Avoid when |
|---|---|---|
| `child_process.spawn` | streaming stdout/stderr, unknown output size | you just want a buffer |
| `child_process.execFile` | small, bounded output, args as array | interactive I/O, large output |
| `child_process.exec` | almost never — shell injection risk | always prefer execFile |
| `child_process.fork` | Node-to-Node IPC channel | non-Node children |
| `node-pty` | the child detects TTY and changes behavior (colors, prompts, xterm) | output is just pipes |
| Bun.spawn | same as spawn, faster under Bun | need Node-only features |

Rule of thumb: **spawn with args-as-array** by default. Use PTY only when
a pipe makes the child misbehave (`git` without TTY behaves fine;
`codex exec` prompts without TTY get confused).

## Contract for Every Spawn

Treat every subprocess invocation as a mini product. Required:

### S1 — args as array, never a string

```ts
good: spawn("git", ["clone", url, dest]);
bad:  spawn(`git clone ${url} ${dest}`, { shell: true });
```

Shell=true plus string interpolation is a vulnerability. Use array form
and let the OS do argument separation.

### S2 — cwd and env are explicit

```ts
spawn("node", [script], {
  cwd: workspaceRoot,
  env: { ...process.env, STAVE_WORKSPACE_ID: ws.id, PATH: sanitizedPath },
});
```

Never rely on the caller's cwd. Sanitize PATH when spawning user
scripts — don't leak absolute paths that only exist in the dev's machine.

### S3 — stdio wired intentionally

```
stdio: ["ignore", "pipe", "pipe"]   // no stdin, capture out/err
stdio: ["pipe",   "pipe", "pipe"]   // feed stdin, capture both
stdio: ["inherit","inherit","inherit"] // pass through (interactive)
```

If you capture stdout/stderr, you **must** consume them. An unconsumed
pipe fills the OS buffer and deadlocks the child at ~64KB.

### S4 — Streaming with backpressure

Use readable streams, not `on('data', collect)` for long outputs.

```ts
for await (const chunk of child.stdout) {
  await consumer.write(chunk);   // respects downstream backpressure
}
```

Or pipe: `child.stdout.pipe(destination)`. Don't accumulate unbounded
`Buffer.concat` of unknown-size stdout.

### S5 — Timeout with kill tree

A timeout that kills only the child leaves grandchildren running.
On POSIX: spawn with `detached: true` and negate the pid to kill the
group. On Windows: use `taskkill /T`.

```ts
const child = spawn(cmd, args, { detached: true });
const timer = setTimeout(() => {
  try {
    process.kill(-child.pid, "SIGTERM");    // group kill
    setTimeout(() => process.kill(-child.pid, "SIGKILL"), 3000);
  } catch {}
}, timeoutMs);
child.on("exit", () => clearTimeout(timer));
```

Or use `tree-kill` / Bun's equivalent for cross-platform.

### S6 — Escalating signals, not one shot

Graceful first, then force:

```
SIGTERM → wait 3s → SIGKILL
```

Children running tests or servers need time to flush. Skipping SIGTERM
corrupts state.

### S7 — Parent crash leaves no zombies

- Register `process.on("exit")` and kill tracked children.
- For critical services, detach the child and log its pid so a supervisor
  can reap it if the parent dies.
- `unref()` only when you genuinely want the child to outlive the parent
  (rare).

### S8 — Exit code + signal + error are three things

```ts
child.on("close", (code, signal) => {
  if (code === 0) resolve();
  else if (signal === "SIGTERM") reject(new TimeoutError());
  else reject(new SubprocessError({ code, signal, cmd }));
});
child.on("error", (err) => reject(err));  // spawn failure (ENOENT, EACCES)
```

`error` fires when spawn itself fails (binary missing, permission).
`close` fires when the child exits. Handle both.

### S9 — Output is structured at the boundary

When a subprocess is part of an agent-callable CLI, translate the child's
result into the CLI's output envelope:

```ts
{ ok: false, error: {
  code: "SUBPROCESS_FAILED",
  message: `git clone exited with code ${code}`,
  details: { cmd: "git clone ...", exitCode: code, stderr: tail(err, 4096) }
}}
```

Never forward raw stderr to the agent. Capture, summarize, include a
tail.

### S10 — Cancellation is an AbortSignal

Expose cancellation at the caller level:

```ts
async function run(cmd, args, opts: { signal?: AbortSignal }) {
  const child = spawn(cmd, args);
  opts.signal?.addEventListener("abort", () => kill(child));
  // ...
}
```

Matches fetch / stream conventions. CLI `Ctrl+C` handlers wire into the
same AbortController.

## PTY Specifics

When using `node-pty`:

- Resize on terminal resize: `pty.resize(cols, rows)`.
- The child sees a TTY; expect ANSI escapes in stdout. Strip or pass
  through depending on consumer.
- PTY exits cleaner than pipe for interactive children — don't force
  SIGKILL if a clean "exit" command would work.
- Binary rebuild for Electron ABI is required (Stave already patches
  this).

## Stave Specifics

### Workspace scripts (user-supplied)

User scripts run in the host-service. Constraints:

- **sandbox env**: strip secrets, freeze PATH to whitelisted binaries
- **cwd**: workspace root, not project root
- **timeout**: default ceiling (e.g. 10 min), configurable per script
- **output cap**: e.g. 10MB stdout, 10MB stderr; tail-truncate with a
  banner when exceeded
- **kill on workspace unload**: track pids per workspace, kill tree on
  close

### Shelling out to providers (claude, codex)

- PTY when the provider wants a TTY (full-auto codex is happier in PTY).
- Capture structured events from stdout (NDJSON or SSE), not free-form
  prose.
- Health-check: a provider that hangs for > N seconds without output
  → kill + fallback.

### IPC-reported progress

Long subprocesses in the host-service should report progress to main via
typed IPC messages (see `the-ipc-schema-sync`). Don't bundle raw stdout
across IPC — summarize at the boundary.

## Anti-Patterns

- `{ shell: true }` with user-provided arguments.
- `child.on('exit')` without a matching `'error'` handler (spawn failures
  fall through silently).
- Buffering unbounded stdout into a variable.
- `SIGKILL` as the first signal.
- Killing by pid on POSIX (should be pgid for tree).
- Relying on the child to respect Ctrl+C via stdin — use signals.

## Integration with Other Skills

- `the-agent-cli`: CLIs that shell out must still respect the output
  envelope contract (S9).
- `the-cli-designer`: `--timeout`, `--kill-grace`, `--no-color` flags on
  the parent.
- `the-terminal-surface-guard` (Stave): when the subprocess feeds an
  xterm surface in the renderer.
- `the-ipc-schema-sync`: progress events across host-service → main → renderer.

## Done Definition

- All spawns use array args, explicit cwd, explicit env.
- stdio pipes are consumed or closed — no deadlock by unread buffer.
- Every long-running subprocess has timeout + kill tree + signal
  escalation.
- Both `error` and `close` handlers are wired.
- Cancellation is an AbortSignal plumbed from the caller.
- Output that crosses a process or API boundary is structured, capped,
  and sanitized.
