# Eval 13: Codebase Onboarding

## Objective

Test the agent's ability to map an unfamiliar codebase and produce an actionable onboarding guide.

## Prompt

> I just joined this project. Map the codebase and produce an onboarding guide for me.

## Setup

- Must be in a real project with at least 20 files across 5+ directories.
- Agent has no prior context about this project.

## Expected Behavior

1. Agent identifies the project type, stack, and build system.
2. Agent produces a directory map with purpose annotations.
3. Agent generates a module dependency diagram (Mermaid).
4. Agent traces at least 2 request flows.
5. Agent identifies key patterns and risk areas.
6. Agent produces an onboarding guide with "start here" instructions.

## Scoring

- **pass**: All 6 sections produced, diagrams are accurate, guide is actionable.
- **partial**: Some sections missing or diagrams have inaccuracies, but guide is useful.
- **no**: Shallow analysis, no diagrams, or guide is not actionable.

## Rubric Dimensions

- Project fingerprint accuracy
- Directory map completeness
- Dependency diagram correctness (verified by manual check)
- Request flow trace accuracy
- Risk area identification
- Onboarding guide actionability
