---
name: the-cli-designer
description: "Design human-facing CLIs — argv parsing, subcommand taxonomy, --help, TTY-aware color/progress, shell completion, good errors. Use when the primary user is a developer at a terminal or picking argv parsers (commander, yargs, oclif, citty), or the user says 'cli 설계', 'argv 파싱', 'shell completion', 'cli ux'."
compatible-tools: [claude, codex]
category: cli
test-prompts:
  - "cli 설계해줘"
  - "make this CLI easier to use"
  - "argv parser 어떤 거 쓸까"
  - "subcommand 구조 잡아줘"
  - "shell completion 붙이기"
  - "help output 개선"
  - "error message 정리"
  - "cli ux 다듬어줘"
---

# The CLI Designer (Human-Facing)

A CLI for humans needs different things than a CLI for agents. A developer
will read help screens, scan colored output, hit tab for completion, and
interpret error messages in context. Your job is to make the terminal feel
like a good product.

For CLIs that LLM agents invoke, use `the-agent-cli` — the output contracts
are stricter there. When one CLI serves both, compose the two skills.

## Use This Skill When

- Designing a CLI whose primary caller is a person.
- Picking an argv parser and subcommand taxonomy.
- Improving help output, error messages, colors, or progress indicators.
- Adding shell completion.
- Cleaning up an existing CLI that grew organically.

## Do Not Use This Skill When

- The CLI is agent-first (use `the-agent-cli`).
- It's an internal script with one entry point and no subcommands.

## Parser Choice (Node/TypeScript)

No perfect answer. Pick by weight:

| Parser | Strength | Pick when |
|---|---|---|
| `citty` | modern, typed, tiny, good subcommand tree | new CLIs that need clean types |
| `cac` | minimal, fast, good for small tools | quick CLIs, not too many commands |
| `commander` | ubiquitous, battle-tested | you want zero surprises for contributors |
| `yargs` | feature-rich, complex | legacy or heavy flag logic |
| `clipanion` | class-based, strong types | large surfaces, team familiar with classes |
| `oclif` | framework (plugins, updates) | you need plugin architecture and auto-update |

Default to `citty` for new Stave-adjacent CLIs. Switch only if a specific
constraint (plugins, dynamic commands) needs it.

## Design Principles

### P1 — Noun-first, verb-second

`tool <noun> <verb>` scales. `tool <verb> <noun>` does not (verbs conflict
fast: `list`, `get`, `show` all mean roughly the same thing).

```
good: stave workspace create
      stave task run
bad:  stave create-workspace
      stave run-task
```

Exception: top-level common verbs (`version`, `help`, `init`, `doctor`).

### P2 — Flags have one job each

- long form required (`--workspace`), short form optional (`-w`)
- boolean flags are `--foo` / `--no-foo`, not `--foo=true`
- flags that take values use `--foo=value` or `--foo value`, both
  accepted
- required flags have helpful error messages naming the missing flag

### P3 — Help is the product surface

For every command, `--help` must include:

- one-line description
- usage pattern (`tool noun verb [flags]`)
- flag list aligned in two columns, with default values
- 2–4 example invocations copy-pasteable
- pointers to related commands ("see also: ...")

Invest in this. Most users never read README; they read `--help`.

### P4 — Color and progress are TTY-gated

- Detect `process.stdout.isTTY`.
- Respect `NO_COLOR=1` and `FORCE_COLOR=*` env vars.
- Spinners only in TTY, and they go to stderr.
- When piped, emit plain, parseable text.

### P5 — Error messages answer three questions

Every error prints:

1. **What happened.** Name the operation and the failure.
2. **Why.** Concrete cause (file path, exit code, permission).
3. **How to recover.** One actionable next step.

```
bad:  Error: EACCES
good: Cannot write to /var/stave/workspaces: permission denied.
      Try: sudo chown -R $USER /var/stave, or set STAVE_HOME elsewhere.
```

### P6 — Confirmation for destructive operations

Delete / reset / force commands must:

- print what will be destroyed
- require `-y` / `--yes` OR interactive confirm (default interactive when TTY)
- support `--dry-run` to preview without acting

### P7 — Shell completion matters

Generate completion for bash, zsh, fish. Publish via:

```
stave completion bash > /usr/local/etc/bash_completion.d/stave
```

citty / clipanion / oclif can emit completion automatically. Wire this
from day one; adding it later breaks muscle memory.

### P8 — `doctor` and `version` are first-class

- `tool version` prints version + commit SHA + runtime info.
- `tool doctor` checks preconditions (node version, paths, permissions,
  required binaries) and prints a pass/fail for each.

Both pay for themselves the first time a user reports a bug.

## Output Formatting for Humans

- Align columns. Right-align numerics, left-align identifiers.
- Use a table for list output, a single-block key-value for detail output.
- Colors: one accent for identifiers, dimmed for metadata, red for
  destructive, yellow for warnings. Stop there.
- Never truncate silently — truncate with `…` and hint at `--wide` or `--json`.
- Timestamps in local time by default, UTC with `--utc`.

## Error Taxonomy

Map exits to human-friendly summaries too. Use the same code map as
`the-agent-cli` so both personas share a contract:

```
tool workspace create --name foo
Error: workspace "foo" already exists (exit 5).
Hint: run 'stave workspace list' to see existing workspaces,
      or pick a new name.
```

## Anti-Patterns

- One flag does five things depending on other flags.
- `--help` longer than two screens per command.
- Colored JSON output without a `--color=never` escape.
- Prompts that can't be bypassed with a flag (blocks CI).
- Quiet mode that still prints a banner.
- Exiting 0 on partial failure.

## Stave-Specific Hooks

- `stave doctor` should check: node version, Bun availability, SQLite
  writable, git worktree support, provider auth status.
- Long operations (task run, workspace bootstrap) should print a single
  concise start/end block with an elapsed time, even in non-TTY mode.
- Respect `STAVE_HOME`, `STAVE_WORKSPACE_ID`, `STAVE_PROFILE` env vars so
  scripts don't need to pass them every time.

## Integration with Other Skills

- `the-agent-cli`: for the machine-readable output contract on the same CLI.
- `the-tui-designer`: when a subset of commands opens an interactive UI.
- `the-build-fixer`: for packaging / cross-platform binary issues.

## Done Definition

- Subcommand taxonomy is noun-first.
- Every command has a full `--help` with examples.
- TTY detection gates color and progress.
- Error messages answer what / why / how.
- Shell completion ships from day one.
- `version` and `doctor` commands exist.
- Destructive commands require confirmation and support `--dry-run`.
