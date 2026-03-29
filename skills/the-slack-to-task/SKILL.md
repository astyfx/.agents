---
name: the-slack-to-task
description: Extract actionable tasks from Slack conversations and create tracked work items. Use when the user says "슬랙에서 태스크 만들어줘", "create tasks from Slack", "이 슬랙 스레드 정리해줘", or when converting Slack discussions into structured work items with optional Jira integration.
compatible-tools: [claude]
category: workflow
test-prompts:
  - "슬랙에서 태스크 만들어줘"
  - "create tasks from this Slack thread"
  - "이 슬랙 스레드 정리해줘"
  - "convert Slack discussion to tasks"
---

# The Slack-to-Task Skill

Convert Slack conversations into structured, tracked work items.

## Use This Skill When

- The user wants to extract tasks from a Slack channel or thread.
- The user says "슬랙에서 태스크", "create tasks from Slack", "스레드 정리".
- A decision was made in Slack and needs to become tracked work.

## Do Not Use This Skill When

- The user wants to send a Slack message (just use Slack MCP directly).
- The task is already clearly defined (just create it directly).

## Prerequisites

- **Slack MCP**: configured for reading channels and threads.
- **Atlassian MCP** (optional): for creating Jira issues.
- **tracking system**: `scripts/new-tracked-task.sh` for local tracking.

## Workflow

### Step 1 — Read Slack Content

Use Slack MCP to fetch the conversation:

1. **Channel messages**: `slack_read_channel` for recent channel discussion.
2. **Thread**: `slack_read_thread` for a specific thread.
3. **Search**: `slack_search_public` to find relevant discussions by keyword.

### Step 2 — Extract Tasks

Parse the conversation to identify:

```
## Extracted Tasks

### Task 1: {title}
- **Source**: #{channel} / thread by @{user} on {date}
- **Description**: {what needs to be done}
- **Acceptance criteria**:
  - [ ] {criterion 1}
  - [ ] {criterion 2}
- **Assignee**: {mentioned or inferred}
- **Priority**: {P0/P1/P2, inferred from urgency language}
- **Context**: {relevant quotes or links from the thread}

### Task 2: {title}
...
```

Extraction rules:
- Look for action verbs: "we need to", "someone should", "can you", "let's"
- Look for decisions: "let's go with", "agreed", "decision:"
- Look for deadlines: "by Friday", "before release", "ASAP"
- Ignore off-topic messages, reactions, and social chatter.

### Step 3 — Review with User

Present extracted tasks and ask the user to:
- Confirm, modify, or remove tasks.
- Assign priority and ownership.
- Choose where to create them (local tracking, Jira, or both).

### Step 4 — Create Work Items

Based on user choice:

**Local tracking**:
```bash
scripts/new-tracked-task.sh <session> <feature> <task-slug>
```
Then populate `plan.md` with the extracted task details.

**Jira** (if Atlassian MCP available):
- Create issue with title, description, acceptance criteria.
- Set priority, assignee, and labels.
- Link back to Slack thread in the description.

**Both**: create local tracking AND Jira issue, cross-reference them.

### Step 5 — Confirm in Slack

Optionally post a confirmation message back to the Slack thread:
- List created tasks with links (Jira URLs or local paths).
- Tag relevant people.

## Output Format

```
## Slack → Task Conversion

### Source
- Channel: #{channel}
- Thread: {link or timestamp}
- Participants: @{user1}, @{user2}

### Created Tasks
| # | Title | Priority | Assignee | Created in |
|---|---|---|---|---|
| 1 | {title} | P1 | @{user} | Jira: PROJ-123 |
| 2 | {title} | P2 | @{user} | Local tracking |

### Slack Confirmation
- Posted to #{channel}: {yes/no}
```

## Done Definition

The conversion is complete when:
- All actionable items from the conversation are extracted.
- User has reviewed and confirmed the task list.
- Tasks are created in the chosen system (tracking, Jira, or both).
- Optionally, confirmation posted back to Slack.
