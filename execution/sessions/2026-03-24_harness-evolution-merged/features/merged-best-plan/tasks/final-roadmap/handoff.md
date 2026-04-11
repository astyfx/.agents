# Handoff

## Summary

두 에이전트(Claude, Codex)의 harness 발전 플랜을 비교 분석하고 머지 플랜을 작성했다.

## Key Decisions Made

1. **Evals first** (Codex 제안 채택): 측정 없이 추가 작업은 검증 불가. Week 1 최우선.
2. **Guardrail 이중 구조** (양쪽 통합): Claude = hooks, Codex = AGENTS.md 명시 규칙. 메커니즘은 달라도 결과는 같아야 함.
3. **Skill portability schema** (Codex 제안 채택): frontmatter에 `compatible-tools`, `category`, `test-prompts` 추가.
4. **Memory = generic tech/arch** (유저 요구사항): `learnings/` 폴더는 기술/구조/아키텍처 패턴만. 프로젝트 사실은 `./agent-memory.md`에 (유저가 원할 때만).
5. **claude-progress.txt** (Claude 제안 채택): 파일 기반 크로스 에이전트 핸드오프 프로토콜. 이름은 "claude"지만 Codex도 동일하게 읽고 씀.

## What Was Dropped

- Claude plan: "Claude wins" 프레이밍 전체 제거
- Claude plan: `agent-memory.md`를 프로젝트별 메모리로 쓰는 아이디어 → 너무 구체적, generic으로 재설계
- Codex plan: 구체적 구현 없이 전략만 있는 부분 → Claude plan의 구체성으로 보완

## Open Questions

- `learnings/` seed content를 누가 어떻게 채울 것인가? 에이전트가 자동으로? 유저가 직접?
- `compatible-tools: [codex]` 스킬 (Codex-only)이 생길 경우를 어떻게 처리할 것인가?
- `evals/results/` 파일의 주기적 리뷰 방식 — 수동? 자동 요약?

## Next Actions

1. **Day 1**: Phase 0 — GitHub PAT 이전 (30분)
2. **Week 1**: Phase 1 — evals/ 10개 태스크 작성 (2시간)
3. **Week 1-2**: Phase 2 — 훅 4개 + Codex AGENTS.md + check-harness.sh + new-task.sh
4. Continue with phases 3-6 per tasks.md

## Artifacts Created

- `plan.md` — full merged roadmap
- `phases.md` — phase status
- `tasks.md` — complete implementation checklist
- `handoff.md` — this file
