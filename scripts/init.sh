#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME}"
ZSHRC="${HOME_DIR}/.zshrc"

CLAUDE_DIR="${REPO_DIR}/claude"
CODEX_DIR="${REPO_DIR}/codex"

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

# Avoid symlink dependency: ensure default folders are plain directories.
timestamp="$(date +%Y%m%d-%H%M%S)"
if [[ -L "${HOME_DIR}/.claude" ]]; then
  rm "${HOME_DIR}/.claude"
fi
if [[ -L "${HOME_DIR}/.codex" ]]; then
  rm "${HOME_DIR}/.codex"
fi
if [[ -e "${HOME_DIR}/.claude" && ! -d "${HOME_DIR}/.claude" ]]; then
  mv "${HOME_DIR}/.claude" "${HOME_DIR}/.claude.backup-${timestamp}"
fi
if [[ -e "${HOME_DIR}/.codex" && ! -d "${HOME_DIR}/.codex" ]]; then
  mv "${HOME_DIR}/.codex" "${HOME_DIR}/.codex.backup-${timestamp}"
fi
mkdir -p "${HOME_DIR}/.claude" "${HOME_DIR}/.codex"

# Add env exports to .zshrc once.
if [[ ! -f "${ZSHRC}" ]]; then
  touch "${ZSHRC}"
fi
if ! grep -q 'CLAUDE_CONFIG_DIR=' "${ZSHRC}"; then
  cat >> "${ZSHRC}" <<EOF

# Unified agent settings roots
export CLAUDE_CONFIG_DIR="\$HOME/.agents/claude"
export CODEX_HOME="\$HOME/.agents/codex"
EOF
fi

echo "Initialized .agents settings."
echo "Reload shell: source ~/.zshrc"
echo "CLAUDE_CONFIG_DIR=\$HOME/.agents/claude"
echo "CODEX_HOME=\$HOME/.agents/codex"
