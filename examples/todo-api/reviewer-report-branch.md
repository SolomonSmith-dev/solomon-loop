# Whole-branch review: todo-api, cross-task Challenge (HEAD 2773bee)

Node v22.23.1. Read spec, `src/server.js`, `src/store.js`, and reviewer reports for Tasks 1 to 3; none of the attacks below repeat those (per-route title validation, `%E0`, prototype keys, oversize body, trailing-OWS owner were already run).

Method: one throwaway file `test/zz-branch-probe.test.js` (recreated once for a second pass after my own raw-socket helper rejected on the server's expected 431 reset; still the only file), run alone with `node --test test/zz-branch-probe.test.js`, deleted with `/bin/rm -f` after each pass. `git status --porcelain` printed nothing after both passes; `test/` holds only `get-items.test.js`, `index.js`, `patch-items.test.js`, `post-items.test.js`. Probe output kept outside the repo.

## Attempts

| target | attack | result |
|---|---|---|
| cross-owner mutate under concurrency | alice POSTs; 50 parallel `PATCH {"done":true}` from bob at alice's id interleaved with 10 parallel GETs from alice | HELD. All 50 bob responses 404; every alice GET saw `done:false`; bob's list `[]`; final alice item `done:false` |
| store object identity | alice and bob POST identical title; each PATCHes own id; compare PATCH bodies and lists | HELD. UUIDs distinct; each PATCH response carries only the caller's object; alice list owners `["alice-y"]`, bob list owners `["bob-y"]`; bob's PATCH of alice's id with spoof body `{done:false,id:<bob id>,owner:"bob-y"}` returned 404 and alice's item stayed `done:true` (live references never cross owners because `listItems`/`updateItem` filter on `owner` first, store.js:13 and :20) |
| header: comma value | `X-Owner: alice-z, bob-z` on POST, GET, PATCH | HELD. Treated as one literal tenant on all three routes (201 / 200 with its own item / 404); `alice-z` and `bob-z` lists both `[]` |
| header: duplicate X-Owner | raw socket, two `X-Owner` lines (alice-z, bob-z) on POST | HELD. Node joins to `"alice-z, bob-z"`; neither alice-z nor bob-z sees the item |
| header: 100 KB value | fetch POST, GET, PATCH; plus raw GET | HELD. Node parser answers `431 Request Header Fields Too Large` and closes before `handle()` runs, identical on all routes; no store write |
| header: non-ASCII | raw latin1 bytes `ålice-ñ` on GET, POST, PATCH; raw UTF-8 bytes of the same string; fetch with the same string | HELD and consistent. Node decodes header bytes as latin1 on every route; byte-exact identity, no normalization, same rule on all three routes. Note only, not a leak |
| header: whitespace-only | raw `X-Owner: \t ` | HELD. 401 (parser strips OWS, server trims) |
| header: CR/LF injection, NUL, obs-fold | fetch with `alice\r\nX-Owner: bob` (undici refuses to build the header); raw `al\x00ice`; raw folded continuation `alice\r\n bob` | HELD. Raw cases rejected by Node with `400 Bad Request` before `handle()` |
| route confusion | `PATCH /items`, `POST /items/<id>` as bob with title, `GET /items/<id>` as bob and as alice, `GET /items/`, `GET /ITEMS`, `PATCH /items/<id>/`, `PATCH //items/<id>` | HELD. All 404 `{"error":"not found"}`; alice's title unchanged, bob's list `[]` |
| route confusion: query on PATCH | bob `PATCH /items/<alice id>?owner=alice-r&done=true` | HELD. 404; query ignored, header is sole identity. alice `PATCH /items/<own id>?x=1` -> 200 (pathname match, query ignored, acceptable) |
| route confusion: lowercase method | raw `patch /items/<id> HTTP/1.1` as bob | HELD. Node parser rejects with `400 Bad Request`; handler never runs |
| route confusion: absolute-form target | raw `PATCH http://evil/items/<alice id>` as alice | HELD. `new URL(req.url, base)` yields pathname `/items/<id>`; 200 for the owner, still owner-scoped. Note only |
| 401 before routing | every method (GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD) on `/items`, `/items/<id>`, `/nope`, no header; plus `X-Owner: ""` | HELD. All 22 requests 401; the check at server.js:52-55 precedes URL parsing and routing |

No BROKE.

## Notes (Minor, no action required for this branch)

- Identity is the raw latin1-decoded header bytes (server.js:52). Two spellings of the same Unicode name (UTF-8 bytes vs latin1 bytes, NFC vs NFD) are different tenants. Consistent across routes, so no cross-owner effect; document it if non-ASCII owners are ever expected.
- Absolute-form request targets are accepted (server.js:57 `new URL(req.url, 'http://localhost')`). Harmless here since only pathname is used.

## Lessons

Lessons: none.

## Verdict

PASS. Across POST, GET and PATCH in any order and under 50-way concurrent cross-owner PATCH, no response ever carried another owner's object, no mutation crossed owners, and header, route and method edge cases either reach the same owner-scoped code path or are rejected by Node's parser before `handle()`. The 401 gate holds for every method and path. Working tree is clean (`git status --porcelain` empty) and the probe file is gone.
