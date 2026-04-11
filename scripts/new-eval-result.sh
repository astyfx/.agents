#!/usr/bin/env bash
# new-eval-result.sh — scaffold a new eval result file
# Usage: bash scripts/new-eval-result.sh <agent> <task-id>

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <agent> <task-id>"
  echo "Example: $0 claude 04"
  exit 1
fi

AGENT="$1"
TASK_ID_RAW="$2"

case "${AGENT}" in
  claude|codex) ;;
  *)
    echo "Unsupported agent: ${AGENT}"
    echo "Expected one of: claude, codex"
    exit 1
    ;;
esac

TASK_ID="$(printf '%02d' "${TASK_ID_RAW}")"
RESULTS_DIR="evals/results"
TODAY="$(date +%Y-%m-%d)"
RESULT_FILE="${RESULTS_DIR}/${TODAY}_${AGENT}_${TASK_ID}.md"

mkdir -p "${RESULTS_DIR}"

if [[ -e "${RESULT_FILE}" ]]; then
  echo "Result file already exists: ${RESULT_FILE}"
  exit 1
fi

cat > "${RESULT_FILE}" <<EOF
# Result — Task ${TASK_ID} — ${AGENT} — ${TODAY}

task_id: ${TASK_ID}
agent: ${AGENT}
eval_type:
change_under_test:
decision_target:
pass:
rework_count:
verification_quality:
policy_compliance:
time_minutes:
notes: |
  TODO: add run notes.
EOF

echo "Created eval result file: ${RESULT_FILE}"
