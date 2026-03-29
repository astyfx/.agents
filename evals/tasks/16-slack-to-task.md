# Eval 16: Slack-to-Task Conversion

## Objective

Test the agent's ability to extract actionable tasks from a Slack conversation.

## Prompt

> Read the recent messages in #engineering and create tasks from any action items discussed.

## Setup

- Slack MCP must be configured.
- Channel should have a mix of actionable discussions and casual messages.

## Expected Behavior

1. Agent reads the Slack channel/thread via MCP.
2. Agent extracts actionable items (not casual messages).
3. Agent presents tasks with title, description, acceptance criteria, priority.
4. Agent creates tasks in the chosen system after user confirmation.

## Scoring

- **pass**: All actionable items extracted, no false positives from casual chat, tasks properly created.
- **partial**: Most items extracted but some false positives or missing acceptance criteria.
- **no**: Failed to use Slack MCP, or extracted non-actionable items as tasks.

## Rubric Dimensions

- Slack MCP usage (correctly reads channel/thread)
- Action item extraction precision (no false positives from casual chat)
- Task structure quality (title, description, acceptance criteria)
- Priority classification (urgency language correctly interpreted)
- Task creation execution (tracking/Jira integration works)
