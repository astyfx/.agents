#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

# Choose shell rc file with a safe fallback.
SHELL_NAME="$(basename "${SHELL:-}")"
RC_FILE="${HOME_DIR}/.profile"
if [[ "${SHELL_NAME}" == "zsh" ]]; then
  RC_FILE="${HOME_DIR}/.zshrc"
elif [[ "${SHELL_NAME}" == "bash" ]]; then
  RC_FILE="${HOME_DIR}/.bashrc"
fi

CLAUDE_DIR="${REPO_DIR}/claude"
CODEX_DIR="${REPO_DIR}/codex"
BACKUP_ROOT="${REPO_DIR}/migration-backups/${TIMESTAMP}"

mkdir -p "${CLAUDE_DIR}" "${CODEX_DIR}"

# Clean baseline files (do not import from existing local settings).
if [[ ! -f "${CLAUDE_DIR}/settings.json" ]]; then
  printf '{}\n' > "${CLAUDE_DIR}/settings.json"
fi

python3 - <<'PYEOF' "${CLAUDE_DIR}/settings.json"
import json
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])
try:
    data = json.loads(settings_path.read_text(encoding="utf-8"))
except Exception:
    data = {}

hooks = data.setdefault("hooks", {})
pre = hooks.setdefault("PreToolUse", [])
post = hooks.setdefault("PostToolUse", [])
stop = hooks.setdefault("Stop", [])


def ensure_hook(bucket, matcher, command):
    for entry in bucket:
        if matcher is not None and entry.get("matcher") != matcher:
            continue
        for hook in entry.get("hooks", []):
            if hook.get("type") == "command" and hook.get("command") == command:
                return
    entry = {"hooks": [{"type": "command", "command": command}]}
    if matcher is not None:
        entry["matcher"] = matcher
    bucket.append(entry)


ensure_hook(pre, "Bash", "bash ~/.agents/scripts/hooks/pre-commit-lint.sh")
ensure_hook(pre, "Write", "bash ~/.agents/scripts/hooks/pre-write-secrets.sh")
ensure_hook(pre, "Edit", "bash ~/.agents/scripts/hooks/pre-write-secrets.sh")
ensure_hook(post, "Write", "bash ~/.agents/scripts/hooks/post-write-format.sh")
ensure_hook(post, "Edit", "bash ~/.agents/scripts/hooks/post-write-format.sh")
ensure_hook(stop, None, "bash ~/.agents/scripts/hooks/on-stop-handoff.sh")

settings_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PYEOF

if [[ ! -f "${CLAUDE_DIR}/CLAUDE.md" ]]; then
  cat > "${CLAUDE_DIR}/CLAUDE.md" <<'EOF'
# Claude Global Policy

## MANDATORY - Read before every session

Before responding to any user message:
1. **Read `~/.agents/AGENTS.md`** - canonical shared policy
2. **Read `~/.agents/CLAUDE.md`** - Claude-specific behavioral guidance

Apply both as global instructions, supplemented by any project-specific context.
EOF
fi

if [[ ! -f "${CODEX_DIR}/config.toml" ]]; then
  cat > "${CODEX_DIR}/config.toml" <<'EOF'
# Codex config (clean baseline)

[tools]
web_search = true
EOF
fi

if [[ ! -f "${CODEX_DIR}/AGENTS.md" ]]; then
  cat > "${CODEX_DIR}/AGENTS.md" <<'EOF'
# AGENTS.md

This runtime directory is not a source-of-truth policy location.

Use `~/.agents/AGENTS.md` as the canonical policy for work under `CODEX_HOME`.
Treat the instructions in `~/.agents/AGENTS.md` as fully incorporated here by reference.

If a future local `AGENTS.md` in this runtime directory conflicts with the root file,
`~/.agents/AGENTS.md` wins unless the user explicitly instructs otherwise.
EOF
fi

python3 - <<'PYEOF' "${CODEX_DIR}/AGENTS.md"
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")

if "## Invariants (enforce unconditionally — no exceptions)" not in text:
    invariants = """

## Invariants (enforce unconditionally — no exceptions)

These rules have no hooks enforcement on the Codex side, so they must be treated as
hard constraints, not preferences. If you would violate any of these, stop and ask
the user how to proceed.

### Commit Messages
- Never create, amend, or push a commit with a non-Conventional Commits message.
- Valid prefixes: feat, fix, refactor, chore, docs, test, perf, ci, build, revert.
- Format: `<type>(<optional scope>): <subject>` — subject in imperative mood, ~72 chars.
- If a non-Conventional commit already exists, stop and fix it before any further work.

### Secret Protection
- Never write API keys, tokens, private keys, or passwords to any tracked file.
- Before any write or edit, inspect both the destination path and the content.
- If the file is tracked or likely to be committed, stop on secret-like values even if the filename looks harmless.
- `.env.example`, `.env.sample`, `.env.template` are allowed only with placeholder values, never real credentials.

### Auto-Formatting
- After writing or editing source files, run the project's configured formatter
  if one exists: prettier for TS/JS, ruff for Python, rustfmt for Rust.
- Do not skip this step. Format before considering the edit complete.

### Session Handoff
- When stopping work on any task tracked under `tracking/`, update the task's
  `handoff.md` with current status, last completed step, and next action
  before finishing the session.
- If `claude-progress.txt` exists, keep `Tracking Task Path` current so the durable handoff target is unambiguous.
"""
    path.write_text(text.rstrip() + invariants + "\n", encoding="utf-8")
