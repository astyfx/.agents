#!/usr/bin/env bash
# init-repo.sh — scaffold per-repo agent config for team-friendly use
#
# Usage:
#   bash ~/.agents/scripts/init-repo.sh <project-path> [--with-execution] [--with-ci]
#
# Design principle:
#   All generated files are TEAM-FRIENDLY — they contain no personal paths (~/.agents/)
#   and can be committed to a shared repo without affecting other team members.
#
#   Personal config (hooks, MCP servers, plugins) is handled by:
#   - Global: ~/.claude/settings.json (your personal harness, applied everywhere)
#   - Local:  .claude/settings.local.json (per-repo personal overrides, gitignored)
#
#   This means teammates who don't have ~/.agents/ can still benefit from the project
#   context in .claude/CLAUDE.md and .codex/AGENTS.md.

set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- Argument parsing ---

if [[ $# -lt 1 ]]; then
  cat <<'USAGE'
Usage: bash ~/.agents/scripts/init-repo.sh <project-path> [options]

Options:
  --with-execution  Create execution/ directory for lightweight task records
  --with-ci         Create .github/workflows/ with PR review template

Generated files (all team-committable):
  .claude/CLAUDE.md             Project context for Claude
  .claude/settings.json         Team-shared settings (no personal hooks)
  .codex/AGENTS.md              Project context for Codex
  CONVENTIONS.override.md       Team convention overrides
  LIBRARIES.override.md         Team library overrides

Personal config (gitignored automatically):
  .claude/settings.local.json   Personal overrides (created only if needed)
  work-handoff.md              Cross-session handoff scratch state

Example:
  bash ~/.agents/scripts/init-repo.sh ~/workspace/my-project --with-execution
USAGE
  exit 1
fi

PROJECT_DIR="$(cd "$1" 2>/dev/null && pwd || echo "$1")"
WITH_EXECUTION=false
WITH_CI=false

shift
for arg in "$@"; do
  case "$arg" in
    --with-execution) WITH_EXECUTION=true ;;
    --with-ci)       WITH_CI=true ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Error: $PROJECT_DIR is not a directory"
  exit 1
fi

PROJECT_NAME="$(basename "$PROJECT_DIR")"
CREATED=()

# --- Helper ---

write_if_missing() {
  local path="$1"
  local content="$2"
  if [[ -f "$path" ]]; then
    echo "  skip: $(basename "$path") (already exists)"
  else
    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$content" > "$path"
    CREATED+=("$path")
    echo "  create: $(basename "$path")"
  fi
}

# =============================================================================
# TEAM FILES — committed to repo, no personal (~/.agents/) references
# =============================================================================

# --- Claude project context ---

echo "=== Claude config (team) ==="
write_if_missing "${PROJECT_DIR}/.claude/CLAUDE.md" "# ${PROJECT_NAME}

## Project Context

<!-- Describe what this project is, its architecture, key entry points,
     and anything an agent needs to know before working here.

     This file is read by Claude Code for all team members.
     Do NOT put personal config here — use settings.local.json instead. -->

## Policy Layer

