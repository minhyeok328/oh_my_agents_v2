# Frontend ↔ Backend Contract

This document binds the API surface to frontend expectations so hybrid or parallel work cannot diverge.

Scope note: this file is a shell-level reference or simulation contract.
For app-scoped work, freeze task-specific frontend/backend contracts under `workspaces/<app-slug>/.agent/contracts/` unless the Task explicitly declares this file as the active contract location.

## Status

- Owner: Integration Coordinator Agent
- Contributors: Frontend Implementation Agent, Backend Implementation Agent
- Review: Review Agent (+ Security Review Agent when relevant)

## Scope

- In scope:
  - Routes/pages ↔ API endpoints mapping
  - Auth state model on the client (logged-in vs authorized)
  - Error/empty/loading UX requirements that depend on API behavior
  - Data shapes used directly by UI components
- Out of scope:
  - UI styling specifics (unless it affects payload expectations)
  - Backend internal storage design (covered by DB schema contract)

## Shared Vocabulary

- "Authentication": token validity (who the user is)
- "Authorization": access to a resource after authentication
- "User-visible error": message shown to user (must not expose internals)

## Data Shape Guarantees

Frozen baseline for hybrid or parallel implementation:

- API payload keys: `camelCase`
- Date-time fields: ISO8601 UTC strings
- IDs in frontend models: `string`
- Error shape consumed by frontend:
  - `{ "error": { "code": string, "message": string, "details"?: object } }`

## Auth UX Contract

Frozen baseline for hybrid or parallel implementation:

- `401 Unauthorized`:
  - treat as authentication failure
  - clear auth state and redirect to login page
- `403 Forbidden`:
  - authenticated but not authorized
  - keep session, show permission-denied UI
- Login redirect rule:
  - after successful login, return to original intended route when available
- Refresh flow:
  - Needs Confirmation (token refresh endpoint and trigger policy)

## Parallel Start Minimum (Frozen For Task 3)

- Frontend must not assume undocumented fields from backend.
- Backend must include only contract-defined fields for UI-critical endpoints.
- Any key renaming or error-shape change requires contract update + sync before merge.

## Endpoint Usage Matrix (Template)

Fill for each UI unit:

- Page/Feature:
- Calls endpoint(s):
- Required fields:
- Error handling:
- Loading state:
- Empty state:
- Accessibility considerations:

### Example Placeholder

- Page/Feature: Needs Confirmation
- Calls endpoint(s): Needs Confirmation
