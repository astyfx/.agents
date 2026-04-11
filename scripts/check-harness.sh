#!/usr/bin/env bash
# check-harness.sh — validate harness health
# Usage: bash scripts/check-harness.sh

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0
WARNINGS=0
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

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
check "ROADMAP.md exists" "[[ -f '${REPO_DIR}/ROADMAP.md' ]]"
check "CHANGELOG.md exists" "[[ -f '${REPO_DIR}/CHANGELOG.md' ]]"
check "CONVENTIONS.md exists" "[[ -f '${REPO_DIR}/docs/instructions/CONVENTIONS.md' ]]"
check "CONTEXT_LOADING.md exists" "[[ -f '${REPO_DIR}/docs/instructions/CONTEXT_LOADING.md' ]]"
check "RESPONSE_STYLE.md exists" "[[ -f '${REPO_DIR}/docs/instructions/RESPONSE_STYLE.md' ]]"
check "LIBRARIES.md exists" "[[ -f '${REPO_DIR}/docs/instructions/LIBRARIES.md' ]]"
check "TRACKING.md exists" "[[ -f '${REPO_DIR}/docs/instructions/TRACKING.md' ]]"
check "ENGINEERING_GROWTH.md exists" "[[ -f '${REPO_DIR}/docs/instructions/ENGINEERING_GROWTH.md' ]]"
check "ROUTING.md exists" "[[ -f '${REPO_DIR}/docs/instructions/ROUTING.md' ]]"
check "TRACKING.md references execution/" "grep -q './execution/' '${REPO_DIR}/docs/instructions/TRACKING.md'"
check "AGENTS.md references ARCHITECTURE.md" "grep -q 'ARCHITECTURE.md' '${REPO_DIR}/AGENTS.md'"
check "AGENTS.md references ROADMAP.md" "grep -q 'ROADMAP.md' '${REPO_DIR}/AGENTS.md'"
check "AGENTS.md references RESPONSE_STYLE.md" "grep -q 'RESPONSE_STYLE.md' '${REPO_DIR}/AGENTS.md'"
check "AGENTS.md references CONTEXT_LOADING.md" "grep -q 'CONTEXT_LOADING.md' '${REPO_DIR}/AGENTS.md'"
check "AGENTS.md references evals/README.md" "grep -q 'evals/README.md' '${REPO_DIR}/AGENTS.md'"
check "AGENTS.md references memory/" "grep -q 'memory/' '${REPO_DIR}/AGENTS.md'"

echo ""
echo "--- Hook scripts ---"
check "pre-commit-lint.sh" "[[ -f '${REPO_DIR}/scripts/hooks/pre-commit-lint.sh' ]]"
check "pre-write-secrets.sh" "[[ -f '${REPO_DIR}/scripts/hooks/pre-write-secrets.sh' ]]"
check "post-write-format.sh" "[[ -f '${REPO_DIR}/scripts/hooks/post-write-format.sh' ]]"
check "on-stop-handoff.sh" "[[ -f '${REPO_DIR}/scripts/hooks/on-stop-handoff.sh' ]]"
check "pre-commit hook avoids python3" "! grep -q 'python3' '${REPO_DIR}/scripts/hooks/pre-commit-lint.sh'"
check "pre-write hook avoids python3" "! grep -q 'python3' '${REPO_DIR}/scripts/hooks/pre-write-secrets.sh'"
check "post-write hook avoids python3" "! grep -q 'python3' '${REPO_DIR}/scripts/hooks/post-write-format.sh'"
check "stop hook avoids python3" "! grep -q 'python3' '${REPO_DIR}/scripts/hooks/on-stop-handoff.sh'"
check "Claude settings wire pre-commit hook" "grep -q 'pre-commit-lint.sh' '${REPO_DIR}/claude/settings.json'"
check "Claude settings wire secret hook" "grep -q 'pre-write-secrets.sh' '${REPO_DIR}/claude/settings.json'"
check "Claude settings wire format hook" "grep -q 'post-write-format.sh' '${REPO_DIR}/claude/settings.json'"
check "Claude settings wire stop handoff hook" "grep -q 'on-stop-handoff.sh' '${REPO_DIR}/claude/settings.json'"
check "Claude secret hook covers Edit" "grep -Eq '\"matcher\"[[:space:]]*:[[:space:]]*\"Edit\"' '${REPO_DIR}/claude/settings.json'"

