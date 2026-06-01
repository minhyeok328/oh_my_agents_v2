# secret_agents_v2 사용 설명서

이 문서는 `secret_agents_v2`를 처음 쓰는 사용자가 전체 구조를 빠르게 이해하기 위한 안내서입니다.
세부 운영 규칙보다 쉽게 읽히도록 작성했습니다.

## 이 시스템은 무엇인가요?

`secret_agents_v2`는 Codex가 사용자 Git 프로젝트를 안전하게 작업하도록 돕는 governance control plane입니다.

즉, `secret_agents_v2` 자체가 제품 앱일 필요는 없습니다.
대신 사용자의 실제 앱을 `workspaces/` 아래에 넣고, `secret_agents_v2`는 그 앱을 어떻게 읽고, 어디까지 수정하고, 어떤 기준으로 검증할지 정합니다.

## v2 difference: 기존 secret_agents와 다른 점

기존 `secret_agents`가 안전한 작업 경계와 기본 workflow를 제공하는 운영 셸이었다면, `secret_agents_v2`는 여러 agent가 큰 작업을 안정적으로 나눠 맡을 수 있도록 확장한 운영 레이어입니다.

핵심 차이는 다음과 같습니다.

- Root Orchestrator, Domain Orchestrator, Task Worker처럼 역할을 나눕니다.
- 병렬 작업을 "동시에 많이 시작하기"가 아니라 dependency가 풀린 node부터 진행하는 hybrid orchestration으로 다룹니다.
- API, DB, frontend-backend, infra contract를 구현 전에 먼저 확인합니다.
- subagent는 명시적으로 요청되었거나 이득이 분명할 때만 쓰고, owned outcome과 checkpoint를 task card에 적습니다.
- System token usage를 기록하고, 다음 작업에서 줄일 context를 평가합니다.
- 문서 검증이 링크, 실제 `.env*` 추적, secret-like 값까지 확인합니다.

기본 구조는 다음과 같습니다.

```text
secret_agents_v2/               # governance control plane / 운영 셸
+-- AGENTS.md                    # 항상 적용되는 운영 규칙
+-- docs/                        # agent 규칙, 템플릿, 온보딩 문서
+-- scripts/                     # 문서 검증 등 보조 스크립트
+-- workspaces/
    +-- my-app/                  # 실제 사용자 Git 프로젝트
```

간단히 말하면, `secret_agents_v2`는 작업 운영 환경이고 `workspaces/my-app`은 실제로 고칠 앱입니다.

## 핵심 개념

agent가 제품 코드를 바꾸기 전에 다음 질문에 답할 수 있어야 합니다.

```text
어느 앱을 작업하나요?
어떤 파일을 바꿀 수 있나요?
어떤 파일은 건드리면 안 되나요?
어떤 명령으로 검증하나요?
어떤 workflow 모드인가요?
```

앱 작업은 보통 이렇게 선언합니다.

```text
Active workspace: workspaces/<app-slug>
```

하나의 작업에서는 하나의 active workspace만 사용하는 것이 원칙입니다.
agent는 다른 `workspaces/*` 앱을 수정하면 안 됩니다.

## Workflow 모드

작업에는 가장 가벼우면서도 안전한 절차를 고릅니다.
일반 작업은 Default Workflow로 처리합니다.
Spec, 설계, 구현 계획 같은 계획 산출물만 요청한 경우에는 Formal Planning Workflow를 사용합니다.
사용자가 처음 기획부터 Spec 작성과 개발까지 맡긴 경우에만 Full Delivery Workflow를 사용합니다.

| Workflow | 사용 상황 |
| --- | --- |
| Default Workflow | 질문, 설명, 읽기 전용 조사, 작은 수정, 집중된 bugfix, 일상적인 구현 slice |
| Formal Planning Workflow | Spec, 설계, 구현 계획, Task/Subtask 분해, handoff 같은 계획 산출물만 요청한 작업 |
| Full Delivery Workflow | 초기 기획, Spec 작성, Task/Subtask 분해, 개발, 리뷰, 검증, handover까지 맡기는 작업 |

