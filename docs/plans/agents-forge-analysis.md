# .agents: Forge-Inspired Role & Workflow Analysis

Date: 2026-04-03
Status: Draft
Scope: `.agents` harness (`~/.agents`)

## Premise

Forge는 muse(계획), forge(구현), sage(리서치) 같은 역할 분리 에이전트를 제공한다.
`.agents`는 이미 subagent(planner, researcher, reviewer, qa-engineer)와 skill 체계를 갖고 있다.

이 분석의 목적은:
1. Forge의 역할 분리 모델과 `.agents`의 기존 모델을 정밀 비교
2. `.agents`에 부족한 부분을 식별
3. 흡수할 요소와 흡수하지 않을 요소를 구분
4. 실행 계획을 구체화

---

## 1. Role Model Comparison

### Forge의 역할 체계

| Role | Purpose | Tool Access | Output |
|---|---|---|---|
| muse | 계획, 설계, 전략 | read-only | plan artifact |
| forge | 구현, 패칭, 리팩터 | full access | code changes |
| sage | 리서치, 분석, 조사 | read-only + web | research report |

Forge는 이 세 역할을 사용자가 명시적으로 선택하거나, 자동 라우팅한다.
각 역할은 tool restriction, system prompt, output shape가 다르다.

### .agents의 기존 역할 체계

| Asset | Type | Forge Equivalent | Tool Access | Output |
|---|---|---|---|---|
| planner | subagent | muse | Read/Glob/Grep/Bash(ro) | architecture plan + Mermaid |
| researcher | subagent | sage | Read/Glob/Grep/Bash(ro) | research report |
| reviewer | subagent | (없음) | Read/Glob/Grep | review report |
| qa-engineer | subagent | (없음) | Read/Glob/Grep/Bash(ro) | test plan |
| main session | implicit | forge | full access | code changes |

### 비교 결론

`.agents`가 Forge보다 더 세분화되어 있다:
- `reviewer`와 `qa-engineer`는 Forge에 없는 역할이다.
- Forge의 `forge`(구현)에 해당하는 것은 `.agents`의 "main session"인데, 이건 명시적 역할이 아니라 암묵적 기본값이다.

하지만 `.agents`에 부족한 것 3가지:

1. **역할 프로필 선언 레이어가 없다**
   - subagent는 "별도 프로세스로 분리할 때" 쓰는 것이다.
   - "같은 세션에서 역할을 전환한다"는 개념이 없다.
   - Forge는 같은 세션 안에서 muse -> forge -> sage 전환이 가능하다.
   - `.agents`는 main session이 Plan mode일 때와 Implement mode일 때의 행동 차이를 선언하지 않는다.

2. **workflow orchestration이 없다**
   - subagent 간 순서, 산출물 전달, 단계별 승인을 정의하는 것이 없다.
   - ROUTING.md는 "언제 spawn할지"만 정의하고, "어떤 순서로 조합할지"는 정의하지 않는다.
   - Forge의 custom workflows는 multi-step orchestration을 YAML로 선언한다.

3. **host adapter가 없다**
   - `.agents`의 skill/subagent는 Claude/Codex에서 직접 읽히도록 설계되어 있다.
   - Stave 같은 GUI host가 `.agents`의 workflow를 읽어 실행하려면, host-agnostic spec이 필요하다.
   - 현재는 Stave가 `skills/`만 읽고, orchestration은 각자 구현한다.

---

## 2. What to Absorb

### 2.1 Role Profiles

**개념**: subagent와 별개로, "같은 세션의 행동 모드"를 선언하는 얇은 프로필.

**현재 `.agents`에 없는 이유**:
- 지금까지 "역할 전환"은 사용자가 프롬프트로 지시하거나, subagent spawn으로 분리했다.
- 하지만 Stave의 Composer 모드 전환(Phase A)이 들어오면, 각 모드의 행동 규칙이 필요하다.
- 그 규칙을 Stave 코드에 하드코딩하면 `.agents`의 source-of-truth가 깨진다.

**설계안**:

```
roles/
  plan.md        # 계획 모드 프로필
  research.md    # 리서치 모드 프로필
  implement.md   # 구현 모드 프로필
  review.md      # 리뷰 모드 프로필
```

각 프로필에 포함할 것:
- `tool_restrictions`: 사용 가능한 도구 목록
- `preferred_skills`: 이 모드에서 자동 로드할 skill 목록
- `output_shape`: 기대하는 산출물 형태
- `guardrails`: 이 모드에서 금지되는 행동
- `model_hint`: 이 모드에 적합한 모델 특성 (host가 참고, 강제 아님)

**Forge와의 차이**:
- Forge는 muse/forge/sage로 이름을 고정한다.
- `.agents`는 `plan/research/implement/review`로 중립적 이름을 쓴다.
- 이유: Claude/Codex/Stave 어디서든 자연스럽게 매핑되기 위해.

