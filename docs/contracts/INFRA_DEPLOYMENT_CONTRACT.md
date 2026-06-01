# Infrastructure / Deployment Contract

This document defines the infrastructure and deployment interface for hybrid or parallel work.

Scope note: this file is a shell-level reference or simulation contract.
For app-scoped work, freeze task-specific infrastructure contracts under `workspaces/<app-slug>/.agent/contracts/` unless the Task explicitly declares this file as the active contract location.

## Status

- Owner: Infrastructure Implementation Agent + Integration Coordinator Agent
- Review: Review Agent (+ Security Review Agent when relevant)

## Scope

- In scope:
  - Environments (dev/staging/prod) naming and invariants
  - Build artifacts and entrypoints
  - Runtime configuration keys (names only; never real values)
  - CI/CD pipeline stages and required checks
  - Service dependencies (DB, cache, queues) at a contract level
- Out of scope:
  - Application feature behavior (backend/frontend responsibility)
  - Any real secrets (forbidden)

## Environment Model

- Environments:
  - `local`, `staging`, `production`
- Required env vars (names only):
  - Use `.env.example` for local dummy structure

## Deployment Shape

Frozen baseline for hybrid or parallel implementation:

- Containerization: Docker required
- Process model: single deployable app service + managed database
- Hosting provider: Needs Confirmation (provider-specific details can stay open)

## CI/CD Stages (Template)

- Lint:
  - required
- Typecheck:
  - required when type system is present
- Unit tests:
  - required
- Integration tests:
  - required for contract-critical paths
- Security scans:
  - required for dependencies and secret leakage checks
- Build:
  - required
- Deploy:
  - required only after all prior stages pass

## Operational Guarantees

- Logging policy: never log secrets/tokens/passwords
- Timeout/retry policy for external calls:
  - timeout required
  - bounded retry with backoff required
- CORS/CSRF policy:
  - must be explicit and least-privilege
  - wildcard production origin is forbidden
