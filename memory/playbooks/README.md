# Playbooks

Repeatable workflows for work that spans tools, systems, or agents.

## Active Playbooks

- [github-pr-review-and-follow-up.md](github-pr-review-and-follow-up.md)
- [slack-thread-to-task-and-jira-setup.md](slack-thread-to-task-and-jira-setup.md)
- [repo-bootstrap-and-handoff-hygiene.md](repo-bootstrap-and-handoff-hygiene.md)
- [harness-change-rollout-and-validation.md](harness-change-rollout-and-validation.md)
- [eval-run-scoring-and-scorecard-update.md](eval-run-scoring-and-scorecard-update.md)
- [stave-task-resume-and-local-execution-bridge.md](stave-task-resume-and-local-execution-bridge.md)
- [figma-design-to-implementation-and-visual-verification.md](figma-design-to-implementation-and-visual-verification.md)

## Next Candidates

- Connector-heavy GitHub or Slack validation run

## Playbook Standard

Each playbook should define:

- trigger
- inputs
- required tools or connectors
- ordered steps
- expected artifacts
- verification or rollback notes

## Rules

- Prefer linking to an existing skill or script instead of duplicating it.
- Capture only workflows that have already proven useful in real work.
- Keep the steps agent-neutral when possible so Claude and Codex can share them.
