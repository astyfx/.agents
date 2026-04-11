# Evals

Benchmark tasks for measuring agent (Claude and Codex) performance on representative work.

## Purpose

- Validate that harness changes (new skills, hooks, subagents) actually improve outcomes.
- Provide an honest comparison of how Claude and Codex each handle the same work.
- Build an evidence base for task routing decisions.
- Keep a small set of decision-linked benchmark runs instead of turning evals
  into per-task journaling.

## Default Stance

- Do not run an eval for every normal task.
- Run one when a harness change, workflow question, or routing choice needs
  evidence.
- If a run will not change a decision, it is usually not worth recording.

## How to Run

1. Pick a task from `tasks/`.
2. Open it and read the Input Prompt section.
3. Give that exact prompt to the agent you are testing (Claude or Codex).
4. Create a result file with `bash scripts/new-eval-result.sh <agent> <task-id>`.
5. After the agent finishes, score the result using the rubric below.
6. Save notes in the created result file.
7. Use `scripts/summarize-evals.py` to see the current aggregate view.

## Scoring Rubric

Each result file records:

| Field | Values | Notes |
|---|---|---|
| `task_id` | 01–10 | From task filename |
| `agent` | claude, codex | Which agent ran the task |
| `eval_type` | change_validation / workflow_baseline / routing_check / agent_comparison | Why this run exists |
| `change_under_test` | freeform | What changed, if this is validating a harness or workflow change |
| `decision_target` | freeform | What decision this run is meant to inform |
| `pass` | yes / partial / no | Did it satisfy the success criteria? |
| `rework_count` | integer | How many user corrections were needed |
| `verification_quality` | yes / partial / no | Did the agent self-verify its work? |
| `policy_compliance` | yes / partial / no | Conventional commits, no secrets, tracking created if needed |
| `time_minutes` | integer | Approx wall-clock minutes |
| `notes` | freeform | Anything notable about the run |

## Result File Template

Preferred path: `bash scripts/new-eval-result.sh <agent> <task-id>`.
This creates `results/YYYY-MM-DD_<agent>_<task-id>.md` with the template below:

```markdown
# Result — Task <id> — <agent> — <date>

task_id:
agent:
eval_type:
change_under_test:
decision_target:
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
- A result without `decision_target` is lower-value evidence; keep those rare.

## When to Re-run Evals

- After adding a new skill
- After modifying hooks or AGENTS.md
- After upgrading agent version
- When you notice repeated failure patterns in real work

## When Not to Run Evals

- Routine one-off work that will not inform a harness or routing decision
- Tasks where the result would only restate that normal delivery still works
- Cases where raw quantity would grow but the evidence base would not get sharper

## Utility Scripts

- `scripts/new-eval-result.sh` — scaffold a result file with the expected fields
- `scripts/summarize-evals.py` — summarize runs by agent, pass rate, rework,
  verification quality, policy compliance, and eval type coverage