- If this repository has an \`AGENTS.md\`, treat it as the shared project policy.
- This file is Claude-specific supplemental guidance.

## Tech Stack

<!-- Example:
- Runtime: Node.js 20 + bun
- Framework: Next.js 14 (app router)
- Database: PostgreSQL via Prisma
- Testing: vitest + playwright
-->

## Key Commands

<!-- Example:
- Dev server: \`bun dev\`
- Tests: \`bun test\`
- Lint: \`bun lint\`
- Build: \`bun build\`
-->

## Project-Specific Rules

<!-- Add rules that all team members' agents should follow. -->
<!-- Example: \"Always run \`bun test\` before committing\" -->"

write_if_missing "${PROJECT_DIR}/.claude/settings.json" '{
  "permissions": {
    "allow": [],
    "deny": []
  }
}'

# --- Codex project context ---

echo ""
echo "=== Codex config (team) ==="
write_if_missing "${PROJECT_DIR}/.codex/AGENTS.md" "# ${PROJECT_NAME}

## Project Context

<!-- Describe what this project is, its architecture, key entry points. -->

## Conventions

- Use Conventional Commits (feat, fix, refactor, chore, docs, test)
- Do not commit secrets or API keys to tracked files
- Run the project formatter before considering edits complete"

# --- Convention and library overrides ---

echo ""
echo "=== Override templates (team) ==="
write_if_missing "${PROJECT_DIR}/CONVENTIONS.override.md" "# CONVENTIONS.override.md

Project-level convention overrides for ${PROJECT_NAME}.
These take precedence over workspace-level defaults.

## Scope
- Project: ${PROJECT_NAME}
- Effective date: $(date +%Y-%m-%d)

## Overrides

<!-- Example:
## Testing
- Use \`bun test\` instead of \`vitest\` directly
- Integration tests require \`docker compose up\` first

## Git
- Branch prefix: \`${PROJECT_NAME}/feat/...\`
-->

## Rationale
<!-- Why these overrides are needed -->"

write_if_missing "${PROJECT_DIR}/LIBRARIES.override.md" "# LIBRARIES.override.md

Project-level library overrides for ${PROJECT_NAME}.
These take precedence over workspace-level defaults.

## Scope
- Project: ${PROJECT_NAME}
- Effective date: $(date +%Y-%m-%d)

## Overrides

<!-- Example:
## State Management
- Preferred library: jotai
- Replaces: zustand
- Reason: existing codebase already uses jotai
-->

## Safety
- Migration plan: N/A
- Rollback plan: N/A"

# --- Optional: execution memory ---

if [[ "$WITH_EXECUTION" == "true" ]]; then
  echo ""
  echo "=== Execution Memory (team) ==="
  if [[ -d "${PROJECT_DIR}/execution" ]]; then
    echo "  skip: execution/ (already exists)"
  else
    mkdir -p "${PROJECT_DIR}/execution/sessions"
    CREATED+=("${PROJECT_DIR}/execution/sessions")
    echo "  create: execution/sessions/"
  fi
fi

# --- Optional: CI workflows ---

if [[ "$WITH_CI" == "true" ]]; then
  echo ""
  echo "=== CI Workflows (team) ==="
  write_if_missing "${PROJECT_DIR}/.github/workflows/agent-pr-review.yml" "# Agent-assisted PR review workflow
# Triggers when a PR is opened or updated. Requires ANTHROPIC_API_KEY secret.
# Customize the review command below to match your team's agent setup.

name: Agent PR Review

on:
  pull_request:
    types: [opened, synchronize, ready_for_review]

jobs:
  review:
    if: \${{ !github.event.pull_request.draft }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      # TODO: Configure your agent CLI and API key
      # - name: Run agent PR review
      #   env:
      #     ANTHROPIC_API_KEY: \${{ secrets.ANTHROPIC_API_KEY }}
      #   run: |
      #     npx claude-code --skill the-pr-reviewer --pr \${{ github.event.pull_request.number }}"
fi

# =============================================================================
# GITIGNORE — ensure personal/runtime files are excluded
# =============================================================================

echo ""
echo "=== Gitignore ==="
GITIGNORE="${PROJECT_DIR}/.gitignore"
ADDITIONS=()

# Personal agent runtime files that should never be committed
PERSONAL_PATTERNS=(
  "# Agent personal/runtime state (auto-added by init-repo.sh)"
  "work-handoff.md"
  ".claude/settings.local.json"
  ".claude/.claude.json"
  ".claude/history.jsonl"
  ".claude/statsig/"
  ".claude/session-env/"
  ".claude/sessions/"
  ".claude/file-history/"
  ".claude/cache/"
  ".claude/plans/"
)

for pattern in "${PERSONAL_PATTERNS[@]}"; do
  # Skip comment lines for the grep check
  [[ "$pattern" == \#* ]] && continue
  if [[ -f "$GITIGNORE" ]] && grep -qF "$pattern" "$GITIGNORE" 2>/dev/null; then
    continue
  fi
  ADDITIONS+=("$pattern")
done

if [[ ${#ADDITIONS[@]} -gt 0 ]]; then
  {
    echo ""
    echo "# Agent personal/runtime state (auto-added by init-repo.sh)"
    for p in "${ADDITIONS[@]}"; do
      echo "$p"
    done
  } >> "$GITIGNORE"
  echo "  updated: .gitignore (+${#ADDITIONS[@]} patterns)"
else
  echo "  skip: .gitignore (patterns already present)"
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo "=== Done ==="
echo "Project: ${PROJECT_DIR}"
echo "Files created: ${#CREATED[@]}"
echo ""
echo "Team files (committable — no personal paths):"
echo "  .claude/CLAUDE.md             Project context for Claude users"
echo "  .claude/settings.json         Team-shared settings"
echo "  .codex/AGENTS.md              Project context for Codex users"
echo "  CONVENTIONS.override.md       Team convention overrides"
echo "  LIBRARIES.override.md         Team library overrides"
if [[ "$WITH_CI" == "true" ]]; then
  echo "  .github/workflows/            CI workflow templates"
fi
echo ""
echo "Personal config (gitignored — handled by your global ~/.claude/ settings):"
echo "  Hooks, MCP servers, plugins → ~/.claude/settings.json (global, auto-applied)"
echo "  Per-repo overrides           → .claude/settings.local.json (if needed)"
echo ""
echo "Next steps:"
echo "  1. Edit .claude/CLAUDE.md — add project context, tech stack, key commands"
echo "  2. Edit CONVENTIONS.override.md — add team convention overrides"
echo "  3. Commit the generated files so your teammates benefit too"
