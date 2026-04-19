---
name: the-agent-tool-schema
description: "Keep one schema as the single source of truth for a CLI subcommand's input flags, output envelope, CLI help text, AND the LLM tool definitions (Anthropic tools, OpenAI function-calling, MCP tool schemas) that agents consume. Use when starting a new agent-callable CLI, adding a new subcommand, or when flag/output drift between the CLI and the agent's tool list is causing tool-use bugs. Trigger phrases: 'tool schema 통합', 'cli와 tool definition 싱크', 'anthropic tool spec 자동 생성', 'zod schema에서 tool 뽑기', 'one schema drives everything', 'agent tool 정의 자동화', 'mcp tool schema 생성'."
compatible-tools: [claude, codex]
category: cli
test-prompts:
  - "cli랑 agent tool definition 싱크 맞추자"
  - "zod schema에서 anthropic tool spec 자동 생성"
  - "one schema for cli flags and tool definition"
  - "tool schema 통합 설계"
  - "openai function calling schema 자동 생성"
  - "mcp tool schema도 같은 소스에서"
  - "flag drift 방지"
---

# The Agent Tool Schema

An agent-callable CLI has two audiences: the CLI parser and the LLM that
decides whether to call it. When those two read different schemas, the
model hallucinates flag names and the parser rejects its calls. The only
reliable fix is **one schema, every consumer reads it**.

This skill is the pattern for that one schema — and the emit path to each
consumer format.

## Use This Skill When

- Starting a new agent-callable CLI (pair with `the-agent-cli`).
- Adding a subcommand that will also appear in an agent's tool list.
- Diagnosing flag drift between the CLI `--help` and the tool definition
  the agent sees.
- Unifying MCP tool schemas with the CLI they wrap.

## Do Not Use This Skill When

- The CLI has no agent caller (use `the-cli-designer`).
- The tool is one-off and will never gain a second consumer.

## Architecture

```
   ┌─────────── single source of truth ───────────┐
   │   commands/<noun>/<verb>.schema.ts            │
   │   - input  = z.object({...})                  │
   │   - output = z.object({ ok, data, error })    │
   │   - meta   = { summary, examples, sideEffects}│
   └─────┬────────────┬────────────┬───────────────┘
         ▼            ▼            ▼
    CLI parser   help text    tool definitions
   (argv → input) (--help)   (Anthropic / OpenAI / MCP)
         │
         ▼
    runtime execution → output envelope
         │
         ▼
    output schema validation → stdout
```

Every arrow is an emitter, not a hand-maintained file.

## The Schema Module

For each subcommand, one file exports a frozen record.

```ts
// commands/workspace/create.schema.ts
import { z } from "zod";

export const input = z.object({
  name: z.string().min(1).describe("workspace display name"),
  projectId: z.string().describe("target project id"),
  branch: z.string().optional().describe("git branch; defaults to main"),
  force: z.boolean().default(false).describe("overwrite if exists"),
});

export const output = z.discriminatedUnion("ok", [
  z.object({
    ok: z.literal(true),
    data: z.object({
      workspaceId: z.string(),
      path: z.string(),
      createdAt: z.string().datetime(),
    }),
  }),
  z.object({
    ok: z.literal(false),
    error: z.object({
      code: z.enum(["CONFLICT", "NOT_FOUND", "INVALID_INPUT"]),
      message: z.string(),
      hint: z.string().optional(),
    }),
  }),
]);

export const meta = {
  command: "workspace create",
  summary: "Create a new workspace in a project.",
  sideEffects: {
    writes: ["{STAVE_HOME}/workspaces/{id}/"],
    spawns: ["git worktree add"],
  },
  examples: [
    'stave workspace create --name "Default" --project-id p_123',
    'stave workspace create --name "Hotfix" --project-id p_123 --branch hotfix/ui',
  ],
  exitCodes: [0, 2, 5, 6],
} as const;
```

That single module feeds all downstream emitters.

## Emitter: CLI Parser Bindings

Your argv parser (citty, commander, etc.) reads the Zod input schema and
generates flag definitions. Provide a small bridge:

```ts
// lib/zod-to-citty.ts
export function flagsFromZod(shape: z.ZodObject<any>) {
  const flags: Record<string, FlagDef> = {};
  for (const [key, field] of Object.entries(shape.shape)) {
    flags[kebab(key)] = {
      type: zodToPrimitive(field),
      required: !field.isOptional(),
      default: defaultOf(field),
      description: field.description ?? "",
    };
  }
  return flags;
}
```