PYEOF

mkdir -p "${REPO_DIR}/migration-backups"

if [[ -L "${HOME_DIR}/.claude" ]]; then
  rm "${HOME_DIR}/.claude"
elif [[ -d "${HOME_DIR}/.claude" ]]; then
  mkdir -p "${BACKUP_ROOT}"
  rsync -a "${HOME_DIR}/.claude/" "${CLAUDE_DIR}/"
  mv "${HOME_DIR}/.claude" "${BACKUP_ROOT}/.claude.legacy"
elif [[ -e "${HOME_DIR}/.claude" ]]; then
  mkdir -p "${BACKUP_ROOT}"
  mv "${HOME_DIR}/.claude" "${BACKUP_ROOT}/.claude.legacy-file"
fi

if [[ -L "${HOME_DIR}/.codex" ]]; then
  rm "${HOME_DIR}/.codex"
elif [[ -d "${HOME_DIR}/.codex" ]]; then
  mkdir -p "${BACKUP_ROOT}"
  rsync -a "${HOME_DIR}/.codex/" "${CODEX_DIR}/"
  mv "${HOME_DIR}/.codex" "${BACKUP_ROOT}/.codex.legacy"
elif [[ -e "${HOME_DIR}/.codex" ]]; then
  mkdir -p "${BACKUP_ROOT}"
  mv "${HOME_DIR}/.codex" "${BACKUP_ROOT}/.codex.legacy-file"
fi

ln -s "${CLAUDE_DIR}" "${HOME_DIR}/.claude"
ln -s "${CODEX_DIR}" "${HOME_DIR}/.codex"

# Add env exports to the selected shell rc file once.
if [[ ! -f "${RC_FILE}" ]]; then
  touch "${RC_FILE}"
fi
if ! grep -q 'CLAUDE_CONFIG_DIR=' "${RC_FILE}"; then
  cat >> "${RC_FILE}" <<EOF

# Unified agent settings roots
export CLAUDE_CONFIG_DIR="\$HOME/.agents/claude"
export CODEX_HOME="\$HOME/.agents/codex"
EOF
fi

# GitHub MCP token — set this to your GitHub PAT in your shell rc or secrets manager
# export GITHUB_MCP_TOKEN="your_token_here"

echo "Initialized .agents settings."
echo "Shell detected: ${SHELL_NAME:-unknown}"
echo "Config written to: ${RC_FILE}"
echo "Reload shell: source ${RC_FILE}"
echo "CLAUDE_CONFIG_DIR=\$HOME/.agents/claude"
echo "CODEX_HOME=\$HOME/.agents/codex"
echo "~/.claude -> \$HOME/.agents/claude"
echo "~/.codex -> \$HOME/.agents/codex"

# --- Health Check ---
echo ""
echo "=== Harness Health Check ==="
HEALTH_OK=true
[[ -f "${REPO_DIR}/scripts/hooks/pre-commit-lint.sh" ]] && echo "✓ commit hook" || { echo "✗ commit hook missing"; HEALTH_OK=false; }
[[ -f "${REPO_DIR}/scripts/hooks/pre-write-secrets.sh" ]] && echo "✓ secrets hook" || { echo "✗ secrets hook missing"; HEALTH_OK=false; }
[[ -f "${REPO_DIR}/scripts/hooks/post-write-format.sh" ]] && echo "✓ format hook" || { echo "✗ format hook missing"; HEALTH_OK=false; }
[[ -f "${REPO_DIR}/scripts/check-harness.sh" ]] && echo "✓ check-harness.sh" || { echo "✗ check-harness.sh missing"; HEALTH_OK=false; }
[[ -f "${REPO_DIR}/skills/INDEX.md" ]] && echo "✓ skill index" || { echo "✗ skill index missing (run after skills are added)"; }
SKILL_COUNT=$(ls "${REPO_DIR}/skills/"*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
echo "  ${SKILL_COUNT} skills registered"
if [[ "${HEALTH_OK}" == "true" ]]; then
  echo "Harness: OK"
else
  echo "Harness: some components missing — run this script again after setup is complete"
fi
