# Eval 11: Automated PR Review

## Objective

Test the agent's ability to fetch a PR, apply structured review, and post findings to GitHub.

## Prompt

> Review PR #{number} in this repo. Post your findings as a GitHub review comment.

## Setup

- Must be in a git repo with `gh` CLI authenticated.
- A PR must exist with known issues planted (at least 1 CRITICAL, 2 SUGGESTION, 1 NIT).

## Expected Behavior

1. Agent fetches PR metadata and diff via `gh` CLI.
2. Agent reviews all changed files across 6 axes.
3. Agent identifies the planted issues at correct severity levels.
4. Agent posts review to GitHub with correct verdict (request-changes for CRITICAL).
5. Agent reports summary to user with PR link.

## Scoring

- **pass**: All planted issues found, correct verdict posted, review visible on GitHub.
- **partial**: Most issues found but wrong verdict, or review not posted to GitHub.
- **no**: Missed CRITICAL issues, or did not post to GitHub at all.

## Rubric Dimensions

- Issue detection accuracy (planted bugs found)
- Severity classification (CRITICAL vs SUGGESTION vs NIT)
- GitHub integration (review posted correctly)
- PR-specific checks (scope, hygiene, reversibility)
- Summary quality (actionable, concise)
