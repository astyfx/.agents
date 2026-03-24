# Execution Log

## 2026-03-24

### Session start
- Input: Codex plan shared by user (채팅으로 붙여넣기)
- Goal: Claude + Codex 플랜 비교 분석 후 머지, 전체 구현

---

### Step 1 — Codex 플랜 파일 확인
- `tracking/sessions/2026-03-24_harness-evolution-research/...` 경로에 Codex가 실제로 트래킹 파일을 남겼음을 확인
- 읽은 파일: plan.md, phases.md, tasks.md

---

### Step 2 — 플랜 비교 매트릭스 작성
두 플랜 9개 차원 비교:
- Codex 우위: 우선순위 순서(evals first), guardrail 프레이밍, skill portability, 유틸 스크립트, harness-as-platform
- Claude 우위: 구체적 구현(훅 4개 파일명/로직), 보안 버그 발견(GitHub PAT), cross-agent 핸드오프 프로토콜, ROUTING.md

핵심 결정: **Evals first** (Codex 제안 채택) — 측정 없이 추가 작업은 검증 불가

---

### Step 3 — 머지 플랜 작성
- `tracking/sessions/2026-03-24_harness-evolution-merged/.../plan.md` 작성
- 6개 Phase로 정리, 총 ~15시간 예상

---

### Step 4 — 병렬 구현 (4개 에이전트 동시 실행)

#### Agent 1: Security + Guardrails
```
수정: claude/settings.json
  - GitHub PAT hardcoded 값 → $GITHUB_MCP_TOKEN 환경변수 교체
  - hooks 블록 추가 (PreToolUse 2개, PostToolUse 2개, Stop 1개)

수정: scripts/init.sh
  - GITHUB_MCP_TOKEN 가이드 주석 추가
  - 하단에 헬스체크 섹션 추가

생성: scripts/hooks/pre-commit-lint.sh   (chmod 755)
  - PreToolUse:Bash — git commit -m 의 메시지 파싱 (stdin JSON → python3)
  - Conventional Commits 패턴 검증, 위반 시 exit 2

생성: scripts/hooks/pre-write-secrets.sh  (chmod 755)
  - PreToolUse:Write — 파일 경로 파싱
  - .env, *.pem, *_key*, *_secret*, *_token*, *credentials* 패턴 차단
  - .env.example/.sample/.template 허용

생성: scripts/hooks/post-write-format.sh  (chmod 755, set -e 없음)
  - PostToolUse:Write,Edit — 파일 확장자별 포맷터 실행
  - .ts/.tsx/.js/.jsx → bunx prettier --write
  - .py → ruff format
  - .rs → rustfmt
  - 항상 exit 0 (fail-safe)

생성: scripts/hooks/on-stop-handoff.sh   (chmod 755, set -e 없음)
  - Stop 이벤트 — 세션 스냅샷 작성
  - ~/.agents/claude/session-snapshots/<timestamp>.md 생성

수정: codex/AGENTS.md
  - 기존 위임 텍스트 유지
  - ## Invariants 섹션 추가 (Commit Messages, Secret Protection, Auto-Formatting, Session Handoff)

생성: scripts/check-harness.sh   (chmod 755)
  - 정책 파일, 훅, 스크립트, 스킬, evals, 서브에이전트, learnings, 심링크 검증
  - 색상 없는 ✓/✗/~ 출력

생성: scripts/new-tracked-task.sh   (chmod 755)
  - Usage: new-tracked-task.sh <session-slug> <feature-slug> <task-slug>
  - tracking/ 하위에 6개 파일 자동 생성 (plan, phases, tasks, execution-log, verification, handoff)
```

#### Agent 2: Evals
```
생성: evals/README.md
  - 스코어링 루브릭 (pass/rework_count/verification_quality/policy_compliance/time_minutes)
  - 결과 파일 템플릿
  - 재실행 시점 가이드

생성: evals/results/.gitkeep

생성: evals/tasks/01-component-build.md      (DataTable with sort+filter+a11y)
생성: evals/tasks/02-tdd-cycle.md            (formatCurrency TDD cycle)
생성: evals/tasks/03-commit-convention.md    (guardrail: 나쁜 커밋 메시지 차단)
생성: evals/tasks/04-code-review-bugs.md     (planted bugs 4개: missing await, hardcoded secret 등)
생성: evals/tasks/05-build-fix-tsc.md        (TS2322, TS2339 에러 진단+수정)
생성: evals/tasks/06-cross-session-resume.md (claude-progress.txt 기반 세션 복원)
생성: evals/tasks/07-skill-creation.md       (the-api-designer 스킬 작성)
생성: evals/tasks/08-multifile-refactor.md   (formatDate 유틸 추출, 3파일)
생성: evals/tasks/09-secret-detection.md     (guardrail: .env 커밋 차단)
생성: evals/tasks/10-prompt-refinement.md    (막연한 프롬프트 → 구체화)
```