Parser consumes `flagsFromZod(input)`; validation runs `input.parse(argv)`
before execution.

## Emitter: Help Text

Help is rendered from the same schema plus `meta`:

```
stave workspace create --help

  Create a new workspace in a project.

  Usage: stave workspace create [flags]

  Flags:
    --name           <string>   workspace display name              (required)
    --project-id     <string>   target project id                   (required)
    --branch         <string>   git branch; defaults to main
    --force                     overwrite if exists                 (default: false)

  Exit codes: 0 success, 2 usage, 5 conflict, 6 permission denied

  Side effects:
    writes: {STAVE_HOME}/workspaces/{id}/
    spawns: git worktree add

  Examples:
    stave workspace create --name "Default" --project-id p_123
    stave workspace create --name "Hotfix" --project-id p_123 --branch hotfix/ui
```

Generate this from the schema; never hand-write it.

## Emitter: Anthropic Tool Definition

```ts
// lib/emit-anthropic.ts
export function toAnthropicTool(name: string, schema: z.ZodObject<any>, meta) {
  return {
    name,
    description: meta.summary,
    input_schema: zodToJsonSchema(schema), // use zod-to-json-schema
  };
}
```

Produces:

```json
{
  "name": "stave_workspace_create",
  "description": "Create a new workspace in a project.",
  "input_schema": {
    "type": "object",
    "properties": {
      "name":      { "type": "string", "description": "workspace display name" },
      "projectId": { "type": "string", "description": "target project id" },
      "branch":    { "type": "string", "description": "git branch; defaults to main" },
      "force":     { "type": "boolean", "default": false }
    },
    "required": ["name", "projectId"]
  }
}
```

## Emitter: OpenAI Function Calling

Same `zodToJsonSchema` call wrapped in OpenAI's `{ type: "function", function: { ... } }` shell.

## Emitter: MCP Tool Schema

For any command also exposed via MCP, the MCP tool definition reads the
same `input` schema:

```ts
server.tool(name, meta.summary, zodToJsonSchema(input), async (args) => {
  const parsed = input.parse(args);
  const result = await execute(parsed);
  return output.parse(result);
});
```

## Naming Convention

Generate tool names from the CLI command path:

```
CLI:               stave workspace create
Anthropic tool:    stave_workspace_create
MCP tool:          stave.workspace.create   (or stave_workspace_create)
```

Pick one convention, encode it in the emitter. Never hand-name.

## Output Envelope Rule

The `output` schema is not optional. Every emitter that describes return
shape (Anthropic tools support `output_schema` in some clients, MCP has
`returns`) should receive it. For the runtime:

```ts
const result = await run(parsed);
const validated = output.parse(result);  // crash if we lie to consumers
process.stdout.write(JSON.stringify(validated));
```

Validation on the way out catches shape drift the same day it's introduced.

## Versioning

- Add fields freely (optional + default).
- Removing or renaming a field is a breaking change — bump a `schemaVersion`
  in `meta` and keep the old schema around for one release.
- Agents may cache tool definitions; publish a `tools list` endpoint or
  file that consumers poll.

## Testing

For each subcommand, three tests minimum:

1. **Input parse** — known-good argv produces validated input.
2. **Output validation** — mocked runtime output passes the output schema.
3. **Emitter fidelity** — emitted Anthropic / OpenAI / MCP schema round-trips
   with a shape snapshot.

## Stave Integration

Every `mcp__stave-local-mcp__*` tool should map to one schema module. The
CLI `stave <noun> <verb>` wraps the same module. When you sunset the MCP
path, the schemas don't move — only the registration does.

## Red Flags

- Two JSON schemas for the same command (CLI and tool list) — delete one.
- Help text that describes a flag the parser doesn't accept.
- Tool definition published without `description` on each field — models
  guess.
- Output shape that the agent sees as `unknown` — always validate before
  writing.

## Integration with Other Skills

- `the-agent-cli`: the contracts (JSON default, exit codes, idempotency).
  This skill is how you realize them without duplication.
- `the-cli-designer`: the human-facing polish on top of the generated
  help.
- `the-ipc-schema-sync`: if the runtime crosses process boundaries, reuse
  the output schema over IPC too.

## Done Definition

- One schema module per subcommand; no hand-written mirrors.
- Parser, help text, and every tool-definition format are emitted, not
  typed.
- Output is validated before stdout write.
- Emitter snapshots in the test suite catch schema drift.
- Tool name convention is encoded once in the emitter.
