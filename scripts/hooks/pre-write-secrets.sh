#!/usr/bin/env bash
set -euo pipefail

# pre-write-secrets.sh — PreToolUse hook for Write tool
# Blocks writing files that match secret/credential patterns.
# Reads hook payload from stdin as JSON.

INPUT="$(cat)"

python3 - <<'PYEOF' "$INPUT"
import sys
import json
import re
import os

payload_str = sys.argv[1]

try:
    payload = json.loads(payload_str)
except json.JSONDecodeError:
    sys.exit(0)

file_path = payload.get("tool_input", {}).get("file_path", "")
if not file_path:
    sys.exit(0)

filename = os.path.basename(file_path)

# Allowlist: .env variants that are clearly templates
allowlist_patterns = [
    r'\.env\.example$',
    r'\.env\.sample$',
    r'\.env\.template$',
]
for pattern in allowlist_patterns:
    if re.search(pattern, filename, re.IGNORECASE):
        sys.exit(0)

# Blocklist patterns
blocklist_patterns = [
    r'^\.env$',          # exact .env
    r'\.pem$',           # PEM files
    r'_key[^a-z]?$',     # files ending in _key
    r'_key\.',           # files with _key in extension area
    r'_secret',          # files containing _secret
    r'_token',           # files containing _token
    r'credentials',      # files containing credentials
]

for pattern in blocklist_patterns:
    if re.search(pattern, filename, re.IGNORECASE):
        print(f"[pre-write-secrets] Blocked write to potentially sensitive file: {file_path}")
        print(f"  Filename '{filename}' matches secret file pattern.")
        print(f"  If this is intentional, rename the file or use a .example/.sample variant.")
        sys.exit(2)

sys.exit(0)
PYEOF
