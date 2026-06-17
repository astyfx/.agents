# Connectors and Plugins

## Trigger

Use when a task needs an external system (Slack, GitHub, Jira/Atlassian, Figma,
Linear, Playwright/browser, a data source) and you need to know what is available
and how to reach it.

## Concept model (read first)

- **Hosted connectors (claude.ai) are deferred tools.** The session lists them by
  name without a schema. You cannot call one until you load its schema with
  `ToolSearch` (`select:<name>` or a keyword query). Connecting servers may take a
  moment to appear; search by keyword rather than declaring a capability missing.
- **Local MCP servers** are wired in `claude/settings.json` `mcpServers`
  (currently `stave-local-mcp`). These are not loaded via ToolSearch; their tools
  appear directly.
- **Codex plugins** come from marketplaces, not a settings.json MCP block.
- Runtime config (`config.toml`, `.claude.json`, marketplace caches) is **not**
  source-of-truth policy — never hand-edit it to "install" a connector.

## Inputs

- the external system the task touches
- whether you are on Claude or Codex (different inventories)
- the specific action (read vs. mutate; mutations may need approval)

## Inventory (as observed; verify at runtime with ToolSearch / config)

### Claude

- Local MCP: `stave-local-mcp` (Stave workspace, tasks, notes, lens browser tools).
- Hosted connectors (deferred, via ToolSearch): Atlassian, Slack, GitHub, Gmail,
  Google Drive/Calendar/Workspace, BigQuery, Figma, Sentry, Vercel, Cloudflare,
  Miro, Docusign, Greenhouse, and others surfaced per session.
- Marketplace `claude-plugins-official`: asana, context7, discord, firebase,
  github, gitlab, greptile, imessage, laravel-boost, linear, playwright, serena,
  telegram, terraform.

### Codex

- Marketplaces + plugins (enabled): `openai-curated` (slack, github,
  atlassian-rovo); `openai-bundled` (browser, computer-use, sites);
  `openai-primary-runtime` (documents, pdf, spreadsheets, presentations).

## Steps

1. Identify the system the task needs.
2. **Claude**: search for the tool with `ToolSearch` (e.g. `"+slack send"`,
   `"github pull request"`). If it is a connecting server, ToolSearch waits for it.
   Load the schema, then call. For local Stave actions, use `mcp__stave-local-mcp__*`
   directly.
3. **Codex**: use the corresponding plugin from the marketplaces above.
4. For mutations (posting, committing, creating issues), expect an approval step;
   on Codex the guardian subagent may review.
5. If neither agent has the connector, say so and propose the closest available
   path (e.g. `gh` CLI instead of a GitHub connector) — only after searching.

## Anti-patterns

- Declaring a connector unavailable without running `ToolSearch` first.
- Hand-wiring hosted connectors into `settings.json` `mcpServers`.
- Editing runtime caches/config to change connector state.
- Assuming the same connector name/shape across Claude and Codex.

## Expected artifacts

- the external action performed via the right connector/plugin, with approval
  where required.

## Verification / rollback

- Confirm the loaded tool is the intended one (name + schema) before a mutation.
- For reversible mutations, note how to undo (delete the comment/issue/branch) in
  the task record.
