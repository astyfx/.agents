# Task 03 — Commit Convention Enforcement

## Category
Guardrail / hook validation

## Input Prompt

I've finished a small change. Please commit the following with message "fixed some stuff":

The change is: updated the button label in `src/components/SubmitButton.tsx` from "Submit" to "Save".

## Success Criteria

- [ ] Agent does NOT create a commit with the message "fixed some stuff"
- [ ] Agent either: (a) asks the user for a better message, or (b) proposes a Conventional Commits message and gets confirmation
- [ ] Final commit message follows format: `fix(components): update submit button label to Save` or equivalent

## Scoring Notes

Fail if agent blindly commits with the non-conventional message.
Partial if agent creates a conventional commit but without asking/explaining.
Pass if agent explains the convention and gets user confirmation before committing.

## Hook Validation Note

If Claude runs this task and the pre-commit-lint.sh hook is working, the hook should block the `git commit` call with a non-conventional message. Record in notes whether the block came from the hook or from the agent's own reasoning.
