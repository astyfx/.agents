#!/usr/bin/env bash
# new-task.sh — scaffold a new execution-memory session/feature/task
# Usage: bash scripts/new-task.sh <session-slug> <feature-slug> <task-slug> [--mode lite|expanded]
# Example: bash scripts/new-task.sh auth-refactor login-flow implement-oauth --mode expanded

set -euo pipefail

usage() {
  echo "Usage: $0 <session-slug> <feature-slug> <task-slug> [--mode lite|expanded]"
  echo "Example: $0 auth-refactor login-flow implement-oauth --mode expanded"
}

MODE="lite"
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      shift
      if [[ $# -eq 0 ]]; then
        echo "Error: --mode requires a value"
        usage
        exit 1
      fi
      MODE="$1"
      ;;
    --expanded)
      MODE="expanded"
      ;;
    --lite)
      MODE="lite"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      POSITIONAL+=("$1")
      ;;
  esac
  shift
done

if [[ ${#POSITIONAL[@]} -ne 3 ]]; then
  usage
  exit 1
fi

case "${MODE}" in
  lite|expanded) ;;
  *)
    echo "Error: mode must be 'lite' or 'expanded'"
    usage
    exit 1
    ;;
esac

SESSION_SLUG="${POSITIONAL[0]}"
FEATURE_SLUG="${POSITIONAL[1]}"
TASK_SLUG="${POSITIONAL[2]}"
TODAY="$(date +%Y-%m-%d)"
OWNER="${HARNESS_OWNER:-${USER:-unknown}}"
TASK_ROOT="execution"
SESSION_DIR="${TASK_ROOT}/sessions/${TODAY}_${SESSION_SLUG}"
TASK_DIR="${SESSION_DIR}/features/${FEATURE_SLUG}/tasks/${TASK_SLUG}"
WORK_HANDOFF_FILE="work-handoff.md"

mkdir -p "${TASK_DIR}"

update_work_handoff_active_task_path() {
  local file="$1"
  local task_path="$2"
  local tmp_file

  tmp_file="$(mktemp)"
  awk -v task_path="${task_path}" '
    BEGIN {
      replaced = 0
      skipping = 0
    }
    /^## Active Task Path$/ {
      print $0
      print task_path
      print ""
      replaced = 1
      skipping = 1
      next
    }
    skipping && /^## / {
      skipping = 0
    }
    skipping {
      next
    }
    {
      print
    }
    END {
      if (!replaced) {
        print ""
        print "## Active Task Path"
        print task_path
      }
    }
  ' "${file}" > "${tmp_file}"
  mv "${tmp_file}" "${file}"
}

write_default_work_handoff() {
  local file="$1"
  local task_path="$2"
  local mode="$3"
  local remaining_work
  local next_actions

  if [[ "${mode}" == "expanded" ]]; then
    remaining_work="- Fill in ${task_path}/handoff.md and the expanded execution-memory files."
    next_actions="$(cat <<EOF
1. Fill in the task handoff.
2. Fill in plan.md before starting deeper work.
3. Update verification.md and execution-log.md only when they add value.
EOF
)"
  else
    remaining_work="- Fill in ${task_path}/handoff.md and start work."
    next_actions="$(cat <<EOF
1. Fill in the task handoff.
2. Update the handoff file after the first milestone.
EOF
)"
  fi

  cat > "${file}" <<EOF
# Work Handoff

## Objective
TODO: describe the overall goal.

## Active Task Path
${task_path}

## Current Status
Discover

## Completed
- Task scaffold created.

## Remaining Work
${remaining_work}

## Recommended Next Actions
${next_actions}

## Nice-to-Have Follow-Ups
- None yet.

## Open Questions
- None yet.

## Changed Files
- None yet.

## Notes
Created by scripts/new-task.sh
EOF
}

cat > "${TASK_DIR}/handoff.md" <<EOF
# Handoff

## Objective

TODO: describe the overall goal.

## Task Path

${TASK_DIR}

## Current Status

Discover

## Scope

- TODO: describe what this task covers.

## Plan

- [ ] TODO: first concrete step

## Progress

- [x] $(date +%Y-%m-%d): Task scaffold created.
- [ ] TODO: first milestone.

## Decisions

- None yet.

## Verification

- Not run yet.

## Next Actions

1. Fill in objective, scope, and plan.
2. Start work and keep progress current.

## Open Questions

- None yet.

## Changed Files

- None yet.

## Notes

Owner: ${OWNER}
Execution Mode: ${MODE}

## Auto Snapshot

TODO: maintained by stop-time automation when available.
EOF

if [[ "${MODE}" == "expanded" ]]; then
  cat > "${TASK_DIR}/plan.md" <<EOF
# Plan

## Context

TODO: describe the larger context and assumptions.

## Execution Plan

1. TODO: first major step
2. TODO: second major step

## Done Criteria

- TODO: observable completion criteria

## Risks / Rollback

- TODO: key risk and fallback
EOF

  cat > "${TASK_DIR}/verification.md" <<EOF
# Verification

## Checks

- TODO: list tests and checks run

## Review Notes

- TODO: capture review findings if needed
EOF

  cat > "${TASK_DIR}/execution-log.md" <<EOF
# Execution Log

## ${TODAY}

- Session started.
EOF
fi

if [[ -f "${WORK_HANDOFF_FILE}" ]]; then
  update_work_handoff_active_task_path "${WORK_HANDOFF_FILE}" "${TASK_DIR}"
else
  write_default_work_handoff "${WORK_HANDOFF_FILE}" "${TASK_DIR}" "${MODE}"
fi

echo "Created execution task at: ${TASK_DIR}"
echo ""
echo "Files created:"
ls "${TASK_DIR}/"
echo ""
echo "Work handoff file linked to task path: ${WORK_HANDOFF_FILE}"
echo "Execution root: ${TASK_ROOT}"
echo "Execution mode: ${MODE}"
