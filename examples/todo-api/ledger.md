# Solomon Loop ledger: todo-api

Plan: docs/plans/todo-api.md. Started 2026-11-03.

Ruling (2026-11-03): the task reviewer's Challenge pass may create ONE throwaway test file in the relevant package's test folder, run only that file, then delete it. `git status --porcelain` must show nothing new afterwards and the reviewer's report must say so. This is the reviewer's only permitted write.
Ruling (2026-11-03): Review Focus taken from the plan's own Review Focus section (three items); no derivation needed.
Ruling (2026-11-03): no mock boundaries; the project has no external services, so every test runs the real node:http server.
Ruling (2026-11-03): workspace is .solomon-loop/todo-api/ (no SDD workspace present); added to .gitignore.
Ruling (2026-11-03, Task 1): implementer added test/index.js outside the task's file list because `node --test test/` on Node 22 treats the path as a module. Accepted as the smallest change that keeps the plan's done check literal; Task 2 brief must say to add its import line. Cost if wrong: bare `node --test` double-counts tests (cosmetic).
Ruling (2026-11-03, Task 1): "characters" in the title limit means UTF-16 code units (`.length`). Strictest reading, never admits an oversize title. Cost if wrong: over-rejects some emoji-heavy titles.
Task 1 complete: 1 round, 0 Critical, 0 Important, 4 Minor, 16 challenge attempts all HELD. Commit 7d3558e.
Ruling (2026-11-03, Task 2): header case variants (`alice` vs `Alice`) are distinct tenants; the spec gives no normalization rule and exact match never leaks. Cost if wrong: a client that varies case sees an empty list, not another owner's data.
Task 2 complete: 1 round, 0 Critical, 0 Important, 3 Minor, 11 challenge attempts all HELD. Commit 94e9a5f.
Ruling (2026-11-03): Tasks 1 and 2 produced no BROKE. Appending Task 3 (PATCH /items/:id) to the plan so the loop is exercised on a task whose brief under-specifies ownership; the spec already covers PATCH and the 404-not-403 rule. Cost if wrong: one extra task on a throwaway repo.
Ruling (2026-11-03, Task 3): reviewer round 1 found one Important BROKE (`/items/%E0` -> 500, src/server.js:81). Fix round 1 resumes the same implementer with the finding verbatim; re-review scoped to that finding plus a regression run of the attempts table.
Ruling (2026-11-03, Task 3): fix chosen was removal of `decodeURIComponent` rather than a try/catch. Ids are server-generated UUIDs; an encoded form of a real id now reads as a different, nonexistent id (404). Cost if wrong: a client that percent-encodes a UUID gets 404; no client that received the id from this API would do that.
Ruling (2026-11-03, Task 3): the implementer added the ownership check to PATCH on its own, prompted by the Risk section (the task text omitted it, the spec required it). The `updateItem(owner, id, patch)` signature deviation from the plan is accepted.
Task 3 complete: 2 rounds (round 1 found 1 Important BROKE at src/server.js:81; fix round 1 FIXED). 0 Critical, 1 Important, 4 Minor, 9 round-1 attempts (1 BROKE), 8 re-review attempts all HELD. Commits 08d40db, 19f0511.
Whole-branch review complete: 13 cross-task attempts, all HELD, 0 findings. No fix dispatch needed.
Ruling (2026-11-03, Promote): lesson #1 built-in-throws-on-path-input recurred in 1 task group (Task 3). Promote rule needs 2 or more, so Status = rejected (one occurrence). The proposed Surfaces line stays in the row as reference for a future run.
Run complete: 3 tasks done, 0 waiting on the user, rounds per task 1 / 1 / 2, findings 0 Critical, 1 Important (fixed), 11 Minor, 0 supported candidates.
