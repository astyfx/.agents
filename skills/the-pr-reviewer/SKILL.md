---
name: the-pr-reviewer
description: Automated pull request review — fetches PR diff, runs 6-axis review, posts findings as GitHub PR comments. Use when the user says "PR 리뷰해줘", "review PR #123", "이 PR 봐줘", or when automating PR review workflows. Builds on the-code-reviewer rubric with GitHub integration.
compatible-tools: [claude, codex]
category: review
test-prompts:
  - "PR 리뷰해줘"
  - "review PR #123"
  - "이 PR 자동 리뷰"
  - "check this pull request"
---

# The PR Reviewer

Automated pull request review with GitHub integration.
Fetches the PR diff, applies 6-axis code review, and posts results as PR comments.

## Use This Skill When

- The user asks to review a specific PR by number or URL.
- The user wants automated PR review posted to GitHub.
- A CI workflow or trigger requests PR review.

## Do Not Use This Skill When

- The user wants a review of local files (use the-code-reviewer instead).
- The PR is a draft and the user did not explicitly ask for review.

## Prerequisites

- GitHub access: `gh` CLI authenticated, or GitHub MCP server configured.
- Repository context: must be inside a git repo or provide owner/repo.

## Workflow

### Step 1 — Fetch PR Context

Gather all necessary context before reviewing:

1. Get PR metadata:
   ```
   gh pr view <number> --json title,body,baseRefName,headRefName,files,additions,deletions,author
   ```

2. Get the full diff:
   ```
   gh pr diff <number>
   ```

3. Get PR comments (existing review threads):
   ```
   gh api repos/{owner}/{repo}/pulls/{number}/comments
   ```

4. If the PR description references issues, read those too:
   ```
   gh issue view <issue-number>
   ```

### Step 2 — Analyze Scope

Before reviewing, assess the PR:

- **Size**: small (< 100 lines), medium (100-500), large (> 500)
- **Type**: feature, fix, refactor, chore, docs
- **Risk areas**: security-sensitive files, public APIs, database migrations, config changes
- **Changed file count**: if > 10 files, flag for potential scope creep

### Step 3 — Apply 6-Axis Review

Apply the same rubric as the-code-reviewer across all changed files:

1. **Correctness** — logic errors, missing error handling, race conditions
2. **Security** — secrets, injection, auth gaps, data exposure
3. **Performance** — N+1 queries, unnecessary re-renders, bundle bloat
4. **Conventions** — naming, commit messages, code style, project patterns
5. **Architecture** — layer leakage, coupling, missing abstractions
6. **Accessibility** — ARIA, keyboard nav, contrast (frontend changes only)

Additional PR-specific checks:
- **PR hygiene**: description completeness, test evidence, breaking change flags
- **Scope**: does the PR do one thing? Flag unrelated changes
- **Reversibility**: can this be rolled back safely?

### Step 4 — Produce Review

Format findings by severity:

```markdown
## PR Review: #{number} — {title}

**Scope**: {file_count} files, +{additions}/-{deletions}
**Type**: {type}  |  **Risk**: {low/medium/high}

### [CRITICAL] Must fix before merge
- **{axis}** `{file}:{line}` — {description}

### [SUGGESTION] Worth addressing
- **{axis}** `{file}:{line}` — {description}

### [NIT] Style/preference
- **{axis}** `{file}:{line}` — {description}

### Summary
{1-2 sentence overall assessment}

**Verdict**: ✅ Approve / 🔄 Request Changes / 💬 Comment Only
```

### Step 5 — Post to GitHub

Based on findings:

- **No CRITICAL findings**: approve the PR
  ```
  gh pr review <number> --approve --body "<review>"
  ```

- **CRITICAL findings exist**: request changes
  ```
  gh pr review <number> --request-changes --body "<review>"
  ```

- **Only SUGGESTION/NIT**: comment without blocking
  ```
  gh pr review <number> --comment --body "<review>"
  ```

For specific line comments on CRITICAL issues:
```
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  -f body="<comment>" -f path="<file>" -F line=<line> -f commit_id="<sha>"
```

### Step 6 — Report to User

After posting, show:
- Verdict (approve / request changes / comment)
- Count of findings by severity
- Link to the PR review

## Handling Large PRs (> 500 lines)

For large PRs:
1. Review in batches by file group (API, UI, tests, config)
2. Prioritize security-sensitive and public API files
3. Flag overall scope concern as a SUGGESTION
4. Consider spawning researcher subagent for context if > 15 files

## Done Definition

The review is complete when:
- All changed files have been reviewed across applicable axes.
- Findings are posted to GitHub with correct verdict.
- User is shown the summary and PR link.
