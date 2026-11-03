# Review: Task 1, POST /items with validation (commit 7d3558e)

## Part 1: Spec compliance

Done check run by me: `node --test test/ 2>&1 | tail -5` -> `# fail 0`, `# tests 12 / # pass 12`. `node --check` on both src files OK. `git status --porcelain` empty before and after my probe.

The diff does what Task 1 and the spec say: 401 before anything else, JSON parse with 400, object-shape check, title string/trim/1..120, 201 with `{id, owner, title, done:false}`, 404 for unknown routes. The 121-char title returns 400 (fails-when condition not triggered).

File outside the task's Files list: `test/index.js` (3 lines, imports the test file). Justified in the report: on Node 22.23.1 `node --test test/` treats `test/` as a module path and fails with MODULE_NOT_FOUND without it. Side effects the worker named: bare `node --test` runs every test twice; Task 2 must add an import line. The plan's done-check command is the real defect; the worker chose the smallest workaround that kept the done check literal. Acceptable, but the plan owner should switch the script and done checks to `node --test "test/**/*.test.js"` and delete `test/index.js`.

Nothing beyond scope: no GET, no PATCH, no listing.

## Part 2: Code quality

Findings:

1. Minor | `src/server.js:35` | Length check uses `.length` (UTF-16 code units), so a 100-emoji title (100 code points) or 61 `e + U+0301` pairs (61 graphemes, 122 code units) are rejected as "more than 120 characters". Spec says "characters" without defining it; code units is the strictest reading and never admits an over-long title, so it is safe but over-rejects. If "characters" means code points, use `[...title].length`; if graphemes, `Intl.Segmenter`. Add whichever definition is chosen to the spec.
2. Minor | `src/server.js:19-21` | Body over 64 KiB destroys the socket (client sees `UND_ERR_SOCKET`) instead of a 413 JSON error. Outside spec, untested. Fine for now.
3. Minor | `src/server.js:33` | Control characters (NUL, newline) inside a title are accepted and stored verbatim (`a\u0000b` -> 201). Spec does not forbid; note only.
4. Minor | `src/store.js:3` | Module-level array shared across all tests in a process. Worker flagged it; Task 2 must use distinct owners per test.

No Critical or Important code findings. Validation order, error shapes, 500 guard and the `__proto__` / array / null body rejections are all correct.

## Part 3: Challenge

Risk section covers all three Review Focus items and all three surfaces, each marked touched/not touched with the tests named. Risk draft mtime 1793699676 precedes test file (1793699695) and src files (1793699750): written before code. Sources listed (Node 22 docs via Context7, dated). Mocks: none, real server on port 0. Verification has all three required commands with output.

Probe file `test/zz-review-probe.test.js` created, run alone, deleted with `/bin/rm -f`; `git status --porcelain` printed nothing afterwards.

| target | attack | result |
|---|---|---|
| title length | 121 ASCII chars | HELD, 400 |
| title trim | 120 chars padded to 125 with whitespace | HELD, 201 with trimmed 120-char title (spec: length after trimming) |
| title length, multi-byte | 121 x `e+U+0301` (242 code units) | HELD, 400 |
| title length, multi-byte | 100 emoji (100 code points, 200 code units) | HELD (rejects), 400; over-strict per Part 2 finding 1, not a break |
| title length, multi-byte | 61 x `e+U+0301` (61 graphemes, 122 code units) | HELD (rejects), 400; same note |
| owner header | no X-Owner | HELD, 401 before body read |
| owner header | `X-Owner: ""` | HELD, 401 (empty treated as missing; sensible, spec silent) |
| owner source | body `{"title":"ok","owner":"someone-else"}` | HELD, 201 with owner from header (`alice`) |
| body parse | `{title: nope` | HELD, 400 |
| body shape | `[1,2]` | HELD, 400 "body must be a JSON object" |
| body shape | empty body | HELD, 400 |
| title type | `{"title":["a"]}` | HELD, 400 |
| prototype | `{"__proto__":{"title":"x"}}` | HELD, 400 (title not read through prototype) |
| body size | 70 KB JSON | HELD, socket destroyed, no store write (no 413, Minor above) |
| cross-owner read | GET /items as bob | n/a, route 404 (Task 2) |
| existence leak | n/a, no id route yet | n/a |

No BROKE.

## Part 4: Lessons

Lessons: none.

Non-blocking notes for the plan owner: (1) the plan's done-check command does not work on Node 22 without `test/index.js`; fix the plan rather than carrying the shim; (2) define "characters" in the spec (code units, code points or graphemes) so the Task 1 length check has one unambiguous meaning.

Verdict: PASS. No Critical or Important findings.
