---
name: docs
description: Use when the user asks to generate, write, or update project documentation. Requires Codex to read the entire workspace folder structure and every file first, produce wiki-style docs split into small focused pages with a maintained index, and when docs already exist, diff the docs against the current code and update only what changed.
---

# Docs

Use this skill whenever the user asks to create or update project documentation.

- **This skill writes files: it creates/updates docs pages** (it does not change application code).
- **Write the docs in the user's language** (default Korean if unclear); keep code identifiers and paths as-is.

## Required workflow

1. Read the whole project before writing:
   - Map the full folder structure (e.g. `git ls-files`, directory listing, or glob).
   - Read every relevant file — source, config, schemas, scripts, templates, existing docs — to understand actual behavior, not just names.
   - Identify modules, entry points, data flow, external integrations, and conventions.
   - Do not document from filenames or assumptions; base every page on real code.

2. Decide: fresh generation or update:
   - No docs at all → generate fresh wiki-style docs (go to step 3).
   - Docs exist and are reasonably complete → treat this as an update, not a rewrite (go to step 4).
   - Docs exist but are empty, stub, or only partial (a few pages, missing parts) → do a hybrid: keep and update the usable pages (step 4) and generate the missing parts (step 3). Do not discard existing custom content.

3. Generate wiki-style docs (when none exist):
   - Split content into small, focused pages — one topic per page (e.g. overview, architecture, each module/feature, setup, configuration, API, data model, testing, deployment).
   - Prefer many short pages over a few long ones; keep each page scannable.
   - Maintain an index page (`docs/README.md` or `docs/index.md`) that links to every page, grouped logically.
   - Cross-link related pages with relative links so navigation works like a wiki.
   - Reference real paths (`path` or `path:line`) so docs stay traceable to code.
   - Mark anything uncertain as "needs verification" instead of guessing.

4. Update existing docs (when docs are present):
   - Read the current docs and compare them against the current code and structure.
   - Use `git diff` / `git diff --name-status` when changes are recent, and read changed files to see what behavior moved.
   - Identify drift: outdated descriptions, renamed/moved/removed items, new modules with no page, broken cross-links, stale index entries.
   - Edit only the pages affected by the changes; do not rewrite unchanged pages.
   - Add new pages for new scopes and remove/redirect pages for deleted ones.
   - Keep the index in sync: add, rename, reorder, or remove links to match the current page set.

5. Verify and summarize:
   - Check that the index links resolve and every page is reachable.
   - List which pages were created, updated, or removed, and why.
   - Note any areas that still need the user's input or verification.

## Conventions

- Group pages into numbered part folders (`00-overview/`, `01-getting-started/`, ...) so the wiki has a clear reading order.
- One topic per page; keep pages short and focused.
- `docs/README.md` is the wiki hub linking every part and page; large parts also get their own `README.md` sub-index.
- Every page is reachable from the hub or a part index — no orphan pages.
- Use relative links between pages and stable headings for anchors.
- Adapt the parts to the actual project: only create the folders that apply (e.g. drop `07-ai-modeling/` if there is no AI), and add new parts when a new area appears.
- Tie statements to real code paths so docs can be re-verified later.

## Suggested structure

Use numbered parts and group related pages. Keep page titles stack-neutral — name them by their role, not by the specific tool/framework — so the same structure works across different stacks. Tailor the parts to what the project actually contains.

```text
docs/
├── README.md                       # wiki hub: links to every part and page
├── 00-overview/
│   └── project-overview.md
├── 01-getting-started/
│   ├── development-environment.md
│   └── run-and-operations.md
├── 02-architecture/
│   ├── system-architecture.md
│   ├── directory-structure.md
│   └── data-flow.md
├── 03-frontend/
│   ├── README.md                   # part sub-index
│   ├── overview.md
│   ├── pages-and-routes.md
│   └── components.md
├── 04-backend/
│   ├── README.md
│   └── modules.md
├── 05-database/
│   └── schema-and-erd.md
├── 06-api/
│   └── api-reference.md
├── 07-ai-modeling/                 # only if the project has AI/LLM parts
│   ├── README.md
│   ├── model-pipeline.md           # the inference/processing flow, whatever the framework
│   └── retrieval-and-storage.md    # RAG / vector store, whatever the provider
└── 08-features/                    # one page per feature
    ├── README.md
    ├── feature-a.md
    └── feature-b.md
```

Name pages by role, not by technology. For example:

- `model-pipeline.md`, not `langgraph-flow.md`
- `retrieval-and-storage.md`, not `rag-pinecone.md`
- `modules.md`, not `django-apps.md`
- `api-reference.md`, not `rest-api.md` (drop to `graphql`/`grpc` specifics inside the page if needed)

Put the concrete stack/tool names inside the page content, not in the folder or file names.
