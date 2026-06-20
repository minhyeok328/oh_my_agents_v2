# secret_agents_v2

`secret_agents_v2`는 Codex와 subagent가 사용자 Git 프로젝트를 안전하게 작업하도록 돕는 governance control plane입니다.
제품 앱 자체가 아니라, 앱을 넣고 작업 경계, 역할 분리, dependency graph, 검증 흐름을 정하는 문서/규칙 중심의 운영 셸입니다.

처음 사용하는 경우 먼저 [사용 설명서](./docs/onboarding/USER_GUIDE.ko.md)를 읽어 주세요.
새 프로젝트 폴더를 넣고 agent에게 profile/manifest 생성을 요청하는 방법은 [Workspace 설정 요청 가이드](./docs/onboarding/WORKSPACE_SETUP_REQUEST.ko.md)를 참고하세요.

## v2 difference: 기존 secret_agents와 다른 점

기존 `secret_agents`가 "작업 경계와 기본 안전 규칙을 둔 단일 운영 셸"에 가까웠다면, `secret_agents_v2`는 큰 작업을 여러 역할과 dependency-aware hybrid orchestration으로 굴리기 위한 운영 레이어입니다.

| 영역 | 기존 secret_agents | secret_agents_v2 |
| --- | --- | --- |
| 실행 모델 | Codex 중심의 단일 작업 흐름 | Root Orchestrator, Domain Orchestrator, Task Worker, Review/Security/Git 역할 분리 |
| 병렬 처리 | 병렬 가능성을 문서화 | dependency graph, ready node, rolling unlock 기반 hybrid orchestration |
| 계약 관리 | 공유 contract 참고 | contract-first gate와 app-scoped frozen contract 위치를 명시 |
| subagent 사용 | 작은 task card 중심 | 명시적 delegation 승인, owned outcome, checkpoint, unlock, usage evaluation까지 요구 |
| context 관리 | context를 작게 유지 | System token usage를 Low/Medium/High 또는 exact count로 기록하고 평가 |
| 검증 | 필수 문구와 trailing whitespace 확인 | Markdown link, real env tracking, secret-like value, gate 필드까지 검증 |
| Git | 구현과 Git 작업 분리 | Git Steward와 commit-workflow를 명확히 분리하고 shell/app target을 분류 |

## 빠른 시작

1. 실제 앱 repo를 `workspaces/<app-slug>/` 아래에 둡니다.
2. [사용 설명서](./docs/onboarding/USER_GUIDE.ko.md)를 읽고 active workspace를 정합니다.
3. `docs/templates/WORKSPACE_PROFILE.template.md`를 참고해 `workspaces/<app-slug>/.agent/profile.md`를 만듭니다.
4. `profile.md is authoritative` for app-local execution context.
5. `app-local AGENTS.md is optional`; 필요한 앱에서만 추가합니다.
6. Codex에게 작업을 요청할 때 `Active workspace: workspaces/<app-slug>`를 함께 적습니다.
7. 대부분의 작업은 Default Workflow로 진행하고, 기획부터 개발까지 맡길 때만 Full Delivery Workflow를 요청합니다.

## 핵심 모델

일반적인 구조는 다음과 같습니다.

```text
secret_agents_v2/               # governance control plane / 운영 셸
+-- AGENTS.md                    # 항상 적용되는 운영 규칙
+-- docs/                        # agent 규칙, 템플릿, 온보딩 문서
+-- scripts/                     # 문서 검증 등 보조 스크립트
+-- workspaces/
    +-- my-app/                  # 실제 사용자 Git 프로젝트
```

작업을 시작할 때는 하나의 active workspace를 선언합니다.

```text
Active workspace: workspaces/<app-slug>
```

agent는 이 active workspace와 배정된 write scope 안에서만 구현해야 합니다.
다른 `workspaces/*` 앱, 실제 `.env` 파일, credential, `.git/**`은 명시적 배정 없이 건드리지 않습니다.

## 기본 설정

1. 이 저장소를 프로젝트 루트로 엽니다.
2. [workspaces 안내](./workspaces/README.md)를 확인합니다.
3. subagent가 필요하면 `docs/templates/SUBAGENT_TASK_CARD.template.md`로 범위를 작게 고정합니다.
4. Git 작업은 구현 agent가 아니라 Git Steward 흐름에서 처리합니다.

## 주요 문서

