# Agent Rule Templates

Use this file only when the user explicitly asks for folder-level `AGENTS.md` files or a local folder truly needs persistent agent guidance.
Do not create folder-level AGENTS.md files by default.

Folder-level rules must specialize local ownership and verification. They must not weaken root `AGENTS.md`.
For app work, `profile.md` remains authoritative and `app-local AGENTS.md is optional`.

For workspace-scoped app work, prefer:

- `docs/templates/WORKSPACE_PROFILE.template.md` for app-local execution context.
- `docs/templates/SUBAGENT_TASK_CARD.template.md` for compact subagent launches.

## Generic Folder-Level AGENTS.md Template

```md
# AGENTS.md

This file defines local agent instructions for this folder.
It inherits the root `AGENTS.md`; local rules must not weaken root-level safety, workflow, review, or Workspace Boundary rules.

## Folder Purpose

- Describe the domain, feature, or module owned by this folder.

## Ownership Scope

- Owned files:
- Related files outside this folder:
- Explicitly out of scope:

## Local Rules

- Add folder-specific architecture, naming, dependency, or design rules.
- Do not repeat root-level rules unless a short reminder prevents misuse.

## Allowed Changes

- List changes agents may make in this folder.

## Forbidden Changes

- List folder-specific changes agents must not make.
- Do not weaken root-level forbidden actions.

## Local Verification

- List tests, checks, or manual verification required for this folder.

## Primary Agent Roles

- Primary:
- Review:
- Security-sensitive areas:

## Handover Notes

- Note local assumptions, known risks, or follow-up requirements for the next agent.
```

## Frontend React + Tailwind Template

```md
# AGENTS.md

This file defines local frontend agent instructions for this folder.
It inherits the root `AGENTS.md`; local rules must not weaken root-level safety, workflow, review, environment variable, or Workspace Boundary rules.

## Agent Focus

This folder is frontend-focused.
Agents working here must prioritize React component structure, user-facing behavior, UI state, accessibility, API integration, and TailwindCSS consistency.

## Project Stack

- Framework: React
- Styling: TailwindCSS
- Language: Use the project's existing JavaScript or TypeScript choice.
- Package Manager: Detect from lockfile before running commands.

## Folder Purpose

- Describe the frontend domain, feature, route, or UI module owned by this folder.

## Ownership Scope

- Owned files:
- Related backend/API contracts:
- Explicitly out of scope:

## Local Rules

- Follow existing React component patterns.
- Prefer small, focused components with clear props.
- Keep UI state local unless shared state is clearly required.
- Handle loading, error, empty, and success states.
- Treat client-side validation as UX support only; backend validation remains required.
- Do not expose server-only environment variables or secrets to client-side code.
- Use Tailwind utility classes consistently with existing design tokens and layout patterns.
- Avoid introducing a component library, state library, or styling framework unless explicitly approved.
- Preserve accessibility with semantic HTML, labels, focus states, keyboard navigation, and readable error text.

## Allowed Changes

- React components, hooks, client utilities, route/view files, styles, tests, and frontend documentation within this folder's scope.

## Forbidden Changes

- Do not change backend API behavior from frontend folders.
- Do not hardcode API secrets, tokens, or server-only environment variables.
- Do not introduce new global styling conventions without approval.

## Local Verification

- Use project-defined frontend commands when available.
- If commands are unknown, inspect package scripts before running tests.

## Primary Agent Roles

- Primary: Frontend Implementation Agent.
- Review: Review Agent with frontend UX, accessibility, state, and API-integration focus.
- Security-sensitive areas: client environment variables, auth UI, token handling, forms, redirects, user-generated content.
```

## Backend Django Template

```md
# AGENTS.md

This file defines local backend agent instructions for this folder.
It inherits the root `AGENTS.md`; local rules must not weaken root-level safety, workflow, review, environment variable, or Workspace Boundary rules.

## Agent Focus

This folder is backend-focused.
Agents working here must prioritize Django app boundaries, API contracts, validation, authentication, authorization, data integrity, error handling, observability, and server-side security.

## Project Stack

- Framework: Django
- API Layer: Use the project's existing Django API pattern, such as Django REST Framework if already present.
- Database: Use the configured project database.
- Package Manager: Detect from project files before running commands.

## Folder Purpose

- Describe the backend domain, Django app, API area, or service module owned by this folder.

## Ownership Scope

- Owned files:
- Related frontend/API consumers:
- Explicitly out of scope:

## Local Rules

- Follow Django app boundaries and existing project structure.
- Keep business logic out of views when it grows; prefer services, selectors, forms, serializers, managers, or existing local patterns.
- Validate all user input server-side.
- Enforce authentication and authorization server-side.
- Never log passwords, tokens, API keys, secrets, or sensitive user data.
- Use Django migrations for model changes and review migrations before applying them.
- Use Django settings and environment variables safely; never hardcode secrets in settings or source code.
- Use Django's built-in password hashing and security mechanisms.
- Consider rate limiting or abuse protection for authentication-sensitive or costly endpoints.
- Return consistent error responses without leaking stack traces or internal details.

## Allowed Changes

- Django apps, models, migrations, views, serializers/forms, services, selectors, permissions, tests, and backend documentation within this folder's scope.

## Forbidden Changes

- Do not change frontend behavior from backend folders unless explicitly scoped.
- Do not bypass authentication, authorization, validation, or migration review.
- Do not commit real `.env` files, credentials, local databases, or generated secrets.

## Local Verification

- Use project-defined backend commands when available.
- If commands are unknown, inspect project scripts or Django management configuration before running tests.

## Primary Agent Roles

- Primary: Backend Implementation Agent.
- Review: Review Agent with backend correctness, API contract, data integrity, and security focus.
- Security-sensitive areas: settings, environment variables, authentication, authorization, permissions, password handling, tokens, sessions, migrations, file access, external APIs.
```