**기존 subagent와의 관계**:
- role profile은 "행동 모드 선언"이다. 메인 세션에서 참조한다.
- subagent는 "분리된 실행 프로세스"이다. 독립 컨텍스트에서 실행한다.
- 예: `plan` role profile은 메인 세션이 Plan 모드일 때 참조. `planner` subagent는 별도 프로세스로 spawn될 때 참조.
- 겹치는 부분이 있지만 용도가 다르다:
  - subagent planner: 복잡한 아키텍처 분석을 격리 실행할 때
  - plan role: 메인 세션이 "지금은 계획만 할게" 모드로 전환할 때
- role profile이 subagent를 대체하지 않는다. 보완한다.

**우선순위**: P0 - Stave Phase A의 선행 조건

---

### 2.2 Workflow Manifests

**개념**: multi-step 작업 패턴을 선언적으로 정의하는 spec.

**현재 `.agents`에 없는 이유**:
- 지금까지 orchestration은 ROUTING.md의 "언제 spawn할지" 가이드와 사용자의 수동 판단에 의존했다.
- 하지만 반복되는 패턴(plan -> implement -> review)을 매번 수동으로 하는 건 비효율적이다.

**설계안**:

```
workflows/
  plan-implement-review.yaml
  bugfix.yaml
  refactor.yaml
  release-pr.yaml
  research-report.yaml
```

Workflow spec 포맷:

```yaml
name: plan-implement-review
description: 계획 -> 승인 -> 구현 -> 리뷰의 기본 워크플로
steps:
  - id: plan
    role: plan
    skills: [the-refactoring-planner]
    output: plan artifact
    approval: required    # 사용자 승인 후 다음 단계
  - id: implement
    role: implement
    skills: [the-tdd]
    input_from: plan      # 이전 단계 산출물을 context로 주입
    workspace: isolated   # 새 worktree 추천
    output: code changes
  - id: review
    role: review
    skills: [the-code-reviewer]
    input_from: implement
    output: review report
```

**핵심 원칙**:
- Workflow spec은 실행 코드가 아니다. 선언이다.
- 실행 책임은 host(Stave, CLI, agentize)에 있다.
- `.agents`는 "무엇을 어떤 순서로"만 정의하고, "어떻게 실행할지"는 host가 결정한다.

**ROUTING.md와의 관계**:
- ROUTING.md: "언제 subagent를 spawn할지"의 판단 기준 (reactive)
- workflows/: "이 작업 유형은 이런 단계로 진행한다"의 선언 (proactive)
- ROUTING.md는 여전히 유효하다. Workflow 없이 자유 실행할 때 참조하는 가이드.
- Workflow는 ROUTING.md 위에 얹히는 상위 레이어다.

**우선순위**: P1

---

### 2.3 Host Adapter Spec

**개념**: `.agents`의 role/workflow를 다양한 host가 읽는 방법을 정의.

**현재 `.agents`에 없는 이유**:
- 지금까지 host는 Claude와 Codex뿐이었고, 둘 다 AGENTS.md를 직접 읽는 동일한 방식이었다.
- Stave가 workflow runner를 갖게 되면, "Stave가 `.agents`의 무엇을 어떻게 읽는가"를 명시해야 한다.

**설계안**:

`docs/instructions/HOST-INTEGRATION.md`에 다음을 정의:

```markdown
# Host Integration Guide

## Readable Assets

| Asset | Path | Format | Host Reads |
|---|---|---|---|
| Shared policy | AGENTS.md | markdown | All |
| Role profiles | roles/*.md | markdown + frontmatter | Stave (mode routing) |
| Workflow specs | workflows/*.yaml | YAML | Stave (workflow runner) |
| Skills | skills/*/SKILL.md | markdown + frontmatter | All |
| Subagent defs | subagents/*/AGENT.md | markdown + frontmatter | Claude/Codex (spawn) |
| Routing rules | docs/instructions/ROUTING.md | markdown | Claude/Codex (decision) |

## How Stave Reads .agents

1. Skill selector: three-layer discovery (global ~/.agents/skills -> user -> local)
2. Role profiles: Composer 모드 전환 시 해당 role profile 로드
3. Workflow specs: command palette에서 workflow 목록 표시, 실행 시 step 해석
4. Policy: AGENTS.md는 provider runtime의 system context에 주입

## How Claude/Codex Reads .agents

1. Bridge files (claude/CLAUDE.md, codex/AGENTS.md) -> AGENTS.md
2. Skills: 사용자 또는 자동으로 SKILL.md 주입
3. Subagents: ROUTING.md 기준으로 spawn 판단, AGENT.md 참조
4. Role profiles: 사용자가 "Plan mode로 해줘" 같은 지시 시 참조 가능
```

