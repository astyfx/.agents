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

if [[ ! -f "${CLAUDE_DIR}/CLAUDE.md" ]]; then
  cat > "${CLAUDE_DIR}/CLAUDE.md" <<'EOF'
# Claude Local Memory

Clean baseline for Claude memory/settings in .agents.
EOF
fi

if [[ ! -f "${CODEX_DIR}/config.toml" ]]; then
  cat > "${CODEX_DIR}/config.toml" <<'EOF'
# Codex config (clean baseline)

[tools]
web_search = true
EOF
fi

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

echo "Initialized .agents settings."
echo "Shell detected: ${SHELL_NAME:-unknown}"
echo "Config written to: ${RC_FILE}"
echo "Reload shell: source ${RC_FILE}"
echo "CLAUDE_CONFIG_DIR=\$HOME/.agents/claude"
echo "CODEX_HOME=\$HOME/.agents/codex"
echo "~/.claude -> \$HOME/.agents/claude"
echo "~/.codex -> \$HOME/.agents/codex"