## 처음 사용할 때의 흐름

1. `secret_agents_v2`를 프로젝트 루트로 엽니다.
2. 실제 제품 앱을 `workspaces/<app-slug>` 아래에 clone하거나 복사합니다.
3. `docs/templates/WORKSPACE_PROFILE.template.md`를 참고해 `workspaces/<app-slug>/.agent/profile.md`를 만듭니다.
4. 앱 작업을 시작할 때 active workspace를 선언합니다.

   ```text
   Active workspace: workspaces/<app-slug>
   ```

5. 일반 작업은 Default Workflow로 진행합니다.
6. Spec, 설계, 구현 계획만 필요하면 Formal Planning Workflow를 요청합니다.
7. 기획부터 개발까지 맡길 때만 Full Delivery Workflow를 요청합니다.
8. subagent가 필요하면 별도로 요청하고 task card로 범위를 고정합니다.
9. 검증 명령은 active workspace 기준으로 실행합니다.
10. Git 작업은 구현 작업과 분리합니다.

## 주요 구성 요소

### 루트 규칙

가장 먼저 봐야 할 파일은 다음입니다.

```text
AGENTS.md
```

이 파일이 운영 기준의 원문입니다.
안전 규칙, workflow 모드, 보안 리뷰 조건, commit 규칙, 완료 기준을 정의합니다.

### 상세 agent 규칙

상세 규칙은 아래 폴더에 있습니다.

```text
docs/agent-rules/
```

주요 파일은 다음과 같습니다.

| 파일 | 목적 |
| --- | --- |
| `workflow.md` | Formal Planning, Full Delivery workflow, Spec/Task/Handover 형식 |
| `hybrid-orchestration.md` | Root/Domain/Worker 계층과 dependency-aware hybrid orchestration 규칙 |
| `roles.md` | agent 역할별 책임 |
| `context-budget.md` | subagent 프롬프트를 작게 유지하는 방법 |
| `subagent-execution.md` | subagent 호출, 중단, 출력, 통합 절차 |
| `workspaces.md` | active workspace 선언과 작업 경계 |
| `review.md` | 리뷰 출력 형식 |
| `security-review.md` | 보안 리뷰가 필요한 경우와 체크리스트 |
| `commits.md` | commit 안전 규칙과 Conventional Commits |

agent는 모든 규칙을 한 번에 읽지 않고, 현재 작업에 필요한 규칙만 읽습니다.

### System token usage

System token usage는 API key, credential, auth token 같은 비밀값이 아닙니다.
agent가 작업 전에 읽는 system/developer 지시, root 규칙, workflow 규칙, workspace profile, contract, task card, handover 같은 운영 context 비용을 뜻합니다.

작은 작업은 필요한 파일만 읽고, Full Delivery나 hybrid 작업은 역할별로 필요한 규칙만 task card에 담습니다.
정확한 token count를 볼 수 없으면 `Low`, `Medium`, `High`로 기록하고, subagent나 review가 끝난 뒤 다음 작업에서 줄일 수 있는 context를 평가합니다.

## Workspace Profile

각 앱에는 앱 전용 실행 프로필을 둘 수 있습니다.

```text
workspaces/<app-slug>/.agent/profile.md
```

프로필은 아래 템플릿으로 만듭니다.

```text
docs/templates/WORKSPACE_PROFILE.template.md
```

프로필에는 보통 다음 내용을 적습니다.

- 앱 루트 경로
- 기술 스택과 package manager
- lint, test, build, smoke 명령
- 수정 가능한 구현 경로
- 금지 경로
- contract 위치
- Git 관련 짧은 포인터

이 파일이 있으면 agent가 앱 구조나 검증 명령을 추측하지 않아도 됩니다.

## Git은 어떻게 다루나요?

구현 agent는 기본적으로 Git 명령을 실행하지 않습니다.
commit, branch, push, Git metadata 수정도 하지 않습니다.