echo ""
echo "--- Utility scripts ---"
check "init-repo.sh" "[[ -f '${REPO_DIR}/scripts/init-repo.sh' ]]"
check "init-repo.sh is executable" "[[ -x '${REPO_DIR}/scripts/init-repo.sh' ]]"
check "init-repo.sh supports --with-execution" "grep -q -- '--with-execution' '${REPO_DIR}/scripts/init-repo.sh'"
check "init-repo.sh drops --with-tracking" "! grep -q -- '--with-tracking' '${REPO_DIR}/scripts/init-repo.sh'"
check "init.sh avoids python3" "! grep -q 'python3' '${REPO_DIR}/scripts/init.sh'"
check "new-task.sh" "[[ -f '${REPO_DIR}/scripts/new-task.sh' ]]"
check "new-task.sh uses execution/" "grep -q 'TASK_ROOT=\"execution\"' '${REPO_DIR}/scripts/new-task.sh'"
check "new-eval-result.sh" "[[ -f '${REPO_DIR}/scripts/new-eval-result.sh' ]]"
check "summarize-evals.py" "[[ -f '${REPO_DIR}/scripts/summarize-evals.py' ]]"
check "summarize-evals.py is executable" "[[ -x '${REPO_DIR}/scripts/summarize-evals.py' ]]"
check "summarize-evals.py avoids python3" "! grep -q 'python3' '${REPO_DIR}/scripts/summarize-evals.py'"

