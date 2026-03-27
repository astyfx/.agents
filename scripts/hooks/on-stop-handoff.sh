#!/usr/bin/env bash
# on-stop-handoff.sh — Stop hook that writes a session snapshot when Claude stops.
# NOTE: intentionally no set -e — this hook must never block the stop event.

SNAPSHOT_DIR="${HOME}/.agents/claude/session-snapshots"
mkdir -p "${SNAPSHOT_DIR}"

TIMESTAMP="$(date +%Y-%m-%d_%H%M%S)"
SNAPSHOT_FILE="${SNAPSHOT_DIR}/${TIMESTAMP}.md"

CURRENT_PWD="$(pwd)"
GIT_STATUS="$(git status --short 2>/dev/null || echo "not a git repo")"
PROGRESS_FILE="${CURRENT_PWD}/claude-progress.txt"
TRACKING_TASK_PATH=""

if [[ -f "${PROGRESS_FILE}" ]]; then
  TRACKING_TASK_PATH="$(python3 - <<'PYEOF' "${PROGRESS_FILE}"
import re
import sys
from pathlib import Path

progress_path = Path(sys.argv[1])
text = progress_path.read_text(encoding="utf-8")
match = re.search(r"^## Tracking Task Path\s*\n(.+?)\s*$", text, flags=re.MULTILINE)
if match:
    print(match.group(1).strip())
PYEOF
)"
fi

cat > "${SNAPSHOT_FILE}" <<EOF
# Session Snapshot — ${TIMESTAMP}

## Status
stopped

## Working Directory
${CURRENT_PWD}

## Tracking Task Path
${TRACKING_TASK_PATH:-unknown}

## Recent Git Status
${GIT_STATUS}
EOF

if [[ -n "${TRACKING_TASK_PATH}" ]]; then
  HANDOFF_BASE="${TRACKING_TASK_PATH}"
  if [[ "${HANDOFF_BASE}" != /* ]]; then
    HANDOFF_BASE="${CURRENT_PWD}/${HANDOFF_BASE}"
  fi

  if [[ -d "${HANDOFF_BASE}" && -f "${HANDOFF_BASE}/handoff.md" ]]; then
    HANDOFF_FILE="${HANDOFF_BASE}/handoff.md"
    python3 - <<'PYEOF' "${HANDOFF_FILE}" "${TIMESTAMP}" "${CURRENT_PWD}" "${SNAPSHOT_FILE}" "${GIT_STATUS}"
import re
import sys
from pathlib import Path

handoff_file = Path(sys.argv[1])
timestamp = sys.argv[2]
working_dir = sys.argv[3]
snapshot_file = sys.argv[4]
git_status = sys.argv[5]

section = f"""## Auto Snapshot

- Timestamp: {timestamp}
- Working Directory: {working_dir}
- Snapshot File: {snapshot_file}
- Recent Git Status:
```text
{git_status}
```
"""

text = handoff_file.read_text(encoding="utf-8")
pattern = re.compile(r"^## Auto Snapshot\s*\n.*?(?=^## |\Z)", flags=re.MULTILINE | re.DOTALL)
if pattern.search(text):
    updated = pattern.sub(section + "\n", text)
else:
    updated = text.rstrip() + "\n\n" + section + "\n"
handoff_file.write_text(updated, encoding="utf-8")
PYEOF
  fi
fi

exit 0
