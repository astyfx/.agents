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
SESSION_DIR="tracking/sessions/${TODAY}_${SESSION_SLUG}"
TASK_DIR="${SESSION_DIR}/features/${FEATURE_SLUG}/tasks/${TASK_SLUG}"

mkdir -p "${TASK_DIR}"

# plan.md
cat > "${TASK_DIR}/plan.md" <<EOF
# Plan

## Scope

TODO: describe what this task covers.

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

Owner: jacob.kim
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
EOF

echo "Created tracking task at: ${TASK_DIR}"
echo ""
echo "Files created:"
ls "${TASK_DIR}/"
