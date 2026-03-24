# Verification

## check-harness.sh 실행 결과

```
=== Harness Health Check: /Users/jacob.kim/.agents ===

--- Policy files ---
✓ AGENTS.md exists
✓ CONVENTIONS.md exists
✓ LIBRARIES.md exists
✓ TRACKING.md exists
✓ ENGINEERING_GROWTH.md exists

--- Hook scripts ---
✓ pre-commit-lint.sh
✓ pre-write-secrets.sh
✓ post-write-format.sh
✓ on-stop-handoff.sh

--- Utility scripts ---
✓ new-tracked-task.sh

--- Skills ---
✓ skills/INDEX.md
  11 SKILL.md files found
  ✓ all skills have required frontmatter

--- Evals ---
✓ evals/ directory
  10 eval tasks found

--- Subagents ---
  2 subagents defined

--- Learnings ---
✓ learnings/ directory

--- Symlinks ---
✓ ~/.claude symlink
✓ ~/.codex symlink

Result: ALL CHECKS PASSED
```

## Git commit

```
[main 57babf2] feat(harness): add enforcement layer, evals, skills, learnings, and subagents
56 files changed, 2743 insertions(+)
```

## 수동 검증 필요 (미완료)

- [ ] `GITHUB_MCP_TOKEN` 환경변수 셸에 등록 후 GitHub MCP 연결 확인
- [ ] `pre-commit-lint.sh` 훅 실제 동작 확인: 나쁜 커밋 메시지로 `git commit` 시도
- [ ] `pre-write-secrets.sh` 훅 실제 동작 확인: `.env` 파일 Write 시도
- [ ] evals/ 태스크 실제 Claude/Codex 비교 런 1회 이상
