# Workspace Profile

This file defines the app-local execution context for agents working inside this app.
Place the filled profile at `workspaces/<app-slug>/.agent/profile.md`.
This `profile.md is authoritative` for app-local execution context.
An `app-local AGENTS.md is optional`; add one only when the app needs persistent local guidance that should be read after the root rules.

## Identity

- App name:
- App slug:
- Active root: `workspaces/<app-slug>`
- Profile owner:
- Last reviewed:

## Stack Snapshot

- Primary language:
- Framework:
- Package manager:
- Runtime version:
- Important lockfiles:

## Commands

Run commands from the active root unless a command states otherwise.

| Purpose | Command | Required? | Notes |
| --- | --- | --- | --- |
| Install |  | Yes/No |  |
| Lint |  | Yes/No |  |
| Unit tests |  | Yes/No |  |
| Integration tests |  | Yes/No |  |
| Build |  | Yes/No |  |
| Typecheck |  | Yes/No |  |
| Manual smoke |  | Yes/No |  |

## Environment

- Env example path:
- Dummy keys required:
  -
- Real env files agents must not read:
  - `.env`
  - `.env.local`

## Implementation Boundaries

Allowed implementation roots:

-

Forbidden paths:

- `.git/**`
-

Generated or heavy paths to avoid:

-

## Contracts

- Contract directory:
- Active contract naming pattern:
- Shared interface contracts required before hybrid or parallel work:
  - API:
  - DB:
  - Frontend/backend:
  - Infra:

## Verification Notes

- Minimal smoke verification:
- Full verification:
- Known flaky or long-running checks:

## Git Pointer

This profile only records Git context. Load Git rules separately before commit, branch, push, or PR work.

- Git mode: app-owned | shell-owned | none | submodule | Needs Confirmation
- Git root:
- Git steward: required before commit | not required | Needs Confirmation

## Agent Notes

- Local architecture notes:
- Known risks:
- Open `Needs Confirmation` items:
- Optional app-local AGENTS.md notes:
