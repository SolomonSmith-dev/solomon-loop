# Task 1 report: POST /items with validation

## Sources
- Node.js v22.x API, `net.Server.listen` / `server.address()` (port 0 assigns an ephemeral port; `address().port` after listening): https://nodejs.org/docs/latest-v22.x/api/net.html, fetched 2026-11-03 via Context7 (`/websites/nodejs_latest-v22_x_api`).
- Node.js v22.x API, `node:http` createServer and request body `'data'`/`'end'` stream pattern: https://nodejs.org/docs/latest-v22.x/api/http.html and https://nodejs.org/docs/latest-v22.x/api/stream.html, fetched 2026-11-03 via Context7.
- Node.js v22.x API, `node:test` (`describe`/`it`/`before`/`after` hooks; CLI positional args are glob patterns; default file patterns include `**/test/**/*.js`): https://nodejs.org/docs/latest-v22.x/api/test.html, fetched 2026-11-03 via Context7.
- Built-ins verified by running: `node --version` (v22.23.1), `node --test test/` and bare `node --test` on the repo.

## Risk
Written to `.solomon-loop/todo-api/risk-task-1-draft.md` at 01:54:36 (before any src/test file existed; test file written afterward, store/server later still).

Review Focus items:
- Cross-owner read: not touched. No GET route in Task 1; Task 2 owns it.
- Missing or oversize title: touched. Tests: "400 when title is missing", "400 when title is empty", "400 when title is whitespace only", "400 when title is not a string", "400 when title is 121 characters", plus boundary "201 when title is 120 characters" and "trims the title".
- Missing owner header: touched. Test "401 when X-Owner is missing". In `src/server.js` the header check is the first statement in `handle()`, before body parsing or any store call.

Security/privacy surfaces:
- Ownership check on every item route: touched for POST. Owner comes only from X-Owner; a body `owner` field is ignored. Tests: "201 happy path" (owner equals header), "ignores owner field in body".
- Existence leak: not touched. No lookup by id in this task.
- Input validation on JSON bodies: touched. Tests: "400 when body is not JSON", "400 when title is not a string", "400 when title is 121 characters". Server also rejects non-object JSON (null, arrays) with 400 and caps bodies at 64 KiB (destroys the socket, no test; see concerns).

## Mocks
None. Tests start the real `node:http` server via `createServer().listen(0, '127.0.0.1')` and hit it with global `fetch`.

## Verification
`node --test test/ 2>&1 | tail -5`
```
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 95.721792
```
Counts from the same run (`grep -E "^# (tests|pass|fail)"`): `# tests 12`, `# pass 12`, `# fail 0`.

`node --check src/server.js && node --check src/store.js` -> `OK` (exit 0).

`git status --porcelain` after commit -> empty (`wc -l` = 0). Commit `7d3558e Add POST /items with title validation and owner header check`, no trailers.

121-char case explicitly: `ok 9 - 400 when title is 121 characters`.

## TDD Evidence
RED (test file written, no src): `node --test test/` ->
```
# Error: Cannot find module '.../todo-api/test'
...
# tests 1
# pass 0
# fail 1
```
and bare `node --test` -> `# tests 1 / # pass 0 / # fail 1` (post-items.test.js failed on missing `../src/server.js`).

GREEN (after store.js, server.js, test/index.js): `node --test test/` -> `# tests 12 / # pass 12 / # fail 0`.

## Files changed
- `src/store.js` (new): in-memory array, `createItem(owner, title)` returns `{id, owner, title, done: false}` with a `randomUUID()` id.
- `src/server.js` (new): exports `createServer()`; 401 without X-Owner first, JSON body parse with 400 on failure, title validation (string, trimmed 1..120), 201 with item, 404 for everything else, 500 guard on unexpected errors.
- `test/post-items.test.js` (new): 12 tests listed above.
- `test/index.js` (new, not in the plan's file list): 3-line entry importing `./post-items.test.js`. Required for the done check command to work at all on Node 22 (see concerns).
- `.solomon-loop/todo-api/risk-task-1-draft.md` written as instructed; `.solomon-loop/` otherwise untouched, `docs/` untouched, neither staged.

## Self-review
- Validation order: owner header, then JSON parse, then object shape, then title. No store access before all pass.
- Trimmed title is what gets stored (spec: "1 to 120 characters after trimming").
- Every error response is JSON `{"error": "..."}` including 401 and 404.
- `store.js` module-level array means state is shared across tests in one process; tests do not depend on list contents, so no cross-test coupling. Task 2's GET tests should use distinct owner names per test.

## Concerns
1. Plan/package.json assume Node 20 semantics for `node --test test/`. On Node 22.23.1 the positional arg is a glob; `test/` matches the directory and the runner executes it as a module, which fails with MODULE_NOT_FOUND regardless of implementation. I added `test/index.js` so the directory resolves to a module that imports the test files. Side effect: bare `node --test` matches `test/index.js` via `**/test/**/*.js` as well as the test file, so it reports every test twice (24 pass, 0 fail). Harmless but noisy. Task 2 must add its own `import './get-items.test.js'` line to `test/index.js` or its tests will not run under the done-check command. Cleaner fix is for the plan owner to change the script and done checks to `node --test "test/**/*.test.js"` and drop `test/index.js`; I did not touch docs/ or package.json per the brief.
2. The 64 KiB body cap destroys the socket rather than returning 413; untested. Outside the spec, mention only.
3. `X-Owner` with an empty or whitespace-only value is treated as missing (401). Spec says "no X-Owner header"; I read an empty value as equivalent. Flagging in case the reviewer wants empty-but-present to be accepted.
