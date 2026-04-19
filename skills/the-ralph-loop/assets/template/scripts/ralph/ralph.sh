#!/usr/bin/env bash
# Ralph loop - Claude or Codex
# Usage: ./scripts/ralph/ralph.sh [--tool claude|codex] [max_iterations]
#
# Environment overrides:
#   CODEX_BIN=codex              Codex binary to use
#   RALPH_SLEEP_SECONDS=2        Pause between iterations
#   RALPH_ENABLE_SEARCH=0|1      Enable Codex web search (codex only)
#   RALPH_ALLOW_DANGEROUS=0|1    Bypass sandbox restrictions

set -euo pipefail

TOOL="claude"
MAX_ITERATIONS=10

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    --tool=*)
      TOOL="${1#*=}"
      shift
      ;;
    -h|--help)
      echo "Usage: ./scripts/ralph/ralph.sh [--tool claude|codex] [max_iterations]"
      exit 0
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      else
        echo "Unknown argument: $1" >&2
        echo "Usage: ./scripts/ralph/ralph.sh [--tool claude|codex] [max_iterations]" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ "$TOOL" != "claude" && "$TOOL" != "codex" ]]; then
  echo "Error: --tool must be 'claude' or 'codex'" >&2
  exit 1
fi

CODEX_BIN="${CODEX_BIN:-codex}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CLAUDE_PROMPT="${SCRIPT_DIR}/CLAUDE.md"
CODEX_PROMPT="${SCRIPT_DIR}/CODEX.md"
PRD_FILE="${SCRIPT_DIR}/prd.json"
PROGRESS_FILE="${SCRIPT_DIR}/progress.txt"
ARCHIVE_DIR="${SCRIPT_DIR}/archive"
LAST_BRANCH_FILE="${SCRIPT_DIR}/.last-branch"
LAST_RESPONSE_FILE="${SCRIPT_DIR}/last-response.txt"
SLEEP_SECONDS="${RALPH_SLEEP_SECONDS:-2}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd git
require_cmd jq

if [[ "$TOOL" == "claude" ]]; then
  require_cmd claude
  if [[ ! -f "$CLAUDE_PROMPT" ]]; then
    echo "Missing prompt file: $CLAUDE_PROMPT" >&2
    exit 1
  fi
else
  require_cmd "${CODEX_BIN}"
  if [[ ! -f "$CODEX_PROMPT" ]]; then
    echo "Missing prompt file: $CODEX_PROMPT" >&2
    exit 1
  fi
fi

if ! git -C "${PROJECT_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Project root is not inside a git repository: ${PROJECT_ROOT}" >&2
  exit 1
fi

if [[ ! -f "${PRD_FILE}" ]]; then
  echo "Missing PRD file: ${PRD_FILE}" >&2
  echo "Copy prd.json.example to prd.json and fill in your stories first." >&2
  exit 1
fi

archive_previous_run_if_needed() {
  [[ -f "${LAST_BRANCH_FILE}" ]] || return 0

  local current_branch last_branch date_stamp folder_name archive_folder
  current_branch="$(jq -r '.branchName // empty' "${PRD_FILE}" 2>/dev/null || echo "")"
  last_branch="$(cat "${LAST_BRANCH_FILE}" 2>/dev/null || echo "")"

  if [[ -z "${current_branch}" || -z "${last_branch}" || "${current_branch}" == "${last_branch}" ]]; then
    return 0
  fi

  date_stamp="$(date +%Y-%m-%d)"
  folder_name="$(echo "${last_branch}" | sed 's|^ralph/||')"
  archive_folder="${ARCHIVE_DIR}/${date_stamp}-${folder_name}"

  echo "Archiving previous Ralph state for branch ${last_branch}"
  mkdir -p "${archive_folder}"
  [[ -f "${PRD_FILE}" ]] && cp "${PRD_FILE}" "${archive_folder}/"
  [[ -f "${PROGRESS_FILE}" ]] && cp "${PROGRESS_FILE}" "${archive_folder}/"

  cat > "${PROGRESS_FILE}" <<EOF
# Ralph Progress Log
Started: $(date)
---
EOF
}

track_current_branch() {
  local current_branch
  current_branch="$(jq -r '.branchName // empty' "${PRD_FILE}" 2>/dev/null || echo "")"
  if [[ -n "${current_branch}" ]]; then
    echo "${current_branch}" > "${LAST_BRANCH_FILE}"
  fi
}

ensure_progress_file() {
  [[ -f "${PROGRESS_FILE}" ]] && return 0
  cat > "${PROGRESS_FILE}" <<EOF
# Ralph Progress Log
Started: $(date)
---
EOF
}

run_claude_iteration() {
  cd "${PROJECT_ROOT}"
  claude --dangerously-skip-permissions --print < "${CLAUDE_PROMPT}" 2>&1 \
    | tee "${LAST_RESPONSE_FILE}" /dev/stderr || true
}

build_codex_command() {
  local -n out_ref=$1
  if [[ "${RALPH_ALLOW_DANGEROUS:-0}" == "1" ]]; then
    out_ref=("${CODEX_BIN}" exec -C "${PROJECT_ROOT}" --dangerously-bypass-approvals-and-sandbox)
  else
    out_ref=("${CODEX_BIN}" exec --full-auto -C "${PROJECT_ROOT}" \
      -c 'approval_policy="never"' \
      -c 'sandbox_mode="workspace-write"')
  fi
  if [[ "${RALPH_ENABLE_SEARCH:-0}" == "1" ]]; then
    out_ref+=(--search)
  fi
}

run_codex_iteration() {
  local CODEX_CMD=()
  build_codex_command CODEX_CMD
  "${CODEX_CMD[@]}" < "${CODEX_PROMPT}" 2>&1 \
    | tee "${LAST_RESPONSE_FILE}" /dev/stderr || true
}

archive_previous_run_if_needed
track_current_branch
ensure_progress_file

echo "Starting Ralph - Tool: ${TOOL} - Max iterations: ${MAX_ITERATIONS}"
echo "Project root: ${PROJECT_ROOT}"

for i in $(seq 1 "${MAX_ITERATIONS}"); do
  echo ""
  echo "==============================================================="
  echo "  Ralph Iteration ${i} of ${MAX_ITERATIONS} (${TOOL})"
  echo "==============================================================="

  if [[ "${TOOL}" == "claude" ]]; then
    OUTPUT="$(run_claude_iteration)"
  else
    OUTPUT="$(run_codex_iteration)"
  fi

  if printf '%s\n' "${OUTPUT}" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "Ralph completed all tasks."
    echo "Completed at iteration ${i} of ${MAX_ITERATIONS}"
    exit 0
  fi

  echo "Iteration ${i} complete. Continuing..."
  sleep "${SLEEP_SECONDS}"
done

echo ""
echo "Ralph reached max iterations (${MAX_ITERATIONS}) without completing all tasks."
echo "Check ${PROGRESS_FILE} and ${LAST_RESPONSE_FILE} for the latest state."
exit 1
