#!/usr/bin/env bash
# new-tracked-task.sh — scaffold a new tracking session/feature/task
# Usage: bash scripts/new-tracked-task.sh <session-slug> <feature-slug> <task-slug>
# Example: bash scripts/new-tracked-task.sh auth-refactor login-flow implement-oauth

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <session-slug> <feature-slug> <task-slug>"
  echo "Example: $0 auth-refactor login-flow implement-oauth"
  exit 1
fi

SESSION_SLUG="$1"
FEATURE_SLUG="$2"
TASK_SLUG="$3"
TODAY="$(date +%Y-%m-%d)"
OWNER="${HARNESS_OWNER:-${USER:-unknown}}"
SESSION_DIR="tracking/sessions/${TODAY}_${SESSION_SLUG}"
TASK_DIR="${SESSION_DIR}/features/${FEATURE_SLUG}/tasks/${TASK_SLUG}"
PROGRESS_FILE="claude-progress.txt"

mkdir -p "${TASK_DIR}"

# plan.md
cat > "${TASK_DIR}/plan.md" <<EOF
# Plan

## Scope

TODO: describe what this task covers.

## Task Path

${TASK_DIR}

## Assumptions

TODO: list assumptions made before starting.

## Decomposition

TODO: break work into explicit sub-tasks.

## Done Criteria

TODO: concrete, observable acceptance criteria.
EOF

# phases.md
cat > "${TASK_DIR}/phases.md" <<EOF
# Phases

## Current Phase

1. Discover

## Phase Status

1. Discover: in_progress
2. Plan: not_started
3. Implement: not_started
4. Verify: not_started
5. Handoff: not_started
EOF

# tasks.md
cat > "${TASK_DIR}/tasks.md" <<EOF
# Tasks

- [ ] TODO: first task

Owner: ${OWNER}
EOF

# execution-log.md
cat > "${TASK_DIR}/execution-log.md" <<EOF
# Execution Log

## $(date +%Y-%m-%d)

Session started.
EOF

# verification.md
cat > "${TASK_DIR}/verification.md" <<EOF
# Verification

## Tests and Checks

TODO: list tests run and their results.
EOF

# handoff.md
cat > "${TASK_DIR}/handoff.md" <<EOF
# Handoff

## Summary

TODO: brief summary of what was done.

## Open Issues

TODO: anything unresolved.

## Next Actions

TODO: what to do next.

## Auto Snapshot

TODO: maintained by stop-time automation when available.
EOF

python3 - <<'PYEOF' "${PROGRESS_FILE}" "${TASK_DIR}"
import re
import sys
from pathlib import Path

progress_file = Path(sys.argv[1])
task_dir = sys.argv[2]

template = f"""# Progress

## Task
TODO: describe the overall goal.

## Tracking Task Path
{task_dir}

## Status
Discover

## Last Completed Step
Task scaffold created.

## Next Action
Fill in tracking/{task_dir.split('tracking/', 1)[-1]}/plan.md and start work.

## Open Questions
None yet.

## Changed Files
None yet.

## Notes
Created by scripts/new-tracked-task.sh
"""

if not progress_file.exists():
    progress_file.write_text(template, encoding="utf-8")
    sys.exit(0)

text = progress_file.read_text(encoding="utf-8")
pattern = re.compile(r"^## Tracking Task Path\s*\n.*?(?=^## |\Z)", flags=re.MULTILINE | re.DOTALL)
replacement = f"## Tracking Task Path\n{task_dir}\n"
if pattern.search(text):
    updated = pattern.sub(replacement, text)
else:
    updated = text.rstrip() + "\n\n" + replacement
progress_file.write_text(updated, encoding="utf-8")
PYEOF

echo "Created tracking task at: ${TASK_DIR}"
echo ""
echo "Files created:"
ls "${TASK_DIR}/"
echo ""
echo "Progress file linked to task path: ${PROGRESS_FILE}"
