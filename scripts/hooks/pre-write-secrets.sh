#!/usr/bin/env bash
set -euo pipefail

# pre-write-secrets.sh — PreToolUse hook for Write/Edit tools
# Blocks writing sensitive content to tracked or likely-to-be-committed files.
# Reads hook payload from stdin as JSON.

INPUT="$(cat)"

python3 - <<'PYEOF' "$INPUT"
import sys
import json
import re
import os
import subprocess

payload_str = sys.argv[1]

try:
    payload = json.loads(payload_str)
except json.JSONDecodeError:
    sys.exit(0)

tool_input = payload.get("tool_input", {})
file_path = tool_input.get("file_path", "") or tool_input.get("path", "")
if not file_path:
    sys.exit(0)

filename = os.path.basename(file_path)
content = ""
for key in ("content", "text", "new_string", "newText", "replacement"):
    value = tool_input.get(key)
    if isinstance(value, str) and value:
        content = value
        break


def run_git(args, cwd):
    return subprocess.run(
        ["git", "-C", cwd, *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )


def git_repo_root(path):
    cwd = os.path.dirname(os.path.abspath(path)) or os.getcwd()
    result = run_git(["rev-parse", "--show-toplevel"], cwd)
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def path_is_trackable(path):
    repo_root = git_repo_root(path)
    if not repo_root:
        return False
    rel_path = os.path.relpath(os.path.abspath(path), repo_root)

    tracked = run_git(["ls-files", "--error-unmatch", "--", rel_path], repo_root)
    if tracked.returncode == 0:
        return True

    ignored = run_git(["check-ignore", "-q", "--", rel_path], repo_root)
    return ignored.returncode != 0


def looks_placeholder(value):
    lowered = value.strip().strip("'\"").lower()
    if not lowered:
        return True
    placeholder_markers = (
        "example",
        "sample",
        "placeholder",
        "changeme",
        "change-me",
        "set-me",
        "replace-me",
        "replace_with",
        "your-",
        "your_",
        "<",
        ">",
        "dummy",
        "fake",
        "redacted",
        "todo",
        "xxxxx",
        "localhost",
        "127.0.0.1",
    )
    return any(marker in lowered for marker in placeholder_markers)


def has_secret_content(text):
    if not text:
        return False

    raw_patterns = [
        r"-----BEGIN [A-Z ]*PRIVATE KEY-----",
        r"\bgh[pousr]_[A-Za-z0-9_]{20,}\b",
        r"\bsk-(?:proj|live|test|prod|ant)?-[A-Za-z0-9_-]{10,}\b",
        r"\bxox[baprs]-[A-Za-z0-9-]{10,}\b",
        r"\bAKIA[0-9A-Z]{16}\b",
        r"\bAIza[0-9A-Za-z\-_]{20,}\b",
    ]
    for pattern in raw_patterns:
        if re.search(pattern, text):
            return True

    env_pattern = re.compile(
        r"(?im)^\s*([A-Z0-9_]*(?:API_KEY|SECRET|TOKEN|PASSWORD|PRIVATE_KEY)[A-Z0-9_]*)\s*=\s*(.+?)\s*$"
    )
    for _, value in env_pattern.findall(text):
        if not looks_placeholder(value):
            return True

    return False

# Allowlist: .env variants that are clearly templates
allowlist_patterns = [
    r'\.env\.example$',
    r'\.env\.sample$',
    r'\.env\.template$',
]
is_template_name = any(re.search(pattern, filename, re.IGNORECASE) for pattern in allowlist_patterns)

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
risky_filename = any(re.search(pattern, filename, re.IGNORECASE) for pattern in blocklist_patterns)
risky_content = has_secret_content(content)
trackable = path_is_trackable(file_path)

if risky_filename and not is_template_name:
    print(f"[pre-write-secrets] Blocked write to high-risk secret path: {file_path}")
    print(f"  Filename '{filename}' matches a secret file pattern.")
    print(f"  Use a .example/.sample variant for templates or keep secrets out of tracked files.")
    sys.exit(2)

if risky_content and (trackable or is_template_name):
    print(f"[pre-write-secrets] Blocked write of secret-like content: {file_path}")
    if trackable:
        print("  Destination file is tracked or likely to be committed.")
    if is_template_name:
        print("  Template/example files must not contain real secret values.")
    print("  Replace secrets with placeholders or move them to an untracked local file.")
    sys.exit(2)

if risky_filename and not trackable:
    for pattern in blocklist_patterns:
        if re.search(pattern, filename, re.IGNORECASE):
            print(f"[pre-write-secrets] Blocked write to potentially sensitive file: {file_path}")
            print(f"  Filename '{filename}' matches secret file pattern.")
            print(f"  If this is intentional, rename the file or use a .example/.sample variant.")
            sys.exit(2)

sys.exit(0)
PYEOF