| 문서 | 목적 |
| --- | --- |
| [AGENTS.md](./AGENTS.md) | 에이전트가 항상 따라야 하는 운영 원문 |
| [USER_GUIDE.ko.md](./docs/onboarding/USER_GUIDE.ko.md) | 처음 사용자를 위한 단순 사용 설명서 |
| [WORKSPACE_SETUP_REQUEST.ko.md](./docs/onboarding/WORKSPACE_SETUP_REQUEST.ko.md) | 새 프로젝트를 넣은 뒤 profile.md와 manifest.yml 생성을 요청하는 방법 |
| [SYSTEM_ARCHITECTURE.ko.md](./docs/onboarding/SYSTEM_ARCHITECTURE.ko.md) | 전체 오케스트레이션 구조와 역할 흐름 |
| [workflow.md](./docs/agent-rules/workflow.md) | Formal Planning, Full Delivery workflow, Spec/Task/Handover 형식 |
| [hybrid-orchestration.md](./docs/agent-rules/hybrid-orchestration.md) | Root/Domain/Worker 계층과 dependency-aware hybrid orchestration 규칙 |
| [workspaces.md](./docs/agent-rules/workspaces.md) | active workspace와 작업 경계 |
| [context-budget.md](./docs/agent-rules/context-budget.md) | subagent context를 작게 유지하는 규칙 |
| [subagent-execution.md](./docs/agent-rules/subagent-execution.md) | subagent 호출, 중단, 출력, 통합 절차 |
| [commits.md](./docs/agent-rules/commits.md) | Git Steward와 commit-workflow 규칙 |
| [repo-managed skills](./docs/skills) | 오케스트레이션 안정화를 위해 전역 skill로 설치할 수 있는 skill 원본 |

## 주요 템플릿

| 템플릿 | 용도 |
| --- | --- |
| [WORKSPACE_PROFILE.template.md](./docs/templates/WORKSPACE_PROFILE.template.md) | 앱별 실행 profile 작성 |
| [SUBAGENT_TASK_CARD.template.md](./docs/templates/SUBAGENT_TASK_CARD.template.md) | subagent에게 넘길 작은 작업 카드 |
| [DOMAIN_ORCHESTRATOR_CARD.template.md](./docs/templates/DOMAIN_ORCHESTRATOR_CARD.template.md) | Domain Orchestrator에게 넘길 dependency node 관리 카드 |
| [FULL_DELIVERY_START_CHECKLIST.md](./docs/templates/FULL_DELIVERY_START_CHECKLIST.md) | Full Delivery hybrid/병렬 multi-agent 작업 시작 전 gate |
| [CROSS_AGENT_HANDOVER_TEMPLATE.md](./docs/templates/CROSS_AGENT_HANDOVER_TEMPLATE.md) | agent 간 handover |

## 문서 검증

문서 체계가 깨지지 않았는지 확인하려면 다음 명령을 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-docs.ps1
```

이 검증은 필수 문서, 핵심 참조, task card 필드, Git Steward 규칙, sample workspace profile/manifest, delivery readiness fixture, Markdown links, 실제 `.env*` 추적 여부, secret-like values, Markdown trailing whitespace를 확인합니다.
Git Steward가 staging 전에 변경 대상을 볼 때는 `scripts/classify-git-target.ps1`로 shell/app 범위를 먼저 분류합니다.
오케스트레이션 구조는 `scripts/check-orchestration.ps1`, 계약 문서는 `scripts/check-contracts.ps1`, workspace 운영 선언은 `scripts/check-workspace-manifest.ps1`, 채워진 task/checklist/active contract 준비 상태는 `scripts/check-delivery-readiness.ps1`로 별도 점검합니다.

앱 workspace에서는 `profile.md`를 사람용 운영 문서로 유지하고, `.agent/manifest.yml`에는 active root, contract root, smoke command, Git mode처럼 기계가 검증해야 하는 핵심 운영값만 둡니다. `check-workspace-manifest.ps1`는 manifest 값이 실제 파일 시스템 및 profile.md와 일치하는지 확인합니다.

## Skill 설치

오케스트레이션 안정화용 전역 skills는 repo 안의 `docs/skills/` 원본을 기준으로 설치합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-skills.ps1
```

`commit-workflow`만 갱신해야 할 때는 기존 단일 설치 스크립트를 사용할 수 있습니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-commit-workflow.ps1
```

## 운영 원칙 요약

- 일반 작업은 Default Workflow로 가볍게 처리합니다.
- Spec, 설계, 구현 계획만 요청한 작업은 Formal Planning Workflow로 처리합니다.
- 처음 기획부터 Spec 작성과 개발까지 맡기는 작업에는 Full Delivery Workflow를 사용합니다.
- Full Delivery 앱 구현 작업은 active workspace와 검증 명령을 명시합니다.
- 큰 Full Delivery 작업은 기본적으로 hybrid orchestration으로 보고, dependency가 풀린 작업부터 순차+병렬로 진행합니다.
- subagent와 Superpowers `spawn_agent`는 기본 실행 경로가 아니며, 사용자가 subagent, delegation, hybrid orchestration, 또는 parallel agent work를 명시적으로 요청했을 때만 사용합니다.
- subagent는 스스로 workspace, write scope, Git 동작, 검증 방식을 정하지 않습니다.
- subagent는 task card의 필수/추천/제외 skill 안내를 기준으로, 자기 역할과 작업 성격에 맞는 installed skill을 스스로 판단해 사용하고 결과에 보고합니다.
- 구현 subagent는 Git 명령을 실행하지 않습니다.
- Git 작업은 [commit-workflow skill](./docs/skills/commit-workflow/SKILL.md)과 Git Steward 규칙을 사용합니다.
- 보안, auth, DB, 파일, 외부 API, dependency, config 작업은 Security Review Agent 조건을 확인합니다.
