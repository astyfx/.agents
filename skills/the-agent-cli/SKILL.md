---
name: the-agent-cli
description: "Design and build CLIs intended to be called by LLM agents (not humans) — deterministic output, structured JSON mode, stable exit-code contract, machine-readable error envelopes, idempotent subcommands, and safe-by-default side effects. Use when building a CLI that will sit on the Stave/Claude/Codex tool surface, replace an MCP server with a CLI, expose internal stave operations as agent-callable commands, or when the user says 'agent용 cli', 'ai가 호출할 cli', 'tool cli', 'cli로 바꾸자 mcp 말고', 'stave 기능을 cli로', 'llm-safe cli', 'structured output cli'. This is the right skill when the primary caller is a model, not a person."
compatible-tools: [claude, codex]
category: cli
test-prompts:
  - "stave 기능을 cli로 만들어서 ai가 호출하게"
  - "design a CLI for an LLM agent to call"
  - "mcp 대신 cli로 노출하자"
  - "agent가 쓸 수 있는 cli 만들어줘"
  - "structured output cli 설계"
  - "json mode랑 exit code 제대로 맞추자"
  - "tool cli 만들기"
  - "llm-safe command for workspace ops"
---

# The Agent-Callable CLI

A CLI that will be invoked by an LLM is a different product than one a
human uses at the terminal. The model cannot see TTY colors, cannot read a
spinner, cannot click "y/n", and cannot infer intent from a free-form error
message. If the CLI does not hand back machine-readable output, the agent
has to parse prose — which is where tool use becomes unreliable.

This skill is the contract for designing CLIs that agents call correctly
every time.

## Use This Skill When

- Building a command intended to be exposed on an agent's tool surface.
- Replacing an MCP server with a CLI (smaller surface, easier to sandbox).
- Exposing Stave operations (workspace create, task run, plan apply,
  notes append, etc.) as commands agents can invoke.
- Wrapping an existing script so a model can drive it reliably.
- Designing the CLI surface before writing any code.

## Do Not Use This Skill When

- The CLI's primary audience is a human with a shell (use `the-cli-designer`).
- The tool is a one-off script you'll run by hand.

## Core Contract

Every agent-callable command must satisfy these. Treat them as a checklist
on the PR.

### C1 — Structured output mode is default for agents

Support `--json` (or `--output json`) that emits a single JSON object to
stdout. No prose, no ANSI colors, no progress spinners — those go to
stderr. If the CLI can run in either mode, make JSON the default when the
process is not attached to a TTY (`!process.stdout.isTTY`).

Output shape must be documented and stable:

```json
{
  "ok": true,
  "data": { ... },
  "warnings": [],
  "meta": { "version": "1.2.0", "command": "workspace create" }
}
```

Or on failure:

```json
{
  "ok": false,
  "error": {
    "code": "WORKSPACE_EXISTS",
    "message": "A workspace with id base:abc already exists.",
    "hint": "Use 'workspace update' or pass --force.",
    "details": { "workspaceId": "base:abc" }
  },
  "meta": { "version": "1.2.0", "command": "workspace create" }
}
```

### C2 — Exit codes are a contract, not a convenience

Fixed mapping the agent can branch on:

| Code | Meaning |
|---|---|
| 0 | success |
| 1 | generic failure (avoid — prefer specific) |
| 2 | usage error (bad flags, missing args) |
| 3 | precondition failed (file missing, wrong state) |
| 4 | not found |
| 5 | conflict / already exists |
| 6 | permission denied |
| 7 | timeout |
| 8 | upstream / network failure |
| 10–19 | domain-specific (document per command) |
| 124 | killed by timeout (matches `timeout(1)`) |

Document the map in `--help` and in the CLI's README. Never let an
unhandled exception leak as exit 1 — catch at the top level and route
through the error envelope.

### C3 — Idempotent by default

An agent will retry. Every mutating command should either be safe to
replay (same input → same end state) or accept `--idempotency-key` that
the CLI uses to dedupe. When that's not possible, the command's `--help`
must explicitly say "not idempotent" so the agent can plan around it.

Prefer:

- `ensure-*` verbs over `create-*` when the operation is convergent
- PUT-like semantics: accept full state, diff internally
- return the final state in the response so the agent can detect no-op vs
  applied change

### C4 — No interactive prompts unless explicitly allowed

Never block on stdin unless `--interactive` is passed or the process has a
TTY stdin. For agent use:

- missing required input → exit 2 with a descriptive error
- destructive action → require `--yes` or `--confirm <token>`
- never assume "press enter to continue"

### C5 — Deterministic output

Same inputs → byte-identical output (or documented-reason variance). Sort
keys, stable ordering in lists, no timestamps unless the command's job is
to emit them. Agents diff tool outputs; non-determinism looks like state
change.

