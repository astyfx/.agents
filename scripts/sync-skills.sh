#!/usr/bin/env bash
# Sync shared skills from ~/.agents/skills/ into Claude and Codex skill dirs.
#
# Architecture:
#   ~/.agents/skills/          - shared skills (single source of truth)
#   ~/.agents/claude/skills/   - Claude system + installed + symlinks to shared
#   ~/.agents/codex/skills/    - Codex system (.system/) + installed + symlinks to shared
#
# This script creates/refreshes symlinks in each tool's skills dir pointing
# back to ~/.agents/skills/<skill-name>. It never touches:
#   - hidden entries (.system, .installed, etc.)
#   - real directories that are not symlinks (tool-installed skills)
#
# Safe to run repeatedly. Also prunes stale symlinks.
#
# Usage:
#   bash ~/.agents/scripts/sync-skills.sh
#   bash ~/.agents/scripts/sync-skills.sh --dry-run
#   bash ~/.agents/scripts/sync-skills.sh --prune-only

set -euo pipefail

SHARED_DIR="${HOME}/.agents/skills"
CLAUDE_DIR="${HOME}/.agents/claude/skills"
CODEX_DIR="${HOME}/.agents/codex/skills"

DRY_RUN=0
PRUNE_ONLY=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --prune-only) PRUNE_ONLY=1 ;;
    -h|--help)
      grep -E '^#' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown arg: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "$SHARED_DIR" ]]; then
  echo "Shared skills dir not found: $SHARED_DIR" >&2
  exit 1
fi

log() {
  echo "[sync-skills] $*"
}

run() {
  if [[ "$DRY_RUN" == 1 ]]; then
    echo "  DRY-RUN: $*"
  else
    "$@"
  fi
}

# Collect real skill dirs in shared (skip files, hidden, INDEX.md)
collect_shared_skills() {
  find "$SHARED_DIR" -mindepth 1 -maxdepth 1 -type d \
    ! -name '.*' \
    -exec basename {} \; \
    | sort
}

sync_to() {
  local target_dir="$1"
  local label="$2"

  log "== Syncing to $label ($target_dir) =="

  if [[ ! -d "$target_dir" ]]; then
    log "Creating $target_dir"
    run mkdir -p "$target_dir"
  fi

  # Create/refresh symlinks for each shared skill
  if [[ "$PRUNE_ONLY" != 1 ]]; then
    while IFS= read -r skill; do
      local src="$SHARED_DIR/$skill"
      local dst="$target_dir/$skill"

      if [[ -L "$dst" ]]; then
        # Already a symlink - check if it points to the right place
        local current
        current="$(readlink "$dst")"
        if [[ "$current" == "$src" ]]; then
          continue
        fi
        log "Refreshing symlink: $dst (was -> $current)"
        run rm "$dst"
        run ln -s "$src" "$dst"
      elif [[ -e "$dst" ]]; then
        # Real file/dir exists - do not touch (could be tool-installed)
        log "SKIP: $dst exists as real entry, not a symlink"
        continue
      else
        log "Linking: $dst -> $src"
        run ln -s "$src" "$dst"
      fi
    done < <(collect_shared_skills)
  fi

  # Prune stale symlinks (symlinks pointing into SHARED_DIR for skills that no longer exist)
  while IFS= read -r entry; do
    local base
    base="$(basename "$entry")"
    if [[ -L "$entry" ]]; then
      local current
      current="$(readlink "$entry")"
      # Only prune symlinks that point into SHARED_DIR
      if [[ "$current" == "$SHARED_DIR"/* ]]; then
        if [[ ! -d "$current" ]]; then
          log "Pruning stale symlink: $entry (target missing)"
          run rm "$entry"
        fi
      fi
    fi
  done < <(find "$target_dir" -mindepth 1 -maxdepth 1 ! -name '.*')
}

sync_to "$CLAUDE_DIR" "Claude"
sync_to "$CODEX_DIR" "Codex"

log "Done."
