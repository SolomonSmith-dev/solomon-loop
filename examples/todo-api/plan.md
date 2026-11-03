# Todo API plan

Spec: docs/spec/todo-api.md

Rules for every brief: zero runtime dependencies; `node --test test/` is the suite; tests start the real server on port 0; commit after each task with a plain message, no attribution trailers; use `/bin/cp -f` and `/bin/rm -f`, never bare `cp` or `rm`.

## Review Focus

- Cross-owner read: a GET with a different X-Owner value must never return another owner's items.
- Missing or oversize title: empty, whitespace-only, non-string, or 121-character titles must be rejected with 400.
- Missing owner header: any request without X-Owner must be rejected with 401 before any store access.

## Tasks

### Task 1: POST /items with validation [x]
Owner: Claude (subagent)
Files: src/server.js, src/store.js, test/post-items.test.js
Steps:
1. Write src/store.js: in-memory array, `createItem(owner, title)` returns `{id, owner, title, done: false}`.
2. Write src/server.js exporting `createServer()` (node:http). Parse JSON bodies; reject non-JSON with 400. Require X-Owner, else 401.
3. POST /items validates title (string, trimmed length 1 to 120), returns 201 with the item, 400 with `{"error": "..."}` otherwise.
4. Tests in test/post-items.test.js cover: 201 happy path, 400 for missing title, empty title, 121-char title, non-JSON body, 401 for missing X-Owner.
Done check: `node --test test/ 2>&1 | tail -5` shows `# fail 0` and at least 6 passing tests
Fails when: any test fails, or the 121-character title returns 201

### Task 2: GET /items scoped to the X-Owner header [x]
Owner: Claude (subagent)
Files: src/server.js, src/store.js, test/get-items.test.js
Steps:
1. Add `listItems(owner)` to src/store.js returning only that owner's items in insertion order.
2. GET /items in src/server.js returns 200 with the calling owner's items as a JSON array. 401 without X-Owner.
3. Tests in test/get-items.test.js cover: empty list for a new owner, items appear after POST, owner A never sees owner B's items, 401 without X-Owner.
Done check: `node --test test/ 2>&1 | tail -5` shows `# fail 0` and at least 10 passing tests
Fails when: any test fails, or a GET with X-Owner: bob returns an item created with X-Owner: alice

### Task 3: PATCH /items/:id marks an item done [x]
Owner: Claude (subagent)
Files: src/server.js, src/store.js, test/patch-items.test.js
Steps:
1. Add `updateItem(id, patch)` to src/store.js returning the updated item or null when no item has that id.
2. PATCH /items/:id in src/server.js reads `{"done": true|false}` from the JSON body, applies it, returns 200 with the item. 400 when done is not a boolean or the body is not JSON. 404 when no item has that id. 401 without X-Owner.
3. Tests in test/patch-items.test.js cover: done true then false round trip, 400 for non-boolean done, 404 for unknown id, 401 without X-Owner.
Done check: `node --test test/ 2>&1 | tail -5` shows `# fail 0` and at least 14 passing tests
Fails when: any test fails, or PATCH with `{"done": "yes"}` returns 200
