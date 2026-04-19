#!/usr/bin/env bash
# scaffold-ralph-codex.sh — install repo-local Ralph loop assets for Codex
#
# Usage:
#   bash ~/.agents/scripts/scaffold-ralph-codex.sh <project-path> [--force]

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: bash ~/.agents/scripts/scaffold-ralph-codex.sh <project-path> [--force]

Installs repo-local Ralph loop assets:
  scripts/ralph/ralph-codex.sh
  scripts/ralph/CODEX.md
  scripts/ralph/prd.json.example

Also adds runtime Ralph state to .gitignore:
  scripts/ralph/prd.json
  scripts/ralph/progress.txt
  scripts/ralph/archive/
  scripts/ralph/.last-branch
  scripts/ralph/last-response.txt
USAGE
}

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="${HARNESS_DIR}/skills/the-ralph-loop/assets/template"

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

PROJECT_DIR="$(cd "$1" 2>/dev/null && pwd || echo "$1")"
FORCE=false

shift || true
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "${PROJECT_DIR}" ]]; then
  echo "Error: ${PROJECT_DIR} is not a directory" >&2
  exit 1
fi

copy_template() {
  local rel_path="$1"
  local mode="$2"
  local src="${TEMPLATE_DIR}/${rel_path}"
  local dst="${PROJECT_DIR}/${rel_path}"
  local existed=false

  if [[ ! -f "${src}" ]]; then
    echo "Missing template: ${src}" >&2
    exit 1
  fi

  if [[ -f "${dst}" && "${FORCE}" != "true" ]]; then
    echo "  skip: ${rel_path} (already exists)"
    return 0
  fi

  if [[ -f "${dst}" ]]; then
    existed=true
  fi

  mkdir -p "$(dirname "${dst}")"
  install -m "${mode}" "${src}" "${dst}"
  if [[ "${existed}" == "true" ]]; then
    echo "  update: ${rel_path}"
  else
    echo "  create: ${rel_path}"
  fi
}

ensure_gitignore_patterns() {
  local gitignore="${PROJECT_DIR}/.gitignore"
  local -a patterns=(
    "scripts/ralph/prd.json"
    "scripts/ralph/progress.txt"
    "scripts/ralph/archive/"
    "scripts/ralph/.last-branch"
    "scripts/ralph/last-response.txt"
  )
  local -a additions=()
  local pattern

  for pattern in "${patterns[@]}"; do
    if [[ -f "${gitignore}" ]] && grep -qF "${pattern}" "${gitignore}" 2>/dev/null; then
      continue
    fi
    additions+=("${pattern}")
  done

  if [[ ${#additions[@]} -eq 0 ]]; then
    echo "  skip: .gitignore (Ralph patterns already present)"
    return 0
  fi

  {
    echo ""
    echo "# Ralph loop state (auto-added by scaffold-ralph-codex.sh)"
    for pattern in "${additions[@]}"; do
      echo "${pattern}"
    done
  } >> "${gitignore}"

  echo "  updated: .gitignore (+${#additions[@]} Ralph patterns)"
}

echo "=== Ralph Loop (Codex) ==="
copy_template "scripts/ralph/ralph-codex.sh" 0755
copy_template "scripts/ralph/CODEX.md" 0644
copy_template "scripts/ralph/prd.json.example" 0644
ensure_gitignore_patterns

echo ""
echo "Installed Ralph loop assets into: ${PROJECT_DIR}"
echo "Next steps:"
echo "  1. Copy scripts/ralph/prd.json.example to scripts/ralph/prd.json"
echo "  2. Fill in project-specific checks in scripts/ralph/CODEX.md"
echo "  3. Run ./scripts/ralph/ralph-codex.sh 10"