### C6 — Small, orthogonal subcommands

Prefer many small verbs over one mega-command with `--mode`. An agent's
tool list works better with `stave workspace create`, `stave workspace
list`, `stave workspace delete` than `stave workspace --action=create`.

Group by noun, then verb:

```
stave <noun> <verb> [flags]
  workspace create|list|get|update|delete
  task      create|list|get|run|cancel
  notes     get|append|replace|clear
```

### C7 — Schema for every input and output

Write a Zod (or equivalent) schema for each subcommand's input flags and
output shape. Validate on entry, serialize on exit. Ship the schemas so
agents (or a generator) can produce tool definitions automatically.

### C8 — `--dry-run` on anything that mutates

Must print the exact plan (commands, files, network calls) without
executing. Output shape for dry-run matches the success envelope with
`data.plan` populated and `data.applied: false`.

### C9 — Bounded, documented side effects

Each command's `--help` lists:

- files it reads
- files/paths it writes
- network endpoints it calls
- processes it spawns
- env vars it requires

Agents need this to decide whether to call it under a given sandbox.

### C10 — Streaming uses line-delimited JSON

Long-running commands emit one JSON object per line (NDJSON) to stdout:

```
{"type":"progress","step":"clone","pct":12}
{"type":"progress","step":"install","pct":58}
{"type":"result","ok":true,"data":{...}}
```

Agents can parse per-line. Never stream partial JSON.

## Design Workflow

### Step 1 — Enumerate the agent's jobs, not commands

Start from the list of things an agent might want to do. "I need to create
a workspace with a git project and immediately start a task" → that's the
user story. Decompose into the smallest verbs that compose cleanly.

### Step 2 — Write the help output first

Before any code, write `stave <noun> <verb> --help`. If the help is hard
to write, the command is wrong. Each help block must include:

- one-line description
- full flag list with types and defaults
- input and output shape (schema or example)
- exit codes (the subset that applies)
- side effects (C9)
- example invocations

### Step 3 — Pin the output schema before the implementation

Freeze the JSON shape. Write a consumer fixture (what the agent will
parse) and assert on it in tests. The implementation follows the schema,
not the other way around.

### Step 4 — Test from the agent's perspective

Golden-file tests that invoke the compiled binary and diff stdout / exit
code. No mocks of the CLI framework itself — the integration is the point.

### Step 5 — Generate tool definitions from the schemas

One source of truth: the schemas drive both (a) the CLI's validation and
(b) the agent's tool list (OpenAI / Anthropic tool definitions, MCP tool
schemas if ever re-exposed). Do not hand-maintain both.

## Stave-Specific Guidance

When building Stave's CLI:

- **Respect workspace boundaries.** Any command that mutates must accept
  `--workspace <id>` or read an env var (`STAVE_WORKSPACE_ID`). Never
  default to "the active workspace" — agents don't have an active
  workspace concept.
- **Single binary, noun-first subcommands.** `stave <noun> <verb>` scales
  to the full surface without namespace collisions.
- **Map existing MCP tools 1:1 first.** Each `mcp__stave-local-mcp__*`
  becomes `stave <noun> <verb>`. After the mapping is complete, then
  consolidate or split.
- **Prefer SQLite-direct over IPC.** If the command reads state, read
  from the workspace DB directly. Going through main → host-service adds
  latency and coupling.
- **Emit task-lifecycle events as NDJSON** for `stave task run` so the
  calling agent can narrate progress.

## Red Flags

- "We can add `--json` later" — no. Retrofitting stable output later
  breaks every agent already parsing.
- "The agent can read stderr for errors" — no. stderr is for humans.
  Errors go in the stdout envelope with `ok: false`.
- "Let's use a TUI for confirmation" — no. Confirmation is a token flag.
- Commands that can partially succeed without saying so. Either the
  envelope reports `warnings[]` or the command doesn't partial-succeed.

## Integration with Other Skills

- `the-cli-designer`: for the human-facing UX pieces (help formatting,
  colors in TTY mode, shell completion).
- `the-tui-designer`: if a subset of commands gains an interactive mode.
- `the-ipc-schema-sync`: when the CLI talks to Stave's host-service.
- `the-build-fixer`: CI for binary packaging and exit-code regression
  tests.

## Done Definition

- `--json` output is default when not a TTY; schema is frozen and tested.
- Exit-code map is documented per subcommand.
- Every mutating command is idempotent or has `--idempotency-key`.
- No command blocks on stdin without `--interactive`.
- `--dry-run` works on every mutating command.
- Help output documents side effects (C9).
- NDJSON streaming for long-running commands.
- Agent tool definitions generated from the same schemas the CLI uses.
