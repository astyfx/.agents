#!/usr/bin/env bash
# on-stop-handoff.sh — Stop hook that writes a session snapshot when Claude stops.
# NOTE: intentionally no set -e — this hook must never block the stop event.

SNAPSHOT_DIR="${HOME}/.agents/claude/session-snapshots"
mkdir -p "${SNAPSHOT_DIR}"

TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
SNAPSHOT_FILE="${SNAPSHOT_DIR}/${TIMESTAMP}.md"

CURRENT_PWD="$(pwd)"
GIT_STATUS="$(git status --short 2>/dev/null || echo "not a git repo")"

cat > "${SNAPSHOT_FILE}" <<EOF
# Session Snapshot — ${TIMESTAMP}

## Status
stopped

## Working Directory
${CURRENT_PWD}

## Recent Git Status
${GIT_STATUS}
EOF

exit 0
