# Learnings

Generic technical knowledge accumulated across projects. Transferable patterns, gotchas, and heuristics.

## What Belongs Here

This is a **technical knowledge base**, not a project diary.

✅ Add: patterns and anti-patterns that apply across multiple projects
✅ Add: gotchas and edge cases in libraries or languages
✅ Add: architecture heuristics that have proven correct
✅ Add: debugging approaches that resolved recurring issue classes

❌ Do not add: facts specific to one project ("stave uses X")
❌ Do not add: session logs or what was done ("today we fixed Y")
❌ Do not add: decisions tied to a specific codebase's constraints

Project-specific facts belong in `./agent-memory.md` at the project root (if the user wants them).

## Format

Each file: bullet-point entries, one insight per bullet.
Keep each entry under 2 lines. Prefer concrete over abstract.

Example:
- `response.json()` in Fetch API returns a Promise — always await it, even if TypeScript does not complain.
- NOT: "be careful with async functions" (too vague)

## How to Add

When completing a task, distill 1-3 learnings and add them to the relevant file.
Only add things that would have saved time if known at the start.
Do not add things already obvious from official documentation.

## Files

| File | Contents |
|---|---|
| react-patterns.md | RSC, hooks, rendering, state management patterns |
| typescript.md | Type system gotchas, utility types, error patterns |
| testing.md | Vitest/pytest/cargo test patterns, mocking strategies |
| architecture.md | Layering rules, boundary patterns, abstraction heuristics |
| build-tooling.md | Bun/Vite/webpack patterns, bundle gotchas, CI |
| api-design.md | REST conventions, error shapes, auth patterns |
| debugging.md | Common error patterns and their root causes |
