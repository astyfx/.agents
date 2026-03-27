#!/usr/bin/env bash
# check-harness.sh — validate harness health
# Usage: bash scripts/check-harness.sh

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0
WARNINGS=0

check() {
  local desc="$1"
  local condition="$2"
  if eval "$condition"; then
    echo "✓ ${desc}"
  else
    echo "✗ ${desc}"
    ((ERRORS++)) || true
  fi
}

warn() {
  local desc="$1"
  local condition="$2"
  if eval "$condition"; then
    echo "✓ ${desc}"
  else
    echo "~ ${desc} (warning)"
    ((WARNINGS++)) || true
  fi
}

echo "=== Harness Health Check: ${REPO_DIR} ==="
echo ""

echo "--- Policy files ---"
check "AGENTS.md exists" "[[ -f '${REPO_DIR}/AGENTS.md' ]]"
check "ARCHITECTURE.md exists" "[[ -f '${REPO_DIR}/ARCHITECTURE.md' ]]"
check "CHANGELOG.md exists" "[[ -f '${REPO_DIR}/CHANGELOG.md' ]]"
check "CONVENTIONS.md exists" "[[ -f '${REPO_DIR}/docs/instructions/CONVENTIONS.md' ]]"
check "LIBRARIES.md exists" "[[ -f '${REPO_DIR}/docs/instructions/LIBRARIES.md' ]]"
check "TRACKING.md exists" "[[ -f '${REPO_DIR}/docs/instructions/TRACKING.md' ]]"
check "ENGINEERING_GROWTH.md exists" "[[ -f '${REPO_DIR}/docs/instructions/ENGINEERING_GROWTH.md' ]]"
check "ROUTING.md exists" "[[ -f '${REPO_DIR}/docs/instructions/ROUTING.md' ]]"
check "AGENTS.md references ARCHITECTURE.md" "grep -q 'ARCHITECTURE.md' '${REPO_DIR}/AGENTS.md'"
check "AGENTS.md references evals/README.md" "grep -q 'evals/README.md' '${REPO_DIR}/AGENTS.md'"
check "AGENTS.md references learnings/" "grep -q 'learnings/' '${REPO_DIR}/AGENTS.md'"

echo ""
echo "--- Hook scripts ---"
check "pre-commit-lint.sh" "[[ -f '${REPO_DIR}/scripts/hooks/pre-commit-lint.sh' ]]"
check "pre-write-secrets.sh" "[[ -f '${REPO_DIR}/scripts/hooks/pre-write-secrets.sh' ]]"
check "post-write-format.sh" "[[ -f '${REPO_DIR}/scripts/hooks/post-write-format.sh' ]]"
check "on-stop-handoff.sh" "[[ -f '${REPO_DIR}/scripts/hooks/on-stop-handoff.sh' ]]"
check "Claude settings wire pre-commit hook" "grep -q 'pre-commit-lint.sh' '${REPO_DIR}/claude/settings.json'"
check "Claude settings wire secret hook" "grep -q 'pre-write-secrets.sh' '${REPO_DIR}/claude/settings.json'"
check "Claude settings wire format hook" "grep -q 'post-write-format.sh' '${REPO_DIR}/claude/settings.json'"
check "Claude settings wire stop handoff hook" "grep -q 'on-stop-handoff.sh' '${REPO_DIR}/claude/settings.json'"
check "Claude secret hook covers Edit" "grep -q '\"matcher\": \"Edit\"' '${REPO_DIR}/claude/settings.json'"

echo ""
echo "--- Utility scripts ---"
check "new-tracked-task.sh" "[[ -f '${REPO_DIR}/scripts/new-tracked-task.sh' ]]"
check "new-eval-result.sh" "[[ -f '${REPO_DIR}/scripts/new-eval-result.sh' ]]"
check "summarize-evals.py" "[[ -f '${REPO_DIR}/scripts/summarize-evals.py' ]]"

echo ""
echo "--- Skills ---"
check "skills/INDEX.md" "[[ -f '${REPO_DIR}/skills/INDEX.md' ]]"
SKILL_COUNT=$(ls "${REPO_DIR}/skills/"*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
echo "  ${SKILL_COUNT} SKILL.md files found"

# Validate skill frontmatter has required fields
SKILL_ERRORS=0
for skill_file in "${REPO_DIR}/skills/"*/SKILL.md; do
  [[ -f "$skill_file" ]] || continue
  skill_name=$(basename "$(dirname "$skill_file")")
  if ! grep -q "^name:" "$skill_file"; then
    echo "  ✗ ${skill_name}: missing 'name' in frontmatter"
    ((SKILL_ERRORS++)) || true
  fi
  if ! grep -q "^description:" "$skill_file"; then
    echo "  ✗ ${skill_name}: missing 'description' in frontmatter"
    ((SKILL_ERRORS++)) || true
  fi
done
[[ $SKILL_ERRORS -eq 0 ]] && echo "  ✓ all skills have required frontmatter"

echo ""
echo "--- Evals ---"
warn "evals/ directory" "[[ -d '${REPO_DIR}/evals' ]]"
warn "evals/README.md" "[[ -f '${REPO_DIR}/evals/README.md' ]]"
if [[ -d "${REPO_DIR}/evals/tasks" ]]; then
  EVAL_COUNT=$(ls "${REPO_DIR}/evals/tasks/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "  ${EVAL_COUNT} eval tasks found"
fi

echo ""
echo "--- Subagents ---"
SUBAGENT_COUNT=$(ls "${REPO_DIR}/subagents/"*/AGENT.md 2>/dev/null | wc -l | tr -d ' ')
echo "  ${SUBAGENT_COUNT} subagents defined"

echo ""
echo "--- Learnings ---"
warn "learnings/ directory" "[[ -d '${REPO_DIR}/learnings' ]]"

echo ""
echo "--- Progress file ---"
if [[ -f "${REPO_DIR}/claude-progress.txt" ]]; then
  check "claude-progress.txt has Tracking Task Path" "grep -q '^## Tracking Task Path$' '${REPO_DIR}/claude-progress.txt'"
  check "claude-progress.txt has Next Action" "grep -q '^## Next Action$' '${REPO_DIR}/claude-progress.txt'"
else
  echo "~ claude-progress.txt not present (warning)"
  ((WARNINGS++)) || true
fi

echo ""
echo "--- Symlinks ---"
check "~/.claude symlink" "[[ -L '${HOME}/.claude' ]]"
check "~/.codex symlink" "[[ -L '${HOME}/.codex' ]]"

echo ""
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  echo "Result: ALL CHECKS PASSED"
elif [[ $ERRORS -eq 0 ]]; then
  echo "Result: OK with ${WARNINGS} warning(s)"
else
  echo "Result: ${ERRORS} error(s), ${WARNINGS} warning(s)"
  exit 1
fi
