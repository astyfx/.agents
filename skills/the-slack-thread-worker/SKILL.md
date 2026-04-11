---
name: the-slack-thread-worker
description: |
  Read a Slack thread and turn it into the right level of work: extract tasks,
  prepare Jira and linked resources, or execute the change through code and PR.
  Use when the user says "슬랙 쓰레드로 작업해", "슬랙 보고 이슈 만들어",
  "이 스레드 정리해서 태스크로 만들어", "이 스레드 보고 수정하고 PR 올려",
  "work this Slack thread", or otherwise expects planning, setup, or end-to-end
  execution from a Slack discussion.
compatible-tools: [claude, codex]
category: workflow
test-prompts:
  - "이 슬랙 스레드로 작업해"
  - "슬랙 보고 이슈 만들어줘"
  - "이 스레드 정리해서 태스크로 만들어줘"
  - "슬랙쓰레드 주면서 작업해. Jira 만들고 PR까지"
  - "work this Slack thread and open a PR"
  - "read this Slack thread, implement it, and link Jira in the PR"
---

# The Slack Thread Worker

Turn a Slack discussion into the right downstream artifact:
task list, Jira-ready work item, or full code-and-PR execution.

## Use This Skill When

- The user gives a Slack thread and wants real work to come out of it.
- The user wants task extraction, Jira setup, linked-resource prep, or end-to-end execution.
- The user wants the resulting task, Jira issue, or PR to preserve Slack context.

## Do Not Use This Skill When

- The user only wants a Slack summary or reply draft.
- The user already gave a fully specified task and does not want Slack-driven setup.
- The work is planning-only and does not need task setup, Jira prep, or execution.

## Required Inputs

- A Slack thread URL, or enough channel and timestamp information to locate one.
- If execution is expected, an active repo or workspace to modify.

## Operating Modes

Pick the narrowest mode that satisfies the request.

- `extract`
  - convert the thread into structured tasks or execution-memory work items
- `prepare`
  - create or draft a Jira issue, collect linked resources, and register context
- `execute`
  - do the preparation work above, then implement, verify, commit, and open a PR

If the user does not specify the mode, infer it from the request:

- "정리", "태스크 만들어", "action items" -> `extract`
- "이슈 만들어", "작업 세팅", "링크 다 연결" -> `prepare`
- "작업해", "수정하고 PR", "implement from this thread" -> `execute`

## Capability Checks

Before doing any work, check what the current environment actually supports.

- **Slack read tools** must exist for thread access.
- **GitHub tools** or authenticated `gh` must exist for PR creation.
- **Atlassian/Jira write tools** may not exist.

If Jira creation tools are missing:

- say that immediately
- continue with `extract` or `execute` if the user still wants it
- draft the Jira-ready summary, description, and acceptance criteria so the missing step is small
- if the user already has a Jira key, use that key in the PR linkage instead of blocking

Do not pretend Jira creation succeeded when the environment cannot do it.

## Workflow

### Step 1 — Read the Slack Thread

- Parse the Slack URL into `channel_id` and `thread_ts`.
- Read the thread with Slack tools.
- Extract:
  - requested change
  - whether the request is extraction, setup, or execution
  - exact conditions or reproduction notes
  - owners, reviewers, urgency, and any deadlines
  - linked resources such as Jira, Confluence, Figma, GitHub PRs, or docs

Lead with the latest decision in the thread, not the oldest message.

### Step 2 — Normalize the Work Item

Turn the thread into an execution brief:

- one-line problem statement
- affected product area
- expected behavior
- non-goals
- validation notes
- recommended mode: `extract`, `prepare`, or `execute`

If the request is still ambiguous after reading the thread, ask a targeted clarification before editing code.

### Step 3 — Create Tasks or Prepare Jira Context

If the mode is `extract`:

- produce a reviewed task list
- create local execution-memory work items when the user wants local durable tracking
- stop before Jira or repo changes unless the user explicitly asks for more

If the mode is `prepare` or `execute`:

- choose the likely Jira project when Jira tools are available
- create the Jira issue or prepare a Jira-ready draft when tools are unavailable
- include the Slack thread, acceptance criteria, and detected resources

### Step 4 — Link Resource Context

- link or record related Confluence, Figma, GitHub, and Slack resources
- if the current environment supports it and the user wants it, register the same resources in the active Stave workspace
- if remote linking is unavailable, fall back to structured description text and say so explicitly

### Step 5 — Implement in the Repo

Only do this in `execute` mode.

- read repo-local guidance first: `AGENTS.md`, `README`, and nearby conventions
- find the smallest safe code change that satisfies the Slack request
- preserve existing patterns unless a functional change requires otherwise
- if the repo has formatting rules, run the formatter after edits
- do not run lint or type checks by default when the repo policy explicitly says not to

Prefer minimal behavior changes over opportunistic refactors.

### Step 6 — Verify the Change

Use the lightest verification that matches the repo rules and the risk level.

- If the user asked for tests, run them.
- If repo policy says not to auto-run lint or type checks, do not run them unless necessary.
- At minimum, inspect the diff for correctness and mention what was or was not verified.

### Step 7 — Commit

- Use a Conventional Commits message only.
- Keep the commit scoped to the actual change.
- Do not mix unrelated cleanup into the same commit.

### Step 8 — Open the PR

When creating the PR:

- summarize the user-visible behavior change
- reference the Slack thread URL
- include the Jira key if available
- include validation notes
- mention limitations or unverified areas honestly

If the environment supports GitHub PR creation but not Jira creation, still open the PR and include the Jira-ready draft or the missing Jira note in the PR body.

## PR Linking Rules

When a Jira key exists:

- include the key in the PR title or body in the format the host recognizes
- include a dedicated `Jira` section in the PR body
- include the Slack thread under a `Context` or `References` section

When a Jira key does not exist:

- do not fabricate one
- explicitly state that Jira creation was unavailable in this environment
- provide the prepared Jira issue content in the final user report

## Final Report

Return a short execution summary with:

- chosen mode
- what the Slack thread requested
- whether local task artifacts were created
- whether Jira was created or only drafted
- what linked resources were recorded
- what code changed, if any
- what was verified, if any
- PR URL, if any
- remaining blocker, if any

## Done Definition

This workflow is done when:

- the Slack thread has been read and reduced to a concrete task
- the chosen mode has been completed fully:
  - `extract`: reviewed tasks or local execution-memory work items exist
  - `prepare`: Jira issue exists or a Jira-ready draft exists, with resource context
  - `execute`: code change, verification, commit, and PR are done
- Jira is either created and linked, or a precise Jira-ready draft is returned when tooling is unavailable

## Supersedes

This skill now absorbs the older split between task extraction, work prep, and
Slack-driven end-to-end execution.
