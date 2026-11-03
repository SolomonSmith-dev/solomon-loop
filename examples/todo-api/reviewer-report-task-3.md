# Review: Task 3, PATCH /items/:id (commit 08d40db on 308837e)

## Part 1: Spec compliance

Done check, run by me: `node --test test/ 2>&1 | tail -5` prints `# fail 0`, `# pass 25` (14 required). `node --check` on both src files exits 0. `git status --porcelain` empty before and after my probe.

The diff does what the task and spec say: 200 with the item on a boolean `done`, 400 for non-boolean/missing `done`, non-JSON and non-object bodies, 404 for unknown id, 401 without X-Owner (pre-routing check in `handle()`, server.js:55-58). The spec's ownership rule is honoured: lookup is `i.id === id && i.owner === owner` (store.js:20), and the 404 body for another owner's id is byte-identical to the unknown-id body (verified, probe 1c).

Signature deviation: plan says `updateItem(id, patch)`, implemented `updateItem(owner, id, patch)`. Justified. The spec requires owner scoping on PATCH, and putting it in the store matches `createItem(owner, ...)` and `listItems(owner)` so no caller can mutate by id alone. Flagged in the risk draft before coding and in the report's self-review.

One spec gap: "Unknown routes return 404" and the spec never permits 500, but `/items/%E0` returns 500 (see Part 3, attempt 5).

## Part 2: Code quality

Findings, by severity:

1. **Important** (server.js:81): `decodeURIComponent(itemMatch[1])` throws `URIError` on invalid percent-encoding; the only handler is the generic `.catch` at server.js:91, so an attacker-controlled path yields `500 {"error":"internal error"}`. Spec requires 404. Fix: drop `decodeURIComponent` entirely (ids are UUIDs, never percent-encoded; a decoded `%2F` could never match anyway) or wrap it and return 404 on throw. Add a test for `/items/%E0` expecting 404.
2. **Minor** (store.js:22): `Object.assign(item, patch)` is generic; the only caller passes `{done}` so it is safe today, but the store itself does not enforce that only `done` is writable. `item.done = patch.done` (or a `setDone(owner, id, done)` signature) would make the store safe against a future caller.
3. **Minor** (server.js:19-22, pre-existing from Task 1, reused here): on an oversize body `readBody` rejects and destroys the socket before any response, so the client sees a socket error, not a 413 or 400. The `.catch` then calls `send(res, 500, ...)` on a destroyed socket (a no-op). Spec is silent on body limits, so not a BROKE, but a 413 before `req.destroy()` would be cleaner.
4. **Minor** (server.js:12-28): no per-request body read timeout; a request with `Content-Length` larger than its body hangs the handler until Node's default `server.requestTimeout` (300 s) fires. Spec is silent. If the server is ever exposed, set `server.requestTimeout`/`headersTimeout` explicitly in `createServer()`.
5. **Minor** (server.js:74-86): `GET /items/:id` or `DELETE /items/:id` fall to the catch-all 404 rather than 405. Spec says unknown routes 404, so acceptable; noting only.

Everything else holds: `parseJsonObject` refactor preserves POST error strings (12 POST tests pass); `new URL(req.url, ...)` cannot throw for a request Node's parser accepted; `JSON.parse` is wrapped; prototype-key bodies cannot reach `Object.assign` because only `parsed.body.done` is copied.

## Part 3: Challenge

All run against the real server from one throwaway file (`test/zz-review-probe.test.js`), deleted with `/bin/rm -f` afterwards; `git status --porcelain` shows nothing.

