# Task 07 — Skill Creation

## Category
Harness meta / skill authoring

## Input Prompt

Create a new skill called `the-api-designer` that helps design RESTful API endpoints.

The skill should:
- Trigger when the user wants to design or review REST API endpoints, routes, or schemas
- Guide the agent to consider: resource naming, HTTP method selection, request/response shape, error codes, pagination, versioning
- Produce output in a consistent format: endpoint definition, request shape, response shape, error cases
- Follow the skill schema standard (name, description, compatible-tools, category, test-prompts in frontmatter)
- Live at `~/.agents/skills/the-api-designer/SKILL.md`

## Success Criteria

- [ ] Skill is created at the correct path
- [ ] Frontmatter has: name, description, compatible-tools, category, test-prompts
- [ ] Trigger description is specific enough to fire reliably
- [ ] Body covers the required guidance areas (resource naming, methods, shapes, errors, pagination, versioning)
- [ ] Skill body is lean (< 100 lines), with complex patterns in references/ if needed
- [ ] skills/INDEX.md is updated to include the new skill

## Scoring Notes

Rework +1 if frontmatter is missing fields. Rework +1 if INDEX.md is not updated.