echo ""
echo "--- Skills ---"
check "skills/INDEX.md" "[[ -f '${REPO_DIR}/skills/INDEX.md' ]]"
SKILL_COUNT=$(ls "${REPO_DIR}/skills/"*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
echo "  ${SKILL_COUNT} SKILL.md files found"

# Validate skill frontmatter has required fields
SKILL_ERRORS=0
SKILL_NAME_LIST="${TMP_DIR}/skill-names.txt"
INDEX_NAME_LIST="${TMP_DIR}/index-skill-names.txt"
: > "${SKILL_NAME_LIST}"

for skill_file in "${REPO_DIR}/skills/"*/SKILL.md; do
  [[ -f "$skill_file" ]] || continue
  skill_name=$(basename "$(dirname "$skill_file")")
  declared_name="$(sed -n 's/^name:[[:space:]]*//p' "$skill_file" | head -n 1 | sed 's/[[:space:]]*$//')"
  if ! grep -q "^name:" "$skill_file"; then
    echo "  ✗ ${skill_name}: missing 'name' in frontmatter"
    ((SKILL_ERRORS++)) || true
  fi
  if ! grep -q "^description:" "$skill_file"; then
    echo "  ✗ ${skill_name}: missing 'description' in frontmatter"
    ((SKILL_ERRORS++)) || true
  fi
  if [[ -n "${declared_name}" && "${declared_name}" != "${skill_name}" ]]; then
    echo "  ✗ ${skill_name}: frontmatter name '${declared_name}' does not match directory"
    ((SKILL_ERRORS++)) || true
  fi
  if [[ -n "${declared_name}" ]]; then
    echo "${declared_name}" >> "${SKILL_NAME_LIST}"
  fi
done
if [[ -f "${REPO_DIR}/skills/INDEX.md" ]]; then
  awk -F'|' '
    /^\|/ {
      name = $2
      gsub(/^[ \t]+|[ \t]+$/, "", name)
      if (name != "" && name != "Skill" && name != "Name" && name !~ /^---+$/) {
        print name
      }
    }
  ' "${REPO_DIR}/skills/INDEX.md" > "${INDEX_NAME_LIST}"

  while IFS= read -r declared_name; do
    [[ -n "${declared_name}" ]] || continue
    if ! grep -Fxq "${declared_name}" "${INDEX_NAME_LIST}"; then
      echo "  ✗ skills/INDEX.md: missing '${declared_name}'"
      ((SKILL_ERRORS++)) || true
    fi
  done < "${SKILL_NAME_LIST}"

  while IFS= read -r indexed_name; do
    [[ -n "${indexed_name}" ]] || continue
    if ! grep -Fxq "${indexed_name}" "${SKILL_NAME_LIST}"; then
      echo "  ✗ skills/INDEX.md: references missing skill '${indexed_name}'"
      ((SKILL_ERRORS++)) || true
    fi
  done < "${INDEX_NAME_LIST}"
fi

PLAYBOOK_SKILL_LIST="${TMP_DIR}/playbook-skill-refs.txt"
if [[ -d "${REPO_DIR}/memory/playbooks" ]]; then
  grep -rhoE 'the-[a-z0-9-]+' "${REPO_DIR}/memory/playbooks" 2>/dev/null | sort -u > "${PLAYBOOK_SKILL_LIST}"
  while IFS= read -r referenced_skill; do
    [[ -n "${referenced_skill}" ]] || continue
    if ! grep -Fxq "${referenced_skill}" "${SKILL_NAME_LIST}"; then
      echo "  ✗ playbooks: references missing skill '${referenced_skill}'"
      ((SKILL_ERRORS++)) || true
    fi
  done < "${PLAYBOOK_SKILL_LIST}"
fi

if [[ $SKILL_ERRORS -eq 0 ]]; then
  echo "  ✓ skill names, index entries, and playbook references are in sync"
else
  ((ERRORS+=SKILL_ERRORS)) || true
fi

echo ""
echo "--- Evals ---"
warn "evals/ directory" "[[ -d '${REPO_DIR}/evals' ]]"
warn "evals/README.md" "[[ -f '${REPO_DIR}/evals/README.md' ]]"
if [[ -d "${REPO_DIR}/evals/tasks" ]]; then
  EVAL_COUNT=$(ls "${REPO_DIR}/evals/tasks/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "  ${EVAL_COUNT} eval tasks found"
fi
if [[ -d "${REPO_DIR}/evals/results" ]]; then
  RESULT_COUNT=$(find "${REPO_DIR}/evals/results" -type f ! -name '.gitkeep' | wc -l | tr -d ' ')
  echo "  ${RESULT_COUNT} eval result files found"
  warn "eval result history exists" "[[ ${RESULT_COUNT} -gt 0 ]]"
fi

echo ""
echo "--- Subagents ---"
SUBAGENT_COUNT=$(ls "${REPO_DIR}/subagents/"*/AGENT.md 2>/dev/null | wc -l | tr -d ' ')
echo "  ${SUBAGENT_COUNT} subagents defined"

echo ""
echo "--- Operational memory ---"
warn "memory/ directory" "[[ -d '${REPO_DIR}/memory' ]]"
warn "memory/README.md" "[[ -f '${REPO_DIR}/memory/README.md' ]]"
warn "memory/scorecard/" "[[ -d '${REPO_DIR}/memory/scorecard' ]]"
warn "learnings/ archived directory" "[[ -d '${REPO_DIR}/learnings' ]]"

echo ""
echo "--- Work handoff file ---"
if [[ -f "${REPO_DIR}/work-handoff.md" ]]; then
  check "work-handoff.md has Active Task Path" "grep -q '^## Active Task Path$' '${REPO_DIR}/work-handoff.md'"
  check "work-handoff.md has Remaining Work" "grep -q '^## Remaining Work$' '${REPO_DIR}/work-handoff.md'"
  check "work-handoff.md has Recommended Next Actions" "grep -q '^## Recommended Next Actions$' '${REPO_DIR}/work-handoff.md'"
else
  echo "~ work-handoff.md not present (warning)"
  ((WARNINGS++)) || true
fi

echo ""
echo "--- Symlinks ---"
check "~/.claude symlink" "[[ -L '${HOME}/.claude' ]]"
check "~/.codex symlink" "[[ -L '${HOME}/.codex' ]]"
check "tracking/ removed" "[[ ! -d '${REPO_DIR}/tracking' ]]"

echo ""
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  echo "Result: ALL CHECKS PASSED"
elif [[ $ERRORS -eq 0 ]]; then
  echo "Result: OK with ${WARNINGS} warning(s)"
else
  echo "Result: ${ERRORS} error(s), ${WARNINGS} warning(s)"
  exit 1
fi
