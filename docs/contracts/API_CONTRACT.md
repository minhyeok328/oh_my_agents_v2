# API Contract

This document defines the **backend API surface** as a shared contract for hybrid or parallel work.

Scope note: this file is a shell-level reference or simulation contract.
For app-scoped work, freeze task-specific API contracts under `workspaces/<app-slug>/.agent/contracts/` unless the Task explicitly declares this file as the active contract location.

## Status

- Owner: Integration Coordinator Agent
- Review: Review Agent (+ Security Review Agent when relevant)
- Change policy: Contract changes must land **before** dependent implementation starts.

## Scope

- In scope:
  - Endpoints, methods, auth requirements, request/response shapes, error codes
  - Versioning and backward-compatibility expectations
  - Pagination, filtering, sorting conventions
  - Idempotency and side-effect rules
- Out of scope:
  - Implementation details (handlers, DB queries, UI state)
  - Real secrets, tokens, credentials (forbidden)

## Global Conventions

- Base URL:
  - `/api/v1` (contract base path)
- Authentication:
  - Bearer token in `Authorization: Bearer <token>`
  - Endpoints that are public must explicitly declare `Auth: Public`
- Content-Type:
  - Default: `application/json`
  - File upload endpoints may use `multipart/form-data` when explicitly documented

## Error Response Standard

Use one global format for all API errors:

- `{ "error": { "code": string, "message": string, "details"?: object } }`

Security note: error messages must not leak stack traces, internal paths, or secrets.

## Parallel Start Minimum (Frozen For Task 3)

These values are fixed to enable safe hybrid or parallel implementation. If a change is needed, update this contract first and re-run integration sync.

- Versioning: all endpoints must be under `/api/v1`
- Success response envelope:
  - `{ "data": <payload>, "meta"?: object }`
- Date-time format:
  - ISO8601 UTC string (example: `2026-05-27T08:41:00Z`)
- ID format:
  - string (do not expose numeric autoincrement assumptions across boundaries)
- Pagination default:
  - Query: `page`, `pageSize`
  - Response meta: `{ "page": number, "pageSize": number, "total": number }`

## Endpoint Catalog (Template)

For each endpoint, fill in:

- Name:
- Method + Path:
- Auth:
- Rate limit / abuse protections:
- Request:
  - Headers:
  - Query:
  - Body:
- Response (Success):
- Response (Errors):
  - 400:
  - 401:
  - 403:
  - 404:
  - 409:
  - 422:
  - 429:
  - 500:
- Notes:

### Example Placeholder

- Name: Needs Confirmation
- Method + Path: Needs Confirmation
- Auth: Needs Confirmation
- Request: Needs Confirmation
- Response: Needs Confirmation
