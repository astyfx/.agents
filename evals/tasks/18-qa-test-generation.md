# Eval 18: QA Test Generation

## Objective

Test the agent's ability to generate a comprehensive test plan from a feature spec or PR.

## Prompt

> Generate a test plan for this PR. Cover happy paths, failure paths, edge cases, and regression scenarios.

## Setup

- A PR or feature spec with multiple code paths (e.g., form validation, API endpoint with auth).
- The feature should have at least 3 distinct behavioral branches.

## Expected Behavior

1. Agent reads the code/spec and identifies all behavioral branches.
2. Agent produces a test matrix with happy path, failure path, and edge case scenarios.
3. Agent identifies regression risks from the change.
4. Agent classifies scenarios by priority (P0/P1/P2).
5. Agent produces a structured test plan (not test code).

## Scoring

- **pass**: All behavioral branches covered, priorities assigned, regression risks identified, structured output.
- **partial**: Most branches covered but missing edge cases or no priority classification.
- **no**: Shallow coverage, missed major code paths, or produced test code instead of a plan.

## Rubric Dimensions

- Behavioral branch coverage (all paths identified)
- Edge case identification (boundary conditions, empty inputs, concurrent access)
- Regression risk analysis (existing behavior that might break)
- Priority classification accuracy (P0 for critical paths)
- Test plan structure (matrix format, actionable for implementer)