**우선순위**: P1 (role profiles + workflows와 함께)

---

### 2.4 Role Separation Evals

**개념**: 역할 분리가 실제로 더 나은 결과를 내는지 검증하는 eval task.

**현재 `.agents`에 없는 이유**:
- 기존 evals는 skill/subagent 단위 성능을 측정한다.
- "single-agent vs role-separated"의 비교 eval은 없다.

**설계안**:

```
evals/tasks/
  20-role-separation-plan.md       # 같은 계획 작업을 single vs plan-role로
  21-role-separation-research.md   # 같은 조사 작업을 single vs research-role로
  22-workflow-orchestration.md     # 수동 단계 전환 vs workflow 자동 전환
```

각 eval은:
- 동일한 입력으로 두 가지 방식을 실행
- 산출물 품질, 소요 시간, context 효율성을 비교
- 역할 분리가 실제로 이점이 있는 임계점을 식별

**우선순위**: P2 (role profiles 구현 후)

---

## 3. What NOT to Absorb

| Forge Feature | 이유 |
|---|---|
| muse/forge/sage 이름 체계 | Forge 전용 브랜딩. `.agents`는 중립적 이름 사용 |
| Shell command 체계 (`/command`) | `.agents`는 host가 아님. CLI UX는 Stave/agentize 책임 |
| Provider/model 설정 | `.agents`는 정책 레이어. model routing은 Stave 책임 |
| Sandbox 구현 | git worktree 실행은 Stave 책임. `.agents`는 `workspace: isolated` 같은 선언만 |
| `~/forge` 디렉토리 | source-of-truth는 `~/.agents`. 이중 root 금지 |
| Runtime-specific config | `.agents`에 Forge용 adapter를 넣지 않음. Forge는 지원 host가 아님 |

---

## 4. ARCHITECTURE.md Impact

role profiles와 workflows를 추가하면 Layer Map이 변경된다:

```
현재:
  Policy -> Entry/Bridge -> Enforcement -> Skills -> Orchestration -> Artifact -> Runtime

추가 후:
  Policy -> Entry/Bridge -> Enforcement -> Roles -> Skills -> Workflows -> Orchestration -> Artifact -> Runtime
                                            ^^^               ^^^^^^^^^
                                            new               new
```

- **Roles Layer**: `roles/*.md` - 메인 세션의 행동 모드 선언
- **Workflows Layer**: `workflows/*.yaml` - multi-step orchestration 선언
- Orchestration Layer(subagents, ROUTING.md)는 그대로 유지
- Skills Layer는 그대로 유지 (workflow에서 참조됨)

---

## 5. Directory Responsibilities (추가분)

| Path | Role | Notes |
|---|---|---|
| `roles/` | 메인 세션 행동 모드 프로필 | subagent와 별개, host가 참조 |
| `workflows/` | 선언적 multi-step workflow spec | host가 실행, `.agents`는 정의만 |
| `docs/instructions/HOST-INTEGRATION.md` | Host가 `.agents`를 읽는 방법 | Stave/Claude/Codex 공통 가이드 |

---

## 6. Execution Plan

| Step | What | Priority | Depends On | Output |
|---|---|---|---|---|
| 1 | `roles/` 디렉토리 + 4개 role profile 작성 | P0 | - | roles/{plan,research,implement,review}.md |
| 2 | Workflow YAML spec 포맷 확정 | P1 | Step 1 | docs/instructions/WORKFLOW-SPEC.md |
| 3 | `workflows/` 디렉토리 + 기본 workflow 4개 작성 | P1 | Step 2 | workflows/*.yaml |
| 4 | HOST-INTEGRATION.md 작성 | P1 | Step 1, 3 | docs/instructions/HOST-INTEGRATION.md |
| 5 | ARCHITECTURE.md 업데이트 (Layer Map, Directory) | P1 | Step 1, 3 | ARCHITECTURE.md |
| 6 | ROUTING.md 업데이트 (workflow와의 관계 명시) | P1 | Step 3 | docs/instructions/ROUTING.md |
| 7 | Role separation evals 추가 | P2 | Step 1 | evals/tasks/20-22 |
| 8 | ROADMAP.md 업데이트 (Phase 5) | P0 | - | ROADMAP.md |
| 9 | CHANGELOG.md 업데이트 | 완료 시 | All | CHANGELOG.md |

---

## 7. Cross-Reference

- Stave absorption plan: `docs/plans/stave-forge-absorption.md`
- Stave Phase A는 `.agents` role profiles (Step 1)에 의존
- Stave Phase C는 `.agents` workflow specs (Step 2-3)에 의존
- 두 계획은 병렬 진행 가능하되, role profiles가 먼저 확정되어야 함
