#!/usr/bin/env bash
set -euo pipefail

# pre-commit-lint.sh — PreToolUse hook for Bash tool
# Blocks git commits with non-Conventional Commits messages.
# Reads hook payload from stdin as JSON.

INPUT="$(cat)"

python3 - <<'PYEOF' "$INPUT"
import sys
import json
import re

payload_str = sys.argv[1]

try:
    payload = json.loads(payload_str)
except json.JSONDecodeError:
    sys.exit(0)

command = payload.get("tool_input", {}).get("command", "")

if "git commit" not in command:
    sys.exit(0)

# Extract commit message from -m "..." or -m '...'
msg_match = re.search(r'-m\s+["\']([^"\']+)["\']', command)
if not msg_match:
    # Could be a heredoc or other form — allow it through
    sys.exit(0)

msg = msg_match.group(1)

# Validate Conventional Commits pattern
pattern = r'^(feat|fix|refactor|chore|docs|test|perf|ci|build|revert)(\(.+\))?: .+'
if re.match(pattern, msg):
    sys.exit(0)
else:
    print(f"[pre-commit-lint] Commit message does not follow Conventional Commits format.")
    print(f"  Got: {msg}")
    print(f"  Expected format: <type>(<scope>): <subject>")
    print(f"  Valid types: feat, fix, refactor, chore, docs, test, perf, ci, build, revert")
    print(f"  Example: feat(auth): add OAuth2 login support")
    sys.exit(2)
PYEOF
