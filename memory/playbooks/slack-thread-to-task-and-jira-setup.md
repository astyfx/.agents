# Slack Thread to Task, Jira, and Execution

## Trigger

Use when a Slack discussion needs to become tracked work, Jira context, or
full implementation and PR follow-through.

## Inputs

- Slack thread URL, channel plus timestamp, or search terms
- target outcome: task extraction only, Jira/resource prep, or end-to-end execution
- optional Stave workspace context if Information panel registration is needed

## Required Tools

- Slack read tools for channel and thread context
- Atlassian tools for Jira and Confluence when available
- GitHub tools or `gh` when execution mode should open a PR
- `the-slack-thread-worker`

## Steps

1. Resolve the Slack source and read the full thread before proposing work.
2. Extract the operational payload:
   - title
   - requested outcome
   - owners
   - deadlines
   - linked resources such as Confluence, Figma, and GitHub
3. Choose the narrowest mode that fits:
   - `extract` for a task list or local execution-memory work items
   - `prepare` for one formal Jira issue with linked resources
   - `execute` when the user expects code changes and a PR from the same thread
4. Choose the Jira project from team, domain, or prior context when Jira work
   is needed. Ask only if multiple plausible projects remain.
5. Create the task artifact, Jira issue, or Jira-ready draft with a structured
   description that preserves the Slack context.
6. Link the originating Slack thread and any related Confluence, Figma, or
   GitHub resources.
7. If the mode is `execute`, implement the smallest safe code change, verify
   it honestly, and open the PR with Slack and Jira context attached when
   available.
8. If the current environment supports it and the user wants it, register the
   same links in the Stave Information panel.
9. Return the created artifacts, linked resources, and any open questions that
   still block execution.

## Expected Artifacts

- Jira issue, Jira-ready draft, or structured task list
- preserved source thread link
- linked design, spec, and PR resources
- optional implementation patch and PR
- optional Stave Information panel updates

## Verification

- confirm the created issue reflects the actual Slack decision, not just the
  first message
- make sure action items and open questions are separated clearly
- if code was changed, verify the final PR matches the current Slack ask rather
  than an older thread state
- verify that every linked resource is reachable before reporting completion

## Rollback Notes

- if project choice or issue type is ambiguous, stop and ask instead of filing
  into the wrong queue
- if connectors cannot create remote links, fall back to issue description or
  comments and say so explicitly
