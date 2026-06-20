# Workspace 설정 요청 가이드

이 문서는 사용자가 실제 프로젝트를 `workspaces/` 아래에 넣은 뒤, Codex에게 어떤 식으로 요청하면 되는지 설명합니다.

## 언제 사용하나요?

다음 상황에서 사용합니다.

- 새 프로젝트 폴더를 `workspaces/<app-slug>/` 아래에 넣은 직후
- 아직 `workspaces/<app-slug>/.agent/profile.md`가 없는 경우
- 아직 `workspaces/<app-slug>/.agent/manifest.yml`이 없는 경우
- Spec을 바탕으로 작업을 시작하기 전에 workspace 운영 파일과 검증 기준을 먼저 잡고 싶은 경우

## 핵심 흐름

현재 시스템은 프로젝트 폴더만 보고 자동으로 운영 파일을 생성하지는 않습니다.
대신 사용자가 active workspace와 요청을 명시하면, agent가 프로젝트 구조를 읽고 필요한 운영 파일을 작성한 뒤 검증할 수 있습니다.

기본 흐름은 다음과 같습니다.

```text
1. 사용자가 프로젝트 폴더를 넣음
   workspaces/my-app/

2. 사용자 또는 agent가 profile 작성
   workspaces/my-app/.agent/profile.md

3. agent가 manifest 작성
   workspaces/my-app/.agent/manifest.yml

4. 검증 실행
   check-workspace-profile.ps1
   check-workspace-manifest.ps1

5. Spec / Task / Card / Contract 작업 진행
```

## 사용자가 이렇게 요청하세요

프로젝트를 넣은 뒤 Codex에게 아래처럼 요청하면 됩니다.

```text
Active workspace: workspaces/my-app

이 프로젝트에 맞게 .agent/profile.md랑 .agent/manifest.yml 만들고 검증해줘.
그 다음 이 spec 기준으로 작업 준비해줘.

Spec:
docs/specs/MY_FEATURE.md
```

Spec 파일이 아직 없고, 먼저 workspace 운영 파일만 만들고 싶다면 이렇게 요청합니다.

```text
Active workspace: workspaces/my-app

이 프로젝트 구조를 읽고 .agent/profile.md랑 .agent/manifest.yml 만들고 검증해줘.
아직 구현은 하지 말고, 부족한 정보가 있으면 Needs Confirmation으로 알려줘.
```

## agent가 해야 하는 일

이 요청을 받으면 agent는 보통 다음 순서로 진행합니다.

1. `workspaces/my-app/`가 실제로 존재하는지 확인합니다.
2. 프로젝트의 package manager, runtime, lockfile, test/build/lint 명령을 확인합니다.
3. `workspaces/my-app/.agent/profile.md`를 작성합니다.
4. `workspaces/my-app/.agent/manifest.yml`을 작성합니다.
5. 필요한 경우 `workspaces/my-app/.agent/contracts/`를 만들고 contract 초안을 준비합니다.
6. 아래 검증을 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-workspace-profile.ps1 -ProfilePath workspaces/my-app/.agent/profile.md
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-workspace-manifest.ps1 -ManifestPath workspaces/my-app/.agent/manifest.yml
```

Spec, task card, active contract까지 준비한 경우에는 추가로 readiness 검증을 실행합니다.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-delivery-readiness.ps1
```

## profile.md와 manifest.yml의 역할

두 파일은 서로 대체 관계가 아닙니다.

```text
profile.md   = 사람이 읽는 workspace 운영 문서
manifest.yml = 기계가 읽는 핵심 운영 선언
PS1 scripts  = profile/manifest/contract/task 상태 검증
```

`profile.md`에는 설명, 주의사항, 판단 맥락을 적습니다.
`manifest.yml`에는 active root, profile path, contract root, verification command, Git mode처럼 스크립트가 안정적으로 검사해야 하는 값만 적습니다.

## agent가 추측하면 안 되는 것

다음 정보가 불명확하면 agent는 임의로 결정하지 않고 `Needs Confirmation`으로 멈춰야 합니다.

- 실제 test/build/lint 명령
- 어떤 경로까지 수정 가능한지
- real `.env` 파일을 읽어야 하는지 여부
- 어느 contract가 active contract인지
- Git root나 Git Steward 필요 여부
- Spec의 acceptance criteria

## 완료 기준

workspace 설정 요청은 최소한 다음이 완료되어야 끝난 것으로 봅니다.

- `workspaces/<app-slug>/.agent/profile.md`가 존재합니다.
- `workspaces/<app-slug>/.agent/manifest.yml`이 존재합니다.
- profile과 manifest가 같은 active root, contract root, verification command를 가리킵니다.
- profile 검증이 통과합니다.
- manifest 검증이 통과합니다.
- 부족한 정보가 있으면 `Needs Confirmation`으로 명시되어 있습니다.

## 관련 문서

- [사용 설명서](./USER_GUIDE.ko.md)
- [Workspace 안내](../../workspaces/README.md)
- [Workspace Profile 템플릿](../templates/WORKSPACE_PROFILE.template.md)
- [Workspace 규칙](../agent-rules/workspaces.md)
