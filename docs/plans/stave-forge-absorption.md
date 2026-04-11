# Stave: Forge-Inspired Feature Absorption Plan

Date: 2026-04-03
Status: Draft
Scope: Stave GUI host (`~/workspace/stave`)

## Premise

Forge는 shell-first agent runtime이고, Stave는 desktop-first agent runtime이다.
둘 다 같은 문제를 풀지만 UX 표면이 다르다.
Forge의 장점을 Stave에 흡수할 때는 "shell UX를 GUI로 번역"하는 관점이 필요하다.

Stave는 이미 상당수를 품고 있다:
- provider runtime + model router (Forge의 model routing에 대응)
- git worktree 기반 workspace (Forge의 sandbox에 대응)
- local MCP surface (Forge의 shell invocation에 대응)
- skill selector (Forge의 SKILL.md에 대응)
- managed task + approval flow (Forge의 operating agents에 대응)

따라서 "새로운 개념 도입"이 아니라 "기존 기능의 제품화 수준 격상"이 핵심이다.

---

## Gap Analysis: Forge vs Stave

| Forge Feature | Stave Current State | Gap |
|---|---|---|
| muse/forge/sage 역할 분리 | provider-runtimes.md에 plan/analyze/implement/verify/general intent 정의 | 내부 라우팅만 존재, 사용자 UX로 노출 안 됨 |
| Custom commands (`/bugfix`, `/release`) | skill selector `$skill-name` | 있지만 workflow orchestration은 없음 |
| Custom workflows (YAML multi-step) | 없음 | 선언적 multi-step workflow runner 없음 |
| Sandbox (git worktree isolation) | workspace = worktree, task ownership | 있지만 "implement in isolated workspace" 원클릭 흐름 없음 |
| Plan -> Approve -> Execute | Codex plan mode (experimental), plan_ready | 부분적. Claude용 plan approval UX 없음 |
| Background agent runs | managed task (local MCP) | 있지만 GUI 내 background task 패널 없음 |
| Progress timeline | todo progress utility (v0.0.33) | 초기 단계 |
| Shell companion CLI | 없음 | stave CLI 없음 |
| Operating agents (specialized) | Stave Auto router | 라우팅만 있고, 에이전트 선택 UI 없음 |

---

## Plan

### Phase A: Role-Aware Composer UX

**목표**: Stave Auto의 내부 intent 분류를 사용자가 직접 선택/전환할 수 있게 노출.

**현재 상태**:
- `provider-runtimes.md`에 `plan | analyze | implement | quick_edit | general | verify` intent가 정의됨
- Stave Auto가 프롬프트 기반으로 자동 분류함
- 사용자는 이 분류를 볼 수 없고, 직접 선택할 수 없음

**변경 사항**:
1. Composer header에 모드 선택 UI 추가
   - `Auto` (기본값, 현재 동작 유지)
   - `Plan` - 계획만 생성, 파일 수정 없음
   - `Research` - read-only 조사, 보고서 반환
   - `Implement` - 승인된 계획 기반 실행
   - `Review` - 코드 리뷰/검증
2. 모드 선택 시 해당 intent로 provider runtime에 강제 라우팅
3. Auto 모드는 현재 Stave Auto 라우팅 그대로 유지

**Forge 대응**: muse(plan) / forge(implement) / sage(research) 역할 분리의 GUI 번역.

**주의**:
- 새로운 provider나 모델을 추가하는 것이 아님
- 기존 intent classification을 사용자 표면으로 승격하는 것
- 모드 선택은 model 선택과 독립 (Auto 안에서 모드별 모델 매핑은 유지)

**영향 파일**:
- Composer 컴포넌트 (모드 선택 UI)
- provider routing logic (강제 intent override)
- task 메타데이터 (어떤 모드로 실행했는지 기록)

**우선순위**: P0

---

### Phase B: Plan-Approve-Implement Flow

**목표**: Plan 모드 응답에서 바로 구현으로 넘어가는 first-class workflow.

**현재 상태**:
- Codex: experimental plan mode 지원 (read-only sandbox, plan_ready 프로모션)
- Claude: plan mode 미지원 (SDK에 해당 개념 없음)
- 둘 다 plan 결과를 별도 artifact로 저장하거나 승인하는 UX 없음

**변경 사항**:
1. Plan 모드 응답 하단에 `Approve and Implement` 버튼 추가
2. 버튼 클릭 시:
   - 새 worktree workspace 생성 제안 (또는 현재 workspace 선택)
   - Implement 모드로 전환
   - Plan 내용을 system context로 주입
3. Plan artifact를 workspace에 저장 (`.stave/plans/`)
4. Plan history 브라우징 UI (v0.0.32의 workspace plan history persistence 확장)

**Forge 대응**: Forge의 plan-first 기본값 + sandbox 실행.

**의존성**: Phase A 완료 (모드 전환 메커니즘 필요)

**영향 파일**:
- message renderer (Approve 버튼)
- workspace creation flow (plan에서 직접 연결)
- plan artifact persistence
- Implement 모드 system prompt injection

**우선순위**: P0

---

### Phase C: Workflow Templates

**목표**: 반복되는 multi-step 작업 패턴을 선언적으로 정의하고 GUI에서 실행.

**현재 상태**:
- skill selector로 단일 skill 주입 가능
- multi-step orchestration은 없음 (사용자가 수동으로 단계 전환)

