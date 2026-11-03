# Review: Task 2, GET /items scoped to X-Owner (commit 94e9a5f)

Verdict: PASS. No Critical or Important findings. Three Minor.

## Part 1: Spec compliance

Diff does exactly steps 1 to 3 and nothing more. `listItems(owner)` is an exact-match filter over the insertion-ordered array (newest last, matches spec). GET /items returns 200 with a JSON array; the 401 check sits at the top of `handle()` at src/server.js:41-44, before URL parsing, routing and any store call. Tests cover all four required cases plus two extras (query param ignored, blank header). The test/index.js import line is within the controller ruling.

Done check, run by me:
```
node --test test/ 2>&1 | tail -5  ->  # fail 0 (cancelled 0, skipped 0, todo 0)
# pass 18   (required >= 10)
node --check src/server.js && node --check src/store.js  ->  syntax ok
```

## Part 2: Code quality

Findings:
- Minor | src/server.js:41-49 | Identity is not normalized by the server itself: the 401 check uses `owner.trim()` but the store receives the raw `owner`. Today unreachable in practice because Node's HTTP parser and undici both strip OWS from header values (my probes confirmed `"alice "` and `"alice\t"` arrive as `"alice"`), so no inconsistency surfaces. Still, the identity key should be derived once (`const owner = raw.trim()`) rather than relying on the parser.
- Minor | src/server.js:48 | HEAD /items returns 404 (and 401 without header). Spec only defines GET, so this is not a violation; noting for Task 3 or later if HEAD parity is wanted.
- Minor | src/store.js:13 | `listItems` returns live store object references. Worker self-flagged this; acceptable for an in-memory single-process store and the intended PATCH semantics.

No error-handling gaps on the GET path: no body read, no parse, no throw path besides `send`.

## Part 3: Challenge

Attempts table (one throwaway file test/zz-probe.test.js, run alone, removed with `/bin/rm -f`; `git status --porcelain` printed nothing afterwards):

| target | attack | result |
|---|---|---|
| Cross-owner read | POST as alice, GET as bob | HELD: `[]` |
| Cross-owner read | GET as `Alice` after POST as `alice` and `Alice` | HELD: only the `Alice` item; case variants are distinct tenants, no leak |
| Cross-owner read / identity normalization | POST with `X-Owner: "alice "`, GET as `alice` and as `"alice "` | HELD: both see the same 2 items. HTTP layer strips trailing OWS on both sides, so storage and lookup agree. Not a cross-owner issue (see Minor above) |
| Identity ambiguity | duplicate X-Owner header (`alice`, `bob`) | HELD: Node joins to `"alice, bob"`, a distinct tenant; returns `[]`, neither alice's nor bob's items |
| Missing owner header | GET with no header | HELD: 401 `{"error":"X-Owner header required"}` |
| Header is sole identity | GET /items?owner=alice as bob | HELD: `[]` |
| Route matching | GET /items/ (trailing slash) | HELD: 404, per spec "unknown routes 404" |
| Method handling | HEAD /items as alice; HEAD with no header | HELD: 404 / 401, empty body; no data exposed |
| Input validation | GET with tab-suffixed owner | HELD: normalized by parser, exact items for `alice` |
| Existence leak | n/a to a list route; array is empty or owner-scoped, no per-id lookup | HELD by design |
| Title validation | untouched by diff; POST tests from Task 1 still pass (18/18) | HELD |

Report checks:
- Risk section: present, substantive, written before code. `stat -f '%m'`: risk draft 1793699973 < test files 1793699992 < src files 1793700000. OK.
- Sources: present (Node v22 node:test and node:http via Context7, dated). No new library or external call introduced. OK.
- Mocks: none; every test hits the real server on port 0. OK.
- Verification: contains `node --test test/ 2>&1 | tail -5`, `node --check src/server.js && node --check src/store.js`, and `git status --porcelain`. The worker's non-empty status was the controller's own uncommitted plan edit, since committed as d42b18b; tree is clean now. OK.

## Part 4: Lessons

Lessons: none.

Files: src/server.js, src/store.js, test/get-items.test.js, test/index.js. No files written by this review remain.