#### Agent 3: Skill System
```
수정: skills/the-refine-prompt/SKILL.md     — frontmatter에 compatible-tools, category, test-prompts 추가
수정: skills/the-skill-creator/SKILL.md     — frontmatter 추가 + Done Definition에 INDEX.md 업데이트 규칙 추가
수정: skills/the-frontend-director/SKILL.md — frontmatter 추가
수정: skills/ai-elements/SKILL.md           — frontmatter 추가
수정: skills/ui-ux-pro-max/SKILL.md         — compatible-tools: [claude] (Bash 의존), 나머지 추가
수정: skills/shadcn-ui/SKILL.md             — frontmatter 추가
수정: skills/vercel-react-best-practices/SKILL.md — 기존 license/metadata 유지 + 추가

생성: skills/INDEX.md
  - 11개 스킬 테이블 (name, category, compatible, trigger summary)

생성: skills/the-code-reviewer/SKILL.md
  - 6축 리뷰: Correctness, Security, Performance, Conventions, Architecture, Accessibility
  - 출력: [CRITICAL]/[SUGGESTION]/[NIT] 등급

생성: skills/the-tdd/SKILL.md
  - Red(실패 테스트) → Green(최소 구현) → Refactor 사이클 강제
  - Vitest/pytest/cargo test 프레임워크별 가이드

생성: skills/the-build-fixer/SKILL.md
  - classify → isolate → minimal fix → verify 루프
  - TypeScript 에러 패턴 테이블

생성: skills/the-build-fixer/scripts/classify-error.sh   (chmod 755)
  - stdin 에러 출력 → 분류 라벨 출력 (grep 패턴 기반, 모델 추론 없음)

생성: skills/the-progress-tracker/SKILL.md
  - claude-progress.txt 형식 정의 (Task/Status/Last Step/Next Action/Open Questions/Changed Files)
  - 세션 시작/작업중/세션 종료 워크플로우
  - cross-agent 호환성 설명
```

#### Agent 4: Learnings + Subagents + Platform
```
생성: learnings/README.md          — 무엇이 들어가야 하는지 규칙 (generic, transferable only)
생성: learnings/react-patterns.md  — RSC, hooks, 상태관리, forms, Electron
생성: learnings/typescript.md      — 타입 시스템 gotchas, 유틸 타입, 공통 에러
생성: learnings/testing.md         — Vitest, pytest, mocking, coverage
생성: learnings/architecture.md    — 레이어링, 모듈 설계, 상태, 경계
생성: learnings/build-tooling.md   — Bun, Vite, tsc, Next.js
생성: learnings/api-design.md      — REST, 응답 형태, 인증, Hono
생성: learnings/debugging.md       — JS/TS, React, 네트워크, 빌드 환경

생성: subagents/researcher/AGENT.md
  - Read/Glob/Grep/Bash(읽기 전용)만 허용
  - Discover 페이즈 탐색 → 구조화된 리포트 반환
  - 출력 형식 정의 (Relevant Files, Patterns, Constraints, Approach, Risks, Assumptions)

생성: subagents/reviewer/AGENT.md
  - Read/Glob/Grep만 허용 (Write 없음)
  - Verify 페이즈 독립 코드 리뷰
  - the-code-reviewer 스킬 적용

생성: docs/instructions/ROUTING.md
  - 단일 에이전트 유지 vs 서브에이전트 스폰 기준
  - researcher 스폰: Discover 페이즈, 5+ 미지 파일
  - reviewer 스폰: Implement 완료, 독립 리뷰 필요 시

생성: ARCHITECTURE.md
  - 6개 레이어 ASCII 다이어그램 (Policy → Enforcement → Skills → Subagents → Memory → Runtime)
  - 설계 원칙 6개
  - 핵심 파일 위치 테이블
  - Claude/Codex 패리티 테이블

생성: CHANGELOG.md
  - v2 (2026-03-24) 변경 이력
  - v1 (2026-03-16 ~ 24) 요약

수정: .gitignore
  - claude-progress.txt 추가
```

---

### Step 5 — 검증
```bash
$ bash scripts/check-harness.sh
=== Harness Health Check: /Users/jacob.kim/.agents ===

--- Policy files ---     ✓ 5/5
--- Hook scripts ---     ✓ 4/4
--- Utility scripts ---  ✓ 1/1
--- Skills ---           ✓ INDEX.md + 11 skills, all frontmatter valid
--- Evals ---            ✓ 10 tasks
--- Subagents ---        2 defined
--- Learnings ---        ✓ directory exists
--- Symlinks ---         ✓ ~/.claude, ~/.codex

Result: ALL CHECKS PASSED
```

---

### Step 6 — 커밋
```
[main 57babf2] feat(harness): add enforcement layer, evals, skills, learnings, and subagents
56 files changed, 2743 insertions(+)
```
