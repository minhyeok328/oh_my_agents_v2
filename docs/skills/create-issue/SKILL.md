---
name: create-issue
description: Use when the user wants to draft a git/GitHub issue (bug, feature, chore, etc.) from a description or the codebase. Requires Codex to read the relevant workspace files first, classify the issue type, and output a well-structured, copy-ready Markdown issue. Output Markdown only — never create issues remotely.
---

# Create Issue

Use this skill whenever the user asks to draft an issue. It produces one clean, copy-ready Markdown issue (or a few, if the request clearly covers separate concerns). For breaking an epic into features use `epic-to-features`; for breaking a feature into tasks use `feature-to-tasks`.

- **Copy-only: do not create code or issues remotely.**
- **Write the issue in the user's language** (default Korean if unclear); keep the `type(scope): summary` title and code identifiers as-is.

## Required workflow

1. Read before writing:
   - List the folder structure (e.g. `git ls-files`, directory listing, or glob) and read the files the issue touches — not just filenames.
   - Run `git status --short` / `git diff --name-status` when the issue concerns recent or pending changes.
   - Ground the issue in real code paths; do not invent details. Mark unknowns as "needs verification".
   - If the request is too vague to write a useful issue, ask one or two clarifying questions first.

2. Classify the issue:
   - Pick a type: `bug`, `feat`, `chore`, `refactor`, `docs`, `test`, or `perf`.
   - If the request actually contains multiple unrelated concerns, output one issue per concern; otherwise keep it to a single focused issue.

3. Write the issue with the recommended structure (copy-ready Markdown):
   - Output each issue in its own fenced code block so it can be pasted directly.
   - Title: `type(scope): summary` (e.g. `bug(checkout): total ignores discount code`).
   - Body sections (include what applies to the type):
     - `## Summary` — what and why, in plain language.
     - `## Context` — relevant files/paths (`path:line` when useful) and current behavior.
     - For a **bug**, add:
       - `## Steps to reproduce` — numbered steps.
       - `## Expected vs actual` — what should happen vs what happens.
     - For a **feature/chore/refactor**, add:
       - `## Proposed approach` — direction at a high level (no code changes).
     - `## Acceptance criteria` — a checklist (`- [ ]`) defining done.
     - Optional when relevant: `## Out of scope`, `## Risks`, `## Labels`, `## References`.

4. Output copy-ready Markdown only — never create issues:
   - Only produce Markdown for the user to copy into their tracker.
   - Do not run `gh issue create`, push, or otherwise create issues remotely, even if asked — this skill is copy-only.

5. Summarize at the end:
   - Note the issue type(s) produced and anything still needing the user's input.

## Examples

Bug:

````text
```markdown
# bug(checkout): order total ignores applied discount code

## Summary
Applying a valid discount code does not reduce the order total, so users are
charged the full price.

## Context
- `services/cart.py:88` — `calculate_total()` sums line items but never reads `cart.discount`.
- Discount is stored correctly on the cart (`models/cart.py:21`).

## Steps to reproduce
1. Add an item to the cart.
2. Apply a valid discount code.
3. Go to checkout.

## Expected vs actual
- Expected: total reflects the discount.
- Actual: total is unchanged.

## Acceptance criteria
- [ ] Valid discount reduces the total
- [ ] Invalid/expired codes are rejected with a message
- [ ] Test covers discounted and non-discounted totals

## Labels
bug, checkout
```
````

Feature:

````text
```markdown
# feat(search): add typo-tolerant search

## Summary
Misspelled queries return no results. Add fuzzy matching so users still find
products despite minor typos.

## Context
- `services/search.py:40` — exact-match only.

## Proposed approach
- Add a fuzzy matching layer with a fallback to exact match when unavailable.

## Acceptance criteria
- [ ] "ipone" returns "iPhone" results
- [ ] Exact queries are unchanged

## Labels
feat, search
```
````
