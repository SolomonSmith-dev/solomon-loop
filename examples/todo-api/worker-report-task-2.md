# Task 2 report: GET /items scoped to the X-Owner header

Commit: `94e9a5f Add GET /items scoped to the X-Owner header`. Suite: 18 pass, 0 fail (was 12 after Task 1; task required >= 10).

## Sources
- Node.js v22 `node:test` API (describe/it/before/after hooks, `node --test` glob handling): https://nodejs.org/docs/latest-v22.x/api/test.html via Context7 `/websites/nodejs_latest-v22_x_api`, fetched 2026-11-03.
- Node.js v22 `node:http` `message.headers` (header names lower-cased, so `req.headers['x-owner']` is correct) and `message.url` parsing with `new URL()`: https://nodejs.org/docs/latest-v22.x/api/http.html via Context7, fetched 2026-11-03.

## Risk
Written to `.solomon-loop/todo-api/risk-task-2-draft.md` at 01:59:33, before the first src/test edit (test files 01:59:52, src files 02:00:00; mtimes verified with `stat`).

Review Focus:
- Cross-owner read: TOUCHED, the core of the task. `listItems(owner)` filters on exact owner string; the route passes only the header value. Test: `GET /items > owner A never sees owner B items`.
- Missing or oversize title: NOT TOUCHED. GET has no body; POST validation unchanged and still covered by test/post-items.test.js.
- Missing owner header: TOUCHED. The pre-routing header check in `handle()` rejects before any store call. Tests: `401 when X-Owner is missing`, `401 when X-Owner is blank`.

Security/privacy surfaces:
- Ownership check on every item route: TOUCHED. Header is the only selector. Tests: `owner A never sees owner B items` and `ignores owner query param, header is the only identity` (`/items?owner=dave-get` with `X-Owner: eve-get` returns `[]`).
- Existence leak: NOT TOUCHED. GET /items is a list, returns an array (possibly empty), never a per-id lookup. PATCH is Task 3.
- Input validation on JSON bodies: NOT TOUCHED. GET reads no body.

## Mocks
None. Every test starts the real `createServer()` on port 0 and uses `fetch` against it.

## Verification
```
$ node --test test/ 2>&1 | tail -5
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 179.309375

$ node --test test/ 2>&1 | grep "^# pass"
# pass 18

$ node --check src/server.js && node --check src/store.js
syntax ok

$ git status --porcelain
 M docs/plans/todo-api.md
```
That remaining entry is NOT mine: it is the controller's `[x]` mark on Task 1 in docs/plans/todo-api.md, already in the tree before this task began. My brief forbids touching docs/, so I left it uncommitted. Everything from this task is committed; see Concerns.

Manual acceptance probe against the real server (the plan's "Fails when" condition): alice POSTs one item, then:
```
bob sees: [] | alice count: 1 | no header: 401
```

## TDD Evidence
RED (tests written, no implementation):
```
not ok 2 - GET /items
  error: '4 subtests failed'
# tests 18
# pass 14
# fail 4
```
The 4 failures were the four 200-path tests (404 returned); the two 401 tests passed already because the header check predates routing.

GREEN (after `listItems` and the GET route):
```
# tests 18
# pass 18
# fail 0
```

## Files changed
- `src/store.js`: added `export function listItems(owner)` returning `items.filter(i => i.owner === owner)` (insertion order, newest last).
- `src/server.js`: import `listItems`; new branch `GET /items` returning 200 with `listItems(owner)`, placed after the 401 check and before the POST branch.
- `test/get-items.test.js`: new, 6 tests (empty list, insertion order after POST, cross-owner isolation, query-param ignored, 401 missing header, 401 blank header). Owner names carry a `-get` suffix per the controller ruling on the shared module-level store.
- `test/index.js`: appended `import './get-items.test.js';` per the controller ruling.
- `.solomon-loop/todo-api/risk-task-2-draft.md`: risk draft (gitignored, as the directory is).

## Self-review
- 401 is enforced before any store access for GET: the owner check is the first statement in `handle()`, before URL parsing and routing. Confirmed by code position, not just by test.
- Owner identity comes only from the header; the test with `?owner=` on the URL proves the query string is ignored. No body is read on GET, so no body field can select items either.
- `listItems` returns the same object references held in the store. That is fine for JSON serialisation today, but Task 3's PATCH will mutate those objects; that is the intended semantics (a later GET should reflect `done`), so I did not copy.
- Insertion order assertion uses `deepEqual([first, second])` on the full objects, which also pins id/owner/title/done shape in list output.
- No new dependencies; `package.json` untouched.

## Concerns
1. `git status --porcelain` is not empty because of the controller's pre-existing, uncommitted `[x]` edit to `docs/plans/todo-api.md`. The controller should commit that itself (and add Task 2's `[x]`) rather than have a worker touch docs/.
2. The store is a process-wide singleton, so test files cannot run isolated; the `-get` owner-suffix convention is a fragile fix. If a future task adds a `reset()` or lets `createServer()` take a store instance, cross-file pollution risk disappears. Not in scope for Task 2.
3. `Content-Type` is `application/json` without `; charset=utf-8`. The test asserts the exact string, so if Task 3 changes `send()` to add a charset the GET test will need updating. Flagging so the reviewer does not read that assertion as a bug.