| # | target | attack | result |
|---|--------|--------|--------|
| 1 | ownership / existence leak | alice creates item; bob PATCHes it `{"done":true}`; alice GETs; compare bob's body to PATCH of unknown UUID | HELD. bob: `404 {"error":"not found"}`; unknown id: `404 {"error":"not found"}`; byte-identical = true; alice GET shows `done:false` |
| 2 | missing owner header | PATCH alice's id, no X-Owner | HELD. `401 {"error":"X-Owner header required"}` |
| 3 | field whitelist | `{"done":true,"title":"","owner":"bob","id":"x"}` | HELD. 200; only `done` changed; title, owner, id unchanged; bob's list unchanged |
| 4 | prototype pollution | `{"done":true,"__proto__":{"owner":"bob"}}` and `{"done":true,"constructor":{"prototype":{"owner":"bob"}}}` | HELD. 200 both; `Object.prototype.owner === undefined`, `({}).owner === undefined` after; stored item and bob's list unchanged |
| 5 | malformed path id | `/items/%E0` | **BROKE, server.js:81** (`decodeURIComponent` throws URIError, caught at server.js:91): `500 {"error":"internal error"}`. Spec requires 404 |
| 5 | malformed path id | `/items/%2F`, `/items/..%2F`, `/items/%00`, 10,000-char id, bob's id URL-encoded | HELD. All `404 {"error":"not found"}`, no hang |
| 6a | readBody chunking | raw socket, body in two chunks 300 ms apart | HELD. `HTTP/1.1 200 OK` |
| 6b | readBody hang | raw socket, Content-Length = body+50 | No response within 2 s (hangs until Node's default 300 s requestTimeout). Spec silent; recorded as Minor #4, not a BROKE |
| 7 | body size cap | PATCH with 70 KB body | Socket destroyed by server, client fetch throws `UND_ERR_SOCKET`; no 4xx. Item unchanged. Spec silent; Minor #3 (pre-existing). 60 KB body: 200, works |

Process checks:
- **Risk** section: present, substantive, written before code. `stat -f '%m'`: risk draft 1793700244 < test files 1793700263 < src files 1793700283. OK.
- **Sources**: present (Context7 Node v22 http and test docs, dated). No new library or external API. OK.
- **Mocks**: "None", tests use the real server on port 0 and global fetch. OK.
- **Verification**: includes `node --test test/ 2>&1 | tail -5`, `node --check src/server.js && node --check src/store.js`, `git status --porcelain` empty after commit. OK.

## Findings list

- Important: `/items/%E0` returns 500 instead of 404 (server.js:81, `decodeURIComponent` on attacker-controlled path).
- Minor: `Object.assign(item, patch)` is wider than the route needs (store.js:22).
- Minor: oversize body closes the socket with no HTTP response (server.js:19-22, pre-existing).
- Minor: no explicit request/body timeout; short-body hang relies on Node's 300 s default (server.js:12-28).
- Minor: other methods on `/items/:id` give 404 rather than 405 (server.js:74-86); spec-compliant.

Verdict: one Important fix required before Task 3 is accepted (remove or guard `decodeURIComponent`, add a `/items/%E0` -> 404 test). Everything else in the diff holds.

## Part 4: Lessons

built-in-throws-on-path-input | The worker's manual acceptance probed `/items`, `/items/a/b` and body shapes but never a malformed path segment; the brief's Surfaces list names "Input validation on JSON bodies" only, so path-derived input was not on the worker's checklist and `decodeURIComponent` was added without thinking of its throw case | Add to the shared brief's Surfaces: "Path and query input: every built-in called on a URL segment (decodeURIComponent, new URL, Number, regex) must be probed with invalid percent-encoding (`%E0`), `%2F`, `%00` and a 10,000-char value; expected 404 or 400, never 500". Add to the worker's Verification requirement: "list every built-in that can throw on caller-supplied input and show the probe that proves it maps to 4xx".

---

# Re-review: Task 3, fix round 1 (commit 19f0511 on 08d40db)

## The fix

Diff `08d40db..19f0511` is two hunks: server.js:81 drops `decodeURIComponent(itemMatch[1])` in favour of the raw `itemMatch[1]`, and test/patch-items.test.js adds `404 for a malformed percent-encoded id, never 500` (line 93, confirmed on disk) sending `PATCH /items/%E0` and asserting `404 {"error":"not found"}`. `grep decodeURIComponent src/server.js` finds nothing, so no other decode call remains on a path segment. The generic `.catch` at server.js:91 is unchanged, which is fine: nothing on the PATCH path can throw on caller input now (`new URL` cannot throw on a request Node's parser accepted, `JSON.parse` is wrapped).

Reverting the fix would fail the new test: `decodeURIComponent('%E0')` throws `URIError` (lone lead byte, invalid UTF-8 sequence), the only handler is the `.catch` at :91, so the response is `500 {"error":"internal error"}` and `assert.equal(res.status, 404)` fails. Reasoned from the diff; not reverted.

## Part 3: Challenge (scoped)

All attacks run against the real server (port 0, global fetch) from one throwaway file `test/zz-rereview-probe.test.js`, deleted with `/bin/rm -f`. `git status --porcelain` printed nothing afterwards; `test/` holds only the three original test files plus `index.js`.

| target | attack | result |
|--------|--------|--------|
| malformed path id | `PATCH /items/%E0` as alice | HELD. `404 {"error":"not found"}` (was 500 at 08d40db) |
| malformed path id | `PATCH /items/%` | HELD. 404, same body |
| malformed path id | `PATCH /items/%2F` | HELD. 404, same body |
| malformed path id | `PATCH /items/%00` | HELD. 404, same body |
| malformed path id (extra) | `%E0%`, `%zz`, `a%`, `%%%` | HELD. All 404, same body |
| happy path regression | alice PATCHes her own real id `{"done":true}` | HELD. `200`, item returned with `done:true`, owner/title/id unchanged |
| ownership | bob PATCHes alice's real id | HELD. `404 {"error":"not found"}`; status and body byte-identical to unknown-UUID PATCH (`bodyIdentical: true`); alice's list afterwards still `done:false` |
| encoded real id | alice PATCHes `%39` + rest of her id (first char `9` percent-encoded) | 404 as predicted, since no decoding happens. Acceptable: ids are server-generated UUIDs (`[0-9a-f-]`), no character in them ever needs encoding, and no client that received the id from this API would encode it. Treating an encoded form as a different, nonexistent id is strictly safer than decoding (no throw surface, no `%2F`-style confusion). |

Full suite: `node --test test/ 2>&1 | tail -5` prints `# fail 0`, `# cancelled 0`, `# skipped 0`, `# todo 0`, `# duration_ms 146`; `grep "^# pass"` prints `# pass 26` (25 before the fix + the new test).

## Part 4: Lessons

Lessons: none. The one Important finding is from round 1 and its lesson is already recorded there; this round found no Critical or Important finding.

## Verdict

**FIXED.** The round-1 Important finding is closed: every malformed percent-encoded id returns 404 with the standard body, the happy path and ownership scoping are unchanged, the regression test exists and would fail on revert, and the suite is green at 26/26. No new findings.
