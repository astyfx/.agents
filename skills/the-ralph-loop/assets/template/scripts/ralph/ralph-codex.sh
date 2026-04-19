#!/usr/bin/env bash
# Shim: delegates to ralph.sh --tool codex
# For direct Codex-only usage. Prefer ralph.sh for the full interface.
exec "$(dirname "${BASH_SOURCE[0]}")/ralph.sh" --tool codex "$@"
