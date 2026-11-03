# Task 3 report: PATCH /items/:id marks an item done

Committed as `08d40db` on top of `308837e`. Suite: 25 pass, 0 fail.

## Sources
- Node.js v22 HTTP API, `message.method` / `message.url` / request body streaming (via Context7 `/websites/nodejs_latest-v22_x_api`, https://nodejs.org/docs/latest-v22.x/api/http.html), fetched 2026-11-03.
- Node.js v22 test runner, `describe` / `it` / `before` / `after` (via Context7, https://nodejs.org/docs/latest-v22.x/api/test.html), fetched 2026-11-03.

## Risk
Written to `.solomon-loop/todo-api/risk-task-3-draft.md` at 02:04:04, before any src or test edit (test file written 02:05+, src after RED). Note: `.solomon-loop/` is gitignored in this repo, so the draft stays on disk only, same as Tasks 1 and 2.

Review Focus:
- Cross-owner read: TOUCHED. PATCH returns the item in the 200 body, so an id-only lookup would both mutate and read another owner's item. Store lookup is scoped by owner. Test: `404 when the id belongs to another owner, and that item is unchanged`.
- Missing or oversize title: NOT TOUCHED. PATCH never reads or writes `title`; a `title` key in the body is ignored (`400 when done is missing` asserts the title is unchanged). POST validation unchanged, still covered by post-items.test.js.
- Missing owner header: TOUCHED. Header check in `handle()` runs before routing; PATCH inherits it. Test: `401 when X-Owner is missing` (also asserts the item was not modified).

Security/privacy surfaces:
- Ownership check on every item route: TOUCHED. `updateItem(owner, id, patch)` only matches `i.id === id && i.owner === owner`. Test: `404 when the id belongs to another owner`.
- Existence leak: TOUCHED. Unknown id and another owner's id both return 404 `{ error: 'not found' }`. Tests: `404 for an unknown id` and `404 when the id belongs to another owner` assert identical body.
- Input validation on JSON bodies: TOUCHED. Tests: `400 when done is not a boolean` (`"yes"`, `1`, `"true"`, `null`, `{}`), `400 when done is missing`, `400 when the body is not JSON or not an object` (`not json`, `[true]`, `null`, `"done"`). Body size cap (64 KiB) from Task 1 applies via the shared `readBody`.

## Mocks
None. Tests start the real server on port 0 and use global `fetch`.

## Verification
```
$ node --test test/ 2>&1 | tail -5
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 270.413417
$ node --test test/ 2>&1 | grep "^# pass"
# pass 25
$ node --check src/server.js && node --check src/store.js
(no output, exit 0)
$ git status --porcelain
(empty)
```
Manual acceptance against the real server (inline node script, not committed):
```
PATCH true      200 {"id":"...","owner":"manual","title":"t","done":true}
GET after       200 [{"id":"...","owner":"manual","title":"t","done":true}]
PATCH yes       400 {"error":"done must be a boolean"}
PATCH unknown   404 {"error":"not found"}
PATCH no owner  401 {"error":"X-Owner header required"}
PATCH /items    404 {"error":"not found"}
PATCH a/b       404 {"error":"not found"}
```

## TDD Evidence
RED (tests written and registered in test/index.js, before touching src):
```
    not ok 1 - 200 round trip: done true then false, visible in GET
    not ok 2 - 400 when done is not a boolean
    not ok 3 - 400 when done is missing
    not ok 4 - 400 when the body is not JSON or not an object
    ok 5 - 404 for an unknown id
    ok 6 - 404 when the id belongs to another owner, and that item is unchanged
    ok 7 - 401 when X-Owner is missing
# tests 25
# pass 21
# fail 4
```
Tests 5 to 7 passed before implementation because the catch-all 404 and the pre-routing 401 already produced the right status; they still guard the final implementation (5 and 6 also check the body is identical, 6 and 7 check the item is unchanged).

GREEN (after implementation):
```
# tests 25
# pass 25
# fail 0
```

## Files changed
- `src/store.js`: added `updateItem(owner, id, patch)`.
- `src/server.js`: new `PATCH /items/:id` route (single-segment match `/^\/items\/([^/]+)$/`, id URL-decoded); extracted the POST body parsing into `parseJsonObject(req)` shared by POST and PATCH (POST behaviour unchanged, its tests still pass).
- `test/patch-items.test.js`: 7 tests, owners suffixed `-patch`.
- `test/index.js`: added `import './patch-items.test.js';` per controller ruling.
- Commit `08d40db` "Add PATCH /items/:id to set done, scoped to the X-Owner header", no trailers.

## Self-review
- Deviation from the plan text: plan says `updateItem(id, patch)`; implemented `updateItem(owner, id, patch)` so ownership lives in the store like `createItem` and `listItems`, and so an id-only lookup can never leak or mutate another owner's item. Flagged in the risk draft before coding.
- `Object.assign(item, patch)` is generic, but the server only ever passes `{ done: boolean }`, so no other field can be written through this route.
- Only `done` is read from the body; extra keys (`title`, `owner`, `id`) are ignored rather than rejected. The plan did not ask for strict-key rejection.
- The `parseJsonObject` refactor touches the POST path; all 12 POST tests still pass and the error strings are unchanged.

## Concerns
- `.solomon-loop/` is gitignored, so the risk draft's mtime ordering is verifiable on disk but not in git history. Same situation as Tasks 1 and 2.
- Extra body keys on PATCH are silently ignored. If the reviewer wants 400 on unknown keys, that is a one-line check plus one test.

---

# Task 3 fix round 1 report

Committed as `19f0511` on top of `08d40db`. Suite: 26 pass, 0 fail. Finding fixed by dropping `decodeURIComponent` (reviewer's first option).

## Sources
- No new library or API docs needed for this fix. Prior sources (Node v22 http and test docs via Context7, fetched 2026-11-03) still apply.

## Risk delta
- Input validation surface: the path id is now used raw, never decoded. A malformed percent-encoding (`/items/%E0`) no longer throws `URIError` into the generic 500 handler; it falls through to the owner-scoped store lookup, matches nothing, and returns 404 `{ error: 'not found' }`, identical to the unknown-id and other-owner bodies. Ids are UUIDs so decoding was never needed, and a decoded `%2F` could not match an id either. Test: `404 for a malformed percent-encoded id, never 500`.
- Existence leak: unchanged, the new path still returns the same 404 body as the other not-found cases.
- Cross-owner read, missing title, missing owner header: unchanged.

## Mocks
None. Real server on port 0, global `fetch`.

## Verification
```
$ node --test test/ 2>&1 | tail -5
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 143.265292
$ node --test test/ 2>&1 | grep "^# pass"
# pass 26
$ node --check src/server.js && node --check src/store.js
(no output, exit 0)
$ git status --porcelain
(empty)
```

## TDD Evidence
RED (test added before the fix):
```
    not ok 6 - 404 for a malformed percent-encoded id, never 500
not ok 3 - PATCH /items/:id
# pass 25
# fail 1
```
GREEN (after removing `decodeURIComponent`):
```
# pass 26
# fail 0
```

## Files changed
- `src/server.js` line 81: `updateItem(owner, itemMatch[1], { done: parsed.body.done })` (decode call removed).
- `test/patch-items.test.js`: new test `404 for a malformed percent-encoded id, never 500` hitting `/items/%E0`.
- Commit `19f0511` "Return 404, not 500, for a malformed percent-encoded item id", no trailers.

## Self-review
- Chose removal over try/catch: less code, no behaviour lost since UUID ids contain no characters that need encoding.
- The `new URL(req.url, ...)` call that produces `url.pathname` does not decode percent sequences and does not throw on `%E0`, so no other path in `handle()` can reach the 500 handler from a malformed id. Confirmed by the passing test rather than by reading alone.
- All earlier PATCH, POST and GET tests still pass unchanged.

## Concerns
- None new. The generic `.catch` 500 handler remains the only backstop for unexpected throws; nothing in the request path currently throws on attacker-controlled input, but any future route that decodes user input should keep this finding in mind.
