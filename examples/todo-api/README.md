# Example: todo-api, one real Solomon Loop run (2026-11-03)

Unedited output of a single run of the loop on a throwaway Node 22 repo (zero dependencies, `node:http`, `node --test`). Only absolute paths were scrubbed. Nothing was staged: no implementer was told to leave a bug, no finding was invented.

## Look at first

1. **The BROKE line.** `reviewer-report-task-3.md`, Part 3, attempt 5: `PATCH /items/%E0` returned 500 because `decodeURIComponent` throws on bad percent-encoding (`src/server.js:81` at the time). Spec requires 404. The implementer's own probes never tried a malformed path segment. The fix round (same file, second half) shows the test-first fix and the scoped re-review that confirmed it with eight more attempts.
2. **Risk written before code.** `risk-task-3-draft.md` was written before any src or test edit (mtimes checked by the reviewer). Task 3's brief omitted the ownership check from its acceptance list; the Risk step made the implementer add it anyway, which is the loop working as designed. Compare `plan.md` Task 3 steps with the `updateItem(owner, id, patch)` signature in `src/store.js`.
3. **The lessons table.** `lessons.md` has one candidate, `built-in-throws-on-path-input`, with a concrete proposed edit. It recurred in one task group, so the promote rule rejected it. One occurrence is a candidate, not evidence.

## What is here

| File | What |
|---|---|
| `spec.md`, `plan.md` | The 10-line spec and the 3-task plan (Task 3 was added after Tasks 1 and 2 held every attack) |
| `loop-lens.md`, `ledger.md`, `lessons.md` | The workspace `/solomon-loop:setup` produces, plus every Ruling made during the run |
| `worker-report-task-N.md` | Implementer reports: Sources, Risk, Mocks, Verification, TDD Evidence, then the standard sections |
| `reviewer-report-task-N.md` | Reviewer reports: spec compliance, code quality, Challenge attempts table, Lessons |
| `reviewer-report-branch.md` | The whole-branch Challenge after the last task (13 cross-task attacks, all held) |
| `risk-task-N-draft.md` | The Risk sections as written before code |
| `src/`, `package.json` | The final server (117 lines). Tests (297 lines) are not copied; the reports quote them |

Numbers: 3 tasks, rounds 1 / 1 / 2, 0 Critical, 1 Important (fixed), 11 Minor, 57 challenge attempts, 1 BROKE.

## Version note

This run used plugin 1.0.0. The files are left as produced, so they differ from 1.0.3 in three places:

- **Fix rounds vs correction attempts.** "Rounds 1 / 1 / 2" counts review rounds. In 1.0.3 terms, Tasks 1 and 2 used 0 correction attempts and Task 3 used 1 of its 2.
- **No review tiers.** `loop-lens.md` has no `Paths:` globs, so every task got the full Challenge. Under 1.0.3, Tasks 1 to 3 all touch `src/server.js` and `src/store.js` (input handling, ownership), so they would still be full tier.
- **Full reports in the controller.** Reports were pasted back into the controller session. In 1.0.3, each agent writes its report file and returns at most 10 lines.

## Reproduce

1. `git init` a scratch repo with `spec.md` as `docs/spec/todo-api.md`, `plan.md` as `docs/plans/todo-api.md` (uncheck the three tasks), and `package.json`.
2. `/solomon-loop:setup docs/plans/todo-api.md`, then `/solomon-loop:run docs/plans/todo-api.md`.
3. Compare your `.solomon-loop/todo-api/` with this folder. Findings will differ; the shape of the reports should not.
