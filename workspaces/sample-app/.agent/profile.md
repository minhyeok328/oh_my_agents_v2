# Workspace Profile

This file defines the app-local execution context for agents working inside this app.
This `profile.md is authoritative` for app-local execution context.
An `app-local AGENTS.md is optional`; this sample app does not need one.

## Identity

- App name: Sample App
- App slug: sample-app
- Active root: workspaces/sample-app
- Profile owner: oh_my_agents_v2 fixture
- Last reviewed: 2026-06-20

## Stack Snapshot

- Primary language: JavaScript
- Framework: none
- Package manager: npm
- Runtime version: Node.js LTS
- Important lockfiles: none

## Commands

Run commands from the active root unless a command states otherwise.

| Purpose | Command | Required? | Notes |
| --- | --- | --- | --- |
| Install | npm install | No | Fixture has no external dependencies. |
| Lint | Not configured | No | Not needed for this fixture. |
| Unit tests | npm.cmd test | Yes | Uses the package script in `package.json`. |
| Integration tests | Not configured | No | Not needed for this fixture. |
| Build | Not configured | No | Not needed for this fixture. |
| Typecheck | Not configured | No | Not needed for this fixture. |
| Manual smoke | npm.cmd test | Yes | Confirms the workspace command path works in PowerShell. |

## Environment

- Env example path: none
- Dummy keys required:
  - none
- Real env files agents must not read:
  - `.env`
  - `.env.local`

## Implementation Boundaries

Allowed implementation roots:

- `workspaces/sample-app/src/**`
- `workspaces/sample-app/tests/**`

Forbidden paths:

- `.git/**`
- `.env`
- `.env.local`
- `workspaces/*` outside `workspaces/sample-app`

Generated or heavy paths to avoid:

- `node_modules/**`
- `coverage/**`

## Contracts

- Contract directory: workspaces/sample-app/.agent/contracts
- Active contract naming pattern: `*_CONTRACT.md`
- Shared interface contracts required before hybrid or parallel work:
  - API: workspaces/sample-app/.agent/contracts/API_CONTRACT.md
  - DB: not applicable
  - Frontend/backend: not applicable
  - Infra: not applicable

## Verification Notes

- Minimal smoke verification: npm.cmd test
- Full verification: npm.cmd test
- Known flaky or long-running checks: none

## Git Pointer

This profile only records Git context. Load Git rules separately before commit, branch, push, or PR work.

- Git mode: shell-owned
- Git root: repository root
- Git steward: required before commit

## Agent Notes

- Local architecture notes: This is a tracked fixture, not a production app.
- Known risks: Fixture must not include real secrets or generated dependency folders.
- Open `Needs Confirmation` items: none
- Optional app-local AGENTS.md notes: not needed
