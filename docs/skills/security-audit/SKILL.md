---
name: security-audit
description: Use when the user asks for a security review or audit of the codebase. Requires Codex to read the relevant code first, focus on real vulnerabilities (authz, injection, secrets, sensitive-data exposure, etc.), report findings ordered by severity with concrete evidence, and make no code changes unless explicitly asked.
---

# Security Audit

Use this skill whenever the user asks to audit code for security issues. Inspect and report; do not fix unless asked.

- **Read-only: do not change code.** Propose remediations in words only.
- **Write the report in the user's language** (default Korean if unclear).
- **When to use a different skill:** for general bug/quality review use `code-review`; for a whole-codebase sweep use `frontend-qa` / `backend-qa`. Use this skill when the focus is security specifically.

## Required workflow

1. Read before judging:
   - Map the structure and read the security-relevant code: auth/session, input handling, DB access, file/IO, external calls, config, and crypto usage.
   - Use `git diff` to scope the audit to recent changes when that's the request.
   - Ground every finding in a real path; do not raise theoretical issues without evidence. Mark uncertain items as "needs verification".

2. Check the high-impact classes first:
   - AuthZ/AuthN: missing or inconsistent authorization on protected paths, broken access control, privilege escalation, IDOR.
   - Injection: SQL/NoSQL, command, template, path traversal; unsafe deserialization.
   - Secrets & config: hardcoded secrets/keys, secrets in logs or responses, insecure defaults, exposed debug endpoints.
   - Sensitive data: PII exposure, weak or home-rolled crypto, tokens/passwords handling, logging of sensitive values.
   - Input/output: missing validation, XSS/output encoding, SSRF, open redirects, unsafe file upload.
   - Dependencies & transport: known-vulnerable deps, missing TLS/cert checks, weak CORS, missing rate limiting.

3. Report findings ordered by severity:
   - For each finding include: severity, location (`path:line`), the vulnerability, how it could be exploited (concrete impact), and a remediation direction.
   - Use severities: `Critical`, `High`, `Medium`, `Low`. Order the whole report by severity.
   - Distinguish confirmed issues from "needs verification".

4. Do not change code:
   - Output a report only. Suggest remediations in words; make edits only if the user explicitly asks afterward.

## Output format

```markdown
# Security audit: <scope>

## Summary
- Overall risk posture and the most urgent issues.

## Findings (by severity)
### [Critical] <title> — `path:line`
- Vulnerability:
- Exploit / impact:
- Remediation:

### [High] ...

## Needs verification
- Items that couldn't be confirmed and what to check.

## Notes
- Areas reviewed and anything out of scope.
```
