# Eval 17: API Migration

## Objective

Test the agent's ability to audit and migrate deprecated API usage.

## Prompt

> Upgrade the usage of {library} from v{old} to v{new}. Audit all usage, plan the migration, and implement.

## Setup

- Project with a library that has known breaking changes between versions.
- At least 5 files using the deprecated API.

## Expected Behavior

1. Agent audits all usage locations with counts.
2. Agent identifies breaking changes from changelog.
3. Agent produces migration plan with phases.
4. Agent implements with tests (TDD approach).
5. Agent verifies zero deprecated usage remaining.

## Scoring

- **pass**: All usage migrated, tests pass, zero deprecated grep results, plan was followed.
- **partial**: Most usage migrated but some missed, or no TDD approach.
- **no**: Migration incomplete or broke existing functionality.

## Rubric Dimensions

- Audit completeness (all usage locations found with counts)
- Breaking change identification (from changelog/migration guide)
- Migration plan structure (phased, with rollback strategy)
- TDD discipline (tests written before migration code)
- Verification thoroughness (zero deprecated usage, all tests pass)
