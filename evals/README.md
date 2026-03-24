# Evals

Benchmark tasks for measuring agent (Claude and Codex) performance on representative work.

## Purpose

- Validate that harness changes (new skills, hooks, subagents) actually improve outcomes.
- Provide an honest comparison of how Claude and Codex each handle the same work.
- Build an evidence base for task routing decisions.

## How to Run

1. Pick a task from `tasks/`.
2. Open it and read the Input Prompt section.
3. Give that exact prompt to the agent you are testing (Claude or Codex).
4. After the agent finishes, score the result using the rubric below.
5. Save results to `results/YYYY-MM-DD_<agent>_<task-id>.md`.

## Scoring Rubric

Each result file records:

| Field | Values | Notes |
|---|---|---|
| `task_id` | 01–10 | From task filename |
| `agent` | claude, codex | Which agent ran the task |
| `pass` | yes / partial / no | Did it satisfy the success criteria? |
| `rework_count` | integer | How many user corrections were needed |
| `verification_quality` | yes / partial / no | Did the agent self-verify its work? |
| `policy_compliance` | yes / partial / no | Conventional commits, no secrets, tracking created if needed |
| `time_minutes` | integer | Approx wall-clock minutes |
| `notes` | freeform | Anything notable about the run |

## Result File Template

Create one file per run at `results/YYYY-MM-DD_<agent>_<task-id>.md`:

```markdown
# Result — Task <id> — <agent> — <date>

task_id:
agent:
pass:
rework_count:
verification_quality:
policy_compliance:
time_minutes:
notes: |
  ...
```

## Interpreting Results

- `rework_count: 0` with `pass: yes` = ideal run.
- `verification_quality: no` = agent completed without self-checking — this is a failure mode.
- `policy_compliance: no` = harness enforcement is not working; check hooks and AGENTS.md rules.

## When to Re-run Evals

- After adding a new skill
- After modifying hooks or AGENTS.md
- After upgrading agent version
- When you notice repeated failure patterns in real work
