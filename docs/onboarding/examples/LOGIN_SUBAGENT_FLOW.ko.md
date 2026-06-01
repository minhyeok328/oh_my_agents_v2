# 로그인 UI Subagent 작업 예시

이 문서는 `secret_agents_v2`에서 subagent 작업이 실제로 어떤 모양으로 흘러가는지 보여주는 예시입니다.
v2에서는 subagent를 단순 보조 작업자가 아니라 owned outcome, checkpoint, scope, verification을 가진 bounded worker로 다룹니다.
예시 앱은 `workspaces/my-app`에 있다고 가정합니다.

## 1. 사용자 요청

```text
workspaces/my-app에서 로그인 UI 오류 메시지를 개선해줘.
가능하면 subagent로 나눠서 진행해줘.
```

이 요청은 사용자가 subagent/delegation을 명시했으므로 Superpowers `spawn_agent`를 사용할 수 있습니다.
다만 자동으로 바로 호출하지 않고, 먼저 active workspace와 write scope를 확정합니다.

## 2. Orchestrator 판단

```text
Workflow mode: Default Workflow with explicit delegation approval
Active workspace: workspaces/my-app
Workspace profile: workspaces/my-app/.agent/profile.md
Primary local task: profile과 로그인 관련 파일 확인
Delegation: Frontend Implementation Agent worker 1개만 조건부 사용
Reason: UI 변경 범위가 작고 write scope가 분리 가능함
```

사용자가 subagent를 명시하지 않았다면 이 작업은 Default Workflow로 메인 Codex가 직접 처리합니다.
이 예시는 사용자가 subagent를 명시했고, 작업 범위가 독립적인 UI slice로 제한되므로 worker 호출이 가능합니다.

## 3. Workspace Profile 일부

