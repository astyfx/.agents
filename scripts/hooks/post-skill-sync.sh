#!/usr/bin/env bash
# Claude PostToolUse hook: if the tool call touched ~/.agents/skills/, sync the
# symlink farm into Claude/Codex skill dirs. Silent no-op otherwise.
#
# Claude provides tool input as JSON on stdin for hooks. We cheaply check for
# the skills path in the payload.

set -euo pipefail

PAYLOAD="$(cat 2>/dev/null || true)"

# Fast path: only run the sync if the payload mentions the skills dir.
# Covers file_path, paths, commands that touch ~/.agents/skills/*.
if printf '%s' "$PAYLOAD" | grep -q '\.agents/skills/'; then
  bash "$HOME/.agents/scripts/sync-skills.sh" >/dev/null 2>&1 || true
fi

exit 0