Git 작업은 별도의 Git Steward 역할에서 처리합니다.
이 역할은 staging이나 commit 전에 commit 규칙을 읽어야 합니다.
commit 생성, staging, commit 분리, commit message 작성에는 `commit-workflow` skill을 사용합니다.
이 skill의 관리 원본은 [docs/skills/commit-workflow/SKILL.md](../skills/commit-workflow/SKILL.md)입니다.
전역 Codex skill로 다시 설치해야 할 때는 다음 명령을 사용합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-commit-workflow.ps1
```

이렇게 분리하는 이유는 구현 범위와 commit 범위의 위험이 다르기 때문입니다.
분리해 두면 잘못된 repo나 잘못된 workspace에 commit하는 실수를 줄일 수 있습니다.

Git Steward는 commit 전에 먼저 대상을 분류합니다.

```text
Git target: shell | active app | none | Needs Confirmation
```

- `shell`: `AGENTS.md`, `docs/**`, 템플릿, 온보딩 같은 `secret_agents_v2` 운영 문서
- `active app`: `workspaces/<app-slug>/**` 안의 실제 앱 변경
- `none`: commit하지 않아야 하는 변경
- `Needs Confirmation`: 대상이 애매해 사용자 확인이 필요한 변경

shell 변경과 app 변경은 기본적으로 같은 commit에 섞지 않습니다.
다른 `workspaces/*` 앱의 변경도 같은 commit에 섞지 않습니다.

## Contract는 무엇인가요?

Contract는 병렬 작업 전에 공유 인터페이스를 미리 정리하는 문서입니다.

기본 모델은 다음과 같습니다.

```text
docs/templates/                     # 재사용 가능한 셸 템플릿
workspaces/<app>/.agent/contracts/  # 앱별로 동결된 contract
```

Full Delivery 병렬 작업에서는 구현 agent가 시작하기 전에 contract를 검토해야 합니다.
구현 중 contract 변경이 필요하다는 사실을 발견하면, 추측해서 구현하지 말고 멈춘 뒤 보고해야 합니다.

## 고급: Subagent 사용

subagent는 기본 실행 방식이 아닙니다.
처음 사용하는 경우에는 먼저 Default Workflow와 active workspace만 이해해도 충분합니다.
subagent는 사용자가 명시적으로 요청했거나, Full Delivery hybrid/병렬 작업처럼 역할 분리의 이득이 분명할 때만 사용합니다.

workflow별 기본 기준은 다음과 같습니다.

| Workflow | subagent 호출 기준 |
| --- | --- |
| Default Workflow | 기본적으로 호출하지 않음. 사용자가 명시적으로 요청한 bounded delegation만 조건부로 사용합니다. |
| Formal Planning Workflow | 일반적으로 호출하지 않음. 독립적인 조사나 리뷰가 명시적으로 요청된 경우에만 조건부로 사용합니다. |
| Full Delivery Workflow | 조건부 호출. hybrid orchestration, 병렬 multi-agent, domain-owned Subtask, review, security review, integration 작업에 사용합니다. |

Superpowers `spawn_agent`를 실제로 호출하려면 사용자가 subagent, delegation, hybrid orchestration, parallel agent work를 명시적으로 요청해야 합니다.
workflow 모드만으로 자동 호출하지 않습니다.

구현 subagent에게는 가능한 한 작은 작업 카드를 전달합니다.

```text
docs/templates/SUBAGENT_TASK_CARD.template.md
```

이 카드는 subagent에게 다음을 알려줍니다.

- active workspace
- 역할
- 수정 가능한 경로
- 읽기 전용 참고 문서
- 금지 경로
- 작업 목표
- 완료 기준
- 검증 명령
- 맡은 결과와 체크포인트 기대치
- 중단해야 하는 조건

subagent는 스스로 작업 범위나 Git 동작, 검증 방식을 정하지 않습니다.
메인 Codex 세션이 orchestrator 역할을 하며, 필요한 범위를 정리한 task card를 만들어 subagent에게 전달합니다.

subagent에게 주는 작업은 작아야 하지만, 단순한 임시 도움으로 취급하지 않습니다.
task card에 맡은 결과와 체크포인트 기대치를 적고, subagent는 `Completed`, `Blocked`, `Needs Confirmation` 중 하나로 책임 있게 보고해야 합니다.
체크포인트는 강제 시간 제한이 아니라 계속 진행, 컨텍스트 보강, 범위 축소, escalation을 결정하는 시점입니다.
의미 있는 진전이 있고 범위가 유지된다면 같은 subagent가 맡은 결과를 끝까지 책임지도록 둡니다.

subagent를 호출하기 전에는 다음이 정해져 있어야 합니다.

- active workspace 또는 해당 없음
- subagent 역할
- 수정 가능한 경로
- 금지 경로
- 검증 명령 또는 `Needs Confirmation`
- 맡은 결과와 체크포인트 기대치
- 중단 조건
- Git 작업 여부
- 메인 Codex가 동시에 진행할 non-overlapping local task

구현 subagent는 Git 명령을 실행하지 않습니다.
작업 범위가 애매하거나 다른 workspace를 건드려야 한다면, 추측해서 진행하지 않고 `Needs Confirmation`으로 멈춰야 합니다.

subagent가 돌아오면 메인 Codex는 결과를 바로 완료로 보지 않고 다음을 확인합니다.

1. 상태가 `Completed`, `Blocked`, `Needs Confirmation` 중 무엇인지 확인합니다.
2. 변경 파일이 허용된 범위 안에 있는지 확인합니다.
3. 금지 경로, 다른 workspace, `.git/**`, 실제 env/secret을 건드리지 않았는지 확인합니다.
4. 완료 기준과 검증 결과를 확인합니다.
5. 필요한 경우 Review Agent, Security Review Agent, Git Steward로 넘깁니다.

자세한 실행 규칙은 [subagent-execution.md](../agent-rules/subagent-execution.md)를 따릅니다.
예시는 [LOGIN_SUBAGENT_FLOW.ko.md](./examples/LOGIN_SUBAGENT_FLOW.ko.md)를 참고합니다.

## agent가 피해야 할 것

agent는 다음을 하면 안 됩니다.

- 명시적으로 배정받지 않은 셸 운영 문서를 수정하기
- active workspace 밖을 수정하기
- 다른 `workspaces/*` 앱을 건드리기
- 실제 `.env`, `.env.local`, credential, local database, generated secret을 읽거나 쓰기
- Git 작업을 배정받지 않았는데 `.git/**`을 수정하기
- 관련 없는 동작을 바꾸기
- 필요한 검증을 건너뛰고 이유를 설명하지 않기

## 다음에 읽을 문서

일반 앱 작업:

```text
AGENTS.md
docs/agent-rules/workspaces.md
docs/templates/WORKSPACE_PROFILE.template.md
```

Formal Planning 또는 Full Delivery 작업:

```text
docs/agent-rules/workflow.md
docs/agent-rules/review.md
```

subagent 요청 시:

```text
docs/agent-rules/subagent-execution.md
docs/templates/SUBAGENT_TASK_CARD.template.md
docs/onboarding/examples/LOGIN_SUBAGENT_FLOW.ko.md
```

Hybrid/병렬 작업:

```text
docs/agent-rules/hybrid-orchestration.md
docs/templates/FULL_DELIVERY_START_CHECKLIST.md
docs/coordination/PARALLEL_WORKFLOW.md
docs/coordination/AGENT_SYNC_CHECKLIST.md
```

보안 민감 작업:

```text
docs/agent-rules/security-review.md
```

commit 작업:

```text
docs/agent-rules/commits.md
docs/skills/commit-workflow/SKILL.md
```

문서 검증:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-docs.ps1
```

이 명령은 필수 문서, 핵심 참조, task card 필드, Git Steward 규칙, Markdown links, 실제 `.env*` 추적 여부, secret-like values, Markdown trailing whitespace를 확인합니다.