**변경 사항**:
1. Workflow spec 포맷 정의 (`.agents/workflows/` 에서 읽음)
2. Command palette에 workflow 목록 노출
3. Workflow 실행 시:
   - 각 단계의 역할(Plan/Research/Implement/Review), 사용 skill, 산출물을 표시
   - 단계별 자동 전환 또는 수동 승인 선택
   - 각 단계 완료 시 산출물을 다음 단계 context로 전달
4. 기본 제공 workflows:
   - `plan-implement-review`: Plan -> Approve -> Implement -> Review
   - `bugfix`: Research -> Implement -> Verify
   - `refactor`: Plan -> Research -> Implement -> Review
   - `release-pr`: Implement -> Review -> PR 생성

**Forge 대응**: Forge의 custom workflows (YAML multi-step orchestration)의 GUI 버전.

**핵심 설계 원칙**:
- Canonical workflow definition은 `.agents/workflows/`에 둔다 (content layer)
- Stave는 그것을 읽고 실행하는 host다
- Workflow spec은 host-agnostic YAML이어야 한다

**의존성**: Phase A (모드 전환), `.agents` workflow spec 포맷 확정

**영향 파일**:
- command palette 확장
- workflow runner engine (새로 추가)
- workflow step UI (progress bar, step cards)
- `.agents` workflow spec loader

**우선순위**: P1

---

### Phase D: Workspace Sandbox Preset

**목표**: "새 worktree에서 격리 실행"을 기본 추천 경로로 만들기.

**현재 상태**:
- workspace = git worktree (이미 구현)
- task는 workspace 소유 (workspace-integrity.md)
- 하지만 "새 workspace에서 작업 시작"이 자연스러운 흐름이 아님

**변경 사항**:
1. 새 task 시작 시 workspace 선택 프롬프트:
   - `Current workspace` (기본)
   - `New isolated workspace` (새 worktree + 브랜치 자동 생성)
2. Implement 모드에서는 `New isolated workspace` 기본 추천
3. Workspace 자동 정리: PR 머지 후 worktree 삭제 제안
4. Workspace 간 diff 비교 UI

**Forge 대응**: Forge sandbox feature의 GUI 버전.

**의존성**: 없음 (독립 구현 가능, 기존 worktree 인프라 위에 얹음)

**영향 파일**:
- task creation flow
- workspace management panel
- PR merge 후처리 로직

**우선순위**: P1

---

### Phase E: Background Task Panel

**목표**: 여러 task를 동시에 실행하고 진행 상황을 모니터링하는 UI.

**현재 상태**:
- managed task (local MCP 경유)는 백그라운드 실행 가능
- GUI 내에서 직접 background task를 시작하는 UX 없음
- todo progress utility 초기 단계 (v0.0.33)

**변경 사항**:
1. Task를 "Send to background" 옵션 추가
2. Background task panel (sidebar 또는 bottom panel):
   - 실행 중인 task 목록
   - 각 task의 진행 요약 (마지막 tool call, 현재 단계)
   - 완료/실패 알림
   - "Bring to foreground" / "Take over" 액션
3. 여러 workspace에서 동시에 task 실행 시 workspace별 그룹핑

**Forge 대응**: Forge의 background agent runs + progress timeline.

**의존성**: Phase D (workspace sandbox와 결합 시 가치 극대화)

**우선순위**: P2

---

### Phase F: Companion CLI

**목표**: Shell에서 Stave를 호출할 수 있는 얇은 CLI.

**현재 상태**:
- local MCP는 있지만 CLI는 없음
- 모든 작업은 GUI를 통해야 함

**변경 사항**:
1. `stave` CLI 바이너리 (또는 shell script)
   - `stave task "Fix the login bug"` - 새 task 생성
   - `stave workflow run bugfix` - workflow 실행
   - `stave status` - 실행 중인 task 상태
   - `stave open` - GUI 열기
2. 내부 구현: local MCP endpoint 호출 (새 런타임 만들지 않음)
3. Shell integration: `stave` 명령 후 GUI에서 task가 열림

**Forge 대응**: Forge의 shell-native invocation.

**핵심 원칙**:
- CLI는 thin client다. 모든 실행은 Stave GUI/runtime에서 일어남
- CLI는 local MCP의 consumer일 뿐이다
- GUI 없이 headless 실행은 scope 밖이다 (그건 agentize의 역할)

**의존성**: Phase C (workflow runner), Phase E (background task)

**우선순위**: P3

---

## Implementation Priority

| Phase | Name | Priority | Dependencies | Forge Feature |
|---|---|---|---|---|
| A | Role-Aware Composer | P0 | - | muse/forge/sage |
| B | Plan-Approve-Implement | P0 | A | plan-first + sandbox |
| C | Workflow Templates | P1 | A, .agents workflow spec | custom workflows |
| D | Workspace Sandbox Preset | P1 | - | sandbox |
| E | Background Task Panel | P2 | D | background runs |
| F | Companion CLI | P3 | C, E | shell invocation |

## Anti-Patterns (Forge에서 가져오지 않을 것)

- **Shell-first UX를 GUI에 이식**: Stave는 GUI-first다. slash command보다 버튼/패널이 맞다.
- **Provider/billing/key 운영 모델**: Stave는 이미 자체 provider config이 있다.
- **Forge의 `~/forge` 디렉토리 체계**: source-of-truth는 `~/.agents`다.
- **Forge의 runtime 구조 모방**: Stave는 Electron + SDK 기반이다. Forge의 CLI runtime을 가져올 이유 없다.
- **Headless 실행**: CLI에서 headless agent run은 agentize의 역할이다. Stave CLI는 GUI의 remote control이다.
