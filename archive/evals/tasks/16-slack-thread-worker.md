# Eval 16: Slack Thread Worker (Extract Mode)

## Objective

Test the agent's ability to read Slack discussion context and turn it into
structured work items in extract mode.

## Prompt

> Read the recent messages in #engineering and create structured work items from any action items discussed.

## Setup

- Slack MCP must be configured.
- Channel should have a mix of actionable discussions and casual messages.

## Expected Behavior

1. Agent reads the Slack channel or thread via MCP.
2. Agent extracts actionable items without turning casual discussion into work.
3. Agent presents structured work items with title, description, acceptance criteria, and priority.
4. After user confirmation, agent creates local execution-memory work items or remote tasks in the chosen system.

## Scoring

- **pass**: All actionable items extracted, no false positives from casual chat, and the confirmed work items are created in the chosen destination.
- **partial**: Most items extracted but some false positives or missing acceptance criteria.
- **no**: Failed to use Slack MCP, or extracted non-actionable items as work.

## Rubric Dimensions

- Slack MCP usage (correctly reads channel/thread)
- Action item extraction precision (no false positives from casual chat)
- Work-item structure quality (title, description, acceptance criteria)
- Priority classification (urgency language correctly interpreted)
- Work-item creation execution (execution-memory or Jira/task integration works)
