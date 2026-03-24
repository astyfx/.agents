#!/usr/bin/env bash
# post-write-format.sh — PostToolUse hook for Write and Edit tools
# Auto-formats files after they are written or edited.
# Reads hook payload from stdin as JSON.
# NOTE: intentionally no set -e — formatters may fail and that is acceptable.

INPUT="$(cat)"

FILE_PATH="$(python3 - <<PYEOF "$INPUT"
import sys, json
try:
    payload = json.loads(sys.argv[1])
    print(payload.get("tool_input", {}).get("file_path", ""))
except Exception:
    print("")
PYEOF
)"

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"

case "$EXT" in
  ts|tsx|js|jsx|json|css)
    if command -v bunx &>/dev/null; then
      bunx prettier --write "$FILE_PATH" 2>/dev/null || true
    elif command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
