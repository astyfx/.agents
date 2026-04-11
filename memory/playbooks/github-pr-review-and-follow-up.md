# GitHub PR Review and Follow-Up Loop

## Trigger

Use when a pull request needs triage, review, follow-up fixes, or comment
resolution.

## Inputs

- repository and PR number
- review goal: summarize, review for bugs, address comments, or fix CI
- local checkout or worktree if code changes are expected

## Required Tools

- GitHub plugin tools for PR metadata, diffs, comments, and reviews
- `github:github` for general PR orientation
- `github:gh-address-comments` when resolving review feedback
- `github:gh-fix-ci` when the main blocker is failing Actions checks
- local shell for targeted verification

## Steps

1. Fetch PR metadata, changed files, and existing review context.
2. Classify the request:
   - summary only
   - code review
   - address review feedback
   - fix CI failures
3. Route to the narrowest workflow that fits:
   - use `the-pr-reviewer` or a code-review mindset for bug finding
   - use `github:gh-address-comments` for unresolved review threads
   - use `github:gh-fix-ci` when Actions failures are the main issue
4. If editing code, sync local repo context before changing files.
5. Implement the smallest defensible fix set and verify locally.
6. Report back in the PR surface that matches the work:
   - review comment
   - top-level summary comment
   - updated branch and draft PR status
7. Update `work-handoff.md` or tracked `handoff.md` if the PR work will
   continue in another session.

## Expected Artifacts

- PR summary or review findings
- local patch set when code changes are required
- verification notes with commands run and residual risks
- updated handoff state for multi-session PR work

## Verification

- confirm the reviewed files match the user's request
- run the smallest relevant local checks before reporting success
- if CI is involved, note whether the fix was verified locally, in GitHub, or
  both

## Rollback Notes

- do not resolve threads or claim success without reading the actual diff and
  comments
- if local changes conflict with unknown workspace edits, pause instead of
  force-reverting
