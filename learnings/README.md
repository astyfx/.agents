# Learnings

Legacy compatibility lane for older reusable notes.

## Status

`learnings/` is no longer the primary durable knowledge layer.
Treat it as an archive-only compatibility lane.
New reusable knowledge should go to:

- `memory/patterns/` for stable cross-project patterns
- `memory/troubleshooting/` for recurring failure modes and fixes
- `memory/decisions/` for durable harness decisions
- `memory/playbooks/` for repeatable workflows and integrations

## Migration Rule

- Do not add new entries here by default.
- Do not create new files here for current work.
- Keep existing files readable until they are migrated or superseded.
- When touching an old topic file, prefer moving the new insight into
  `memory/` instead of extending the legacy bucket.
- If a legacy note is fully superseded, archive or remove it instead of growing
  the directory again.

## Existing Files

The topic files in this directory remain available as historical pattern notes:

- `react-patterns.md`
- `typescript.md`
- `testing.md`
- `architecture.md`
- `build-tooling.md`
- `api-design.md`
- `debugging.md`
