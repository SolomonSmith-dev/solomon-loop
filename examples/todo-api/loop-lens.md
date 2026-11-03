# Loop lens: Todo API plan

Plan: docs/plans/todo-api.md. Written 2026-11-03. These four lists are the `[PLACEHOLDER]` values for worker-report.md and reviewer-challenge.md.

## Review Focus

- Cross-owner read: a GET with a different X-Owner value must never return another owner's items.
- Missing or oversize title: empty, whitespace-only, non-string, or 121-character titles must be rejected with 400.
- Missing owner header: any request without X-Owner must be rejected with 401 before any store access.

## Security/privacy surfaces

- Ownership check on every item route (X-Owner header is the only identity; nothing else may select items).
- Existence leak: a response that differs for "not found" versus "someone else's item".
- Input validation on JSON bodies (non-JSON, wrong types, oversize strings).

## Verify commands

- `node --test test/ 2>&1 | tail -5` (from Task 1)
- `node --check src/server.js && node --check src/store.js` (from Task 1)
- `git status --porcelain` must be empty after commit (from Task 1)

## Mock boundaries

- None: all integration is real (tests start the real node:http server on port 0).
