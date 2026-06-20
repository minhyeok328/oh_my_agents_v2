# API Contract

This fixture represents a filled active API contract for `workspaces/sample-app`.

## Status

- Owner: Integration Coordinator Agent
- Review: Approved by Review Agent
- Change policy: Contract changes land before dependent implementation starts.

## Scope

- In scope:
  - Fixture endpoint method, path, auth, request shape, response shape, and error shape
- Out of scope:
  - Production credentials
  - Database schema changes

## Parallel Start Minimum

- Versioning: all endpoints are under `/api/v1`
- Success response envelope: `{ "data": <payload>, "meta"?: object }`
- Date-time format: ISO8601 UTC string
- ID format: string
- Error response envelope: `{ "error": { "code": string, "message": string, "details"?: object } }`

## Endpoint Catalog

### Fixture Status

- Name: Fixture Status
- Method + Path: GET `/api/v1/fixture/status`
- Auth: Bearer token required
- Request:
  - Headers: `Authorization`
  - Query: none
  - Body: none
- Response:
  - Success: `{ "data": { "status": "ok" } }`
  - Errors: standard error envelope