```md
# Workspace Profile

## Identity

- App name: my-app
- App slug: my-app
- Active root: `workspaces/my-app`

## Commands

| Purpose | Command | Required? | Notes |
| --- | --- | --- | --- |
| Lint | `npm run lint` | Yes | active root 기준 |
| Unit tests | `npm test -- login` | Yes | 로그인 관련 테스트 |
| Build | `npm run build` | Yes | 최종 확인 |

## Implementation Boundaries

Allowed implementation roots:

- `workspaces/my-app/src/routes/login/**`
- `workspaces/my-app/src/components/auth/**`
- `workspaces/my-app/tests/login/**`

Forbidden paths:

- `.git/**`
- `.env`
- `.env.local`
- `workspaces/*` outside `workspaces/my-app`

## Git Pointer

- Git mode: app-owned
- Git root: `workspaces/my-app`
- Git steward: required before commit
```

## 4. Subagent Task Card 예시

```md
# Subagent Task Card

## Activation

- Active workspace: `workspaces/my-app`
- Workspace profile: `workspaces/my-app/.agent/profile.md`
- Task / Subtask: Login UI error message copy and state handling
- Role: Frontend Implementation Agent
- Workflow mode: Default Workflow with explicit delegation approval

## Required Read Context

- `AGENTS.md`
- `docs/agent-rules/context-budget.md`
- `docs/agent-rules/subagent-execution.md`
- `docs/agent-rules/workspaces.md`
- Workspace profile: `workspaces/my-app/.agent/profile.md`
- Spec/Subtask: inline task card only
- Contracts: not applicable unless API response expectations change

## Allowed Write Scope

- `workspaces/my-app/src/routes/login/**`
- `workspaces/my-app/src/components/auth/**`
- `workspaces/my-app/tests/login/**`

## Read-Only Context

- `docs/agent-rules/**`
- `workspaces/my-app/package.json`
- existing login-related files outside write scope, if needed for pattern inspection

## Forbidden Paths

- `docs/**` unless explicitly assigned
- `workspaces/*` outside `workspaces/my-app`
- `.git/**`
- real `.env`, `.env.local`, credentials, local databases, generated secrets
- backend/API files unless the orchestrator updates the task card

## Mission

- Improve login UI error message handling without changing backend API behavior.
- Preserve existing loading, success, and validation behavior.
- Add or update focused login UI tests if the app already has a matching test pattern.

## Acceptance Criteria

- Invalid credentials show the new user-facing error copy.
- Empty email/password validation still behaves as before.
- No backend/API contract is changed.
- Relevant tests or manual checks are reported.

## Ownership And Checkpoints

- Owned outcome: login UI error copy and state handling are updated within the allowed frontend scope.
- Checkpoint interval: report progress if the task runs long enough to need a status update.
- Continue when: changes stay inside the allowed scope and progress is visible.
- Re-scope or stop when: backend/API behavior must change, verification is blocked, or scope expands.
- Escalation owner: main Codex orchestrator.

## Verification

Run from `workspaces/my-app`.

- `npm test -- login`
- `npm run lint`

## Stop Conditions

Stop and report if:

- backend response shape must change
- write scope must expand outside allowed paths
- verification commands are missing or fail for unrelated reasons
- real env files or secrets are needed
- Git commands appear necessary

## Output Required

- Status: Completed | Blocked | Needs Confirmation
- Changed files:
- Summary:
- Verification:
- Contract impact:
- Security impact:
- Assumptions:
- Follow-up required:
  - Git steward required: yes/no/Needs Confirmation
  - Suggested commit target: shell/active app/none/Needs Confirmation
```

## 5. Superpowers 호출 예시

메인 Codex는 task card를 만든 뒤 worker subagent를 호출할 수 있습니다.
이때 같은 파일을 메인 Codex가 동시에 수정하지 않습니다.

```text
spawn_agent
- agent_type: worker
- fork_context: false
- message: 위 task card 전문 또는 요약된 task card
```

`wait_agent`는 바로 기다려야 다음 단계가 가능한 경우에만 사용합니다.
worker가 실행되는 동안 메인 Codex는 profile 확인, 관련 문서 업데이트, 검증 준비처럼 write scope가 겹치지 않는 작업을 진행합니다.

## 5-1. Worker 간 소통 원칙

Anchor: CROSS_AGENT_COMMUNICATION

여러 worker가 있는 작업에서도 worker끼리 비공개로 합의해서 shared behavior를 바꾸면 안 됩니다.
기본 소통 경로는 다음과 같습니다.

```text
Worker
→ Orchestrator 또는 Integration Coordinator
→ contract/task card 업데이트
→ 필요한 worker에게 다시 전달
```

예를 들어 backend worker가 API error code 변경이 필요하다고 판단하면, frontend worker에게 바로 맞추라고 말하지 않습니다.
먼저 `Needs Confirmation`으로 보고하고, Integration Coordinator가 contract를 갱신한 뒤 frontend task card를 다시 발행해야 합니다.

직접 worker-to-worker 질문은 orchestrator가 명시적으로 허용한 좁은 질문에만 사용합니다.
그 결과도 다시 orchestrator에게 보고해야 합니다.

## 6. Subagent Output 예시

```md
- Status: Completed
- Changed files:
  - `workspaces/my-app/src/routes/login/LoginForm.tsx`
  - `workspaces/my-app/tests/login/login-form.test.tsx`
- Summary:
  - Invalid credentials now show the approved error copy.
  - Existing empty-field validation behavior was preserved.
- Verification:
  - `npm test -- login`: passed
  - `npm run lint`: passed
- Contract impact:
  - none
- Security impact:
  - no auth/token/session logic changed
- Assumptions:
  - Existing API error code remains `INVALID_CREDENTIALS`.
- Follow-up required:
  - Git steward required: yes
  - Suggested commit target: active app
```

## 7. Orchestrator Integration 예시

메인 Codex는 subagent 완료를 곧바로 최종 완료로 보지 않습니다.

확인할 것:

- task card의 owned outcome과 checkpoint 기준이 지켜졌는가
- changed files가 task card의 allowed write scope 안에 있는가
- `docs/**`, 다른 `workspaces/*`, `.git/**`, 실제 env/secret을 건드리지 않았는가
- acceptance criteria를 만족하는가
- verification 결과가 충분한가
- Review Agent 또는 Security Review Agent가 필요한가
- Git Steward가 필요한가

통합 메모 예시:

```md
Status: Integrated
Scope check: passed
Ownership/checkpoints: passed
Verification: login tests and lint passed
Review required: no separate Review Agent for this small delegated Default Workflow task
Security review required: no auth/token/session behavior changed
Git steward: required before commit
Git target: active app
```

## 8. Git Steward Handoff 예시

구현 subagent는 Git 명령을 실행하지 않습니다.
commit이 필요하면 Git Steward가 `docs/agent-rules/commits.md`와 `commit-workflow`를 사용합니다.

```md
Git target: active app
Git root: workspaces/my-app
Files to inspect before staging:
- `workspaces/my-app/src/routes/login/LoginForm.tsx`
- `workspaces/my-app/tests/login/login-form.test.tsx`
Suggested commit:
- `fix(login): improve invalid credentials message`
Stop if:
- shell docs changes are mixed in
- another workspace has dirty files
- real env files or generated secrets appear
```

## 9. 흐름 평가

이 예시는 다음 원칙과 맞습니다.

- subagent는 사용자가 명시적으로 요청했기 때문에 호출 가능합니다.
- 사용자가 delegation을 명시했고, UI slice가 독립적입니다.
- task card가 active workspace, write scope, forbidden paths, ownership/checkpoints, verification, stop condition을 모두 포함합니다.
- worker는 Git을 하지 않고, Git Steward로 handoff합니다.
- orchestrator가 결과를 다시 검토하고 통합합니다.
- worker 간 shared behavior 변경은 orchestrator/Integration Coordinator를 통해 contract나 task card로 기록합니다.
