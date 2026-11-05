---
description: Run a plan with the Solomon Loop. One implementer then an independent reviewer per task, at most two total correction attempts per lineage, rulings in ledger.md, lessons promoted only when they recur.
argument-hint: <plan-path>
allowed-tools: Read, Write, Edit, Agent, Bash(test *), Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git rev-parse *)
---

# Solomon Loop run

Plan path: `$ARGUMENTS`

## 0. Preconditions

1. Load the `solomon-loop` skill (invoke it with the Skill tool) and follow its loop: define, research, assess risk, implement, verify, challenge, learn, validate, promote.
2. If `$ARGUMENTS` is empty or not a file, stop with one line: `solomon-loop:run: plan not found at <path>`.
3. Slug = plan filename without directory or `.md`. Workspace = `.superpowers/sdd/<slug>/` if it exists, else `.solomon-loop/<slug>/`. If the workspace has no `loop-lens.md`, run the steps of `/solomon-loop:setup $ARGUMENTS` first, then continue.
4. Read `loop-lens.md`, `lessons.md` and `ledger.md` from the workspace. Read `${CLAUDE_PLUGIN_ROOT}/skills/solomon-loop/worker-report.md` and `${CLAUDE_PLUGIN_ROOT}/skills/solomon-loop/reviewer-challenge.md`.
5. **With superpowers:** if `superpowers:subagent-driven-development` is loaded in this session, say so in one line and defer to it: SDD supplies prompt/report mechanics and its ledger; reviewer assignment stays independent and the independent reviewer owns acceptance, and the two-total-attempt lineage counter below supersedes any conflicting SDD circuit breaker. Your additions: before each implementer dispatch, derive the tier (1a rule) and bind `[REPORT_PATH]` to `<workspace>/worker-report-task-<N>.md`; append the worker block to SDD's implementer prompt. Before each review, run the 1c candidate binding and diff tier re-check, bind `[REPORT_PATH]` to `<workspace>/reviewer-report-task-<N>.md`, and append the challenge block (Challenge dropped for light tier) after SDD's Part 2 of the reviewer prompt. Then the targeted report reads, lessons, rulings and the HEAD check before check-off from 1c and 1e. Skip the rest of sections 1 to 3 and follow SDD for ordering.

## 1. For each unchecked task, in plan order

A task is unchecked when its heading or checkbox is not marked done (`- [ ]`, or a `### Task N:` heading with no `[x]`). Skip tasks whose Owner is the user (decisions, accounts, hardware); list them at the end as waiting on them.

### 1a. Define: build the implementer brief

The brief contains, in this order:

- The task text verbatim (title, owner, files, steps).
- Acceptance checks: every Done check as `command` plus the expected output, and its "Fails when" line. If the plan gives none, write one observable check from the task's files and say it was derived.
- The relevant Review Focus items, surfaces, verify commands that exist by this task number, and mock boundaries, copied from `loop-lens.md`.
- Repo rules the plan states for every brief (shell aliases to avoid, commit conventions, forbidden trailers).
- The worker-report block from `worker-report.md`, appended last, with `[REVIEW_FOCUS]`, `[SECURITY_SURFACES]`, `[MOCK_BOUNDARIES]` and `[VERIFY_COMMANDS]` filled from `loop-lens.md`, and `[REPORT_PATH]` = `<workspace>/worker-report-task-<N>.md`.
- Review tier: **light** only when every path in the task's Files list is on the light allowlist: docs (`*.md`, `*.mdx`, `*.rst`, `*.txt`), tests (`test/**`, `tests/**`, `**/__tests__/**`, `*.test.*`, `*.spec.*`, `*_test.*`, `test_*.py`) and fixtures (`**/fixtures/**`, `**/testdata/**`). Any other path, or `Review tier: full` in the plan, makes it **full**. A plan line asking for `light` is ignored and ledgered. Ledger the tier: `Ruling (YYYY-MM-DD, Task N): tier <full|light> | first non-allowlisted path or all allowlisted | a light task hides a source bug`.

### 1b. Implement: dispatch the implementer

Dispatch one `Agent` (general-purpose) with the brief. The implementer writes the report itself, in the order the worker block states (Sources, Risk, Mocks, Verification, TDD Evidence, then files changed, self-review, concerns), and returns only the 10-line summary. Do not read the report file; pass its path on.

### 1c. Challenge: dispatch an independent reviewer

First bind the candidate: run `git rev-parse HEAD` yourself and require it to equal the summary's `COMMIT`; on mismatch, do not review, ledger it and treat it as a Critical finding against the implementer. Then re-check the tier against the actual diff, `git diff --name-only <base>..<candidate>`: any path off the light allowlist from 1a raises a light task to full (ledger it); nothing ever lowers a tier. Then dispatch a second, independent reviewer `Agent` (never the implementer, never one the implementer chose) with: the task text and acceptance checks, the candidate SHA and commit range (the reviewer runs `git diff` itself and reports the SHA it reviewed), the implementer's report path, the tier, and the reviewer-challenge block from `reviewer-challenge.md` with its placeholders filled (only the Part 3 Challenge section dropped for light tier; review authority, report compliance, lessons and writes stay). The reviewer rates each finding Critical, Important or Minor, reports each break attempt as `target | attack | result (HELD or BROKE file:line)`, states that `git status --porcelain` shows nothing new outside the workspace, and ends with Lessons lines or `Lessons: none`. It writes the report to `<workspace>/reviewer-report-task-<N>.md` and returns only the 10-line summary. Targeted reads only: for every task, read the report's Part 4 Lessons section and its list of unfixed Minors (needed for 1e and the final report); when the summary says `corrections-needed`, also read its Critical and Important findings to brief the correction. Never read the rest.

### 1d. Fix rounds

A real Critical or Important finding starts a correction attempt. Minors, including compliance gaps the reviewer did not tie to a defect, never start one; fold them into a round that real findings already started, else list them in the final report. Initial production is separate. At most TWO correction attempts TOTAL per work-order lineage; persist `correction_count` in ledger/reports across restart/model/producer changes, reassignment and successor orders addressing the same failure. Increment before each correction dispatch. An independent reviewer handles the scoped re-review of the exact new revision. After two unsuccessful attempts, preserve findings and escalate to the owner. Do not check off failed work, adjudicate it into acceptance, reset the count or create another order to bypass exhaustion. Final whole-branch review uses affected lineages' remaining counters, never an extra allowance.

### 1e. Learn and record

- Copy every Lessons line from the reviewer into `lessons.md` as a new row: `#`, task group (the task number or the plan's grouping), finding class, root cause, proposed improvement, `Recurrences` 1, `Status` candidate. If the same finding class already has a row, bump its `Recurrences` and add the task group instead of adding a row.
- Record every decision you made in `ledger.md` as `Ruling (YYYY-MM-DD, Task N): <what> | <why> | <cost if wrong>`: derived checks, scope cuts, an extra verify command, an unblocking fix, which round fixed a finding.
- Only after exact-revision acceptance by the independent reviewer and actual done evidence, and only when `git rev-parse HEAD` still equals the reviewed SHA (any new commit returns the task to 1c), ledger `Ruling (YYYY-MM-DD, Task N): accepted <sha> | reviewer verdict accept | unreviewed code if HEAD moved` and check the task off in the plan: `- [ ]` becomes `- [x]`, or add `[x]` to the task heading. Edit only that line.
- Make the lessons, ledger and plan edits as parallel tool calls in ONE message per task, not one message per file.

### 1f. Controller context

The controller's own context is the largest cost in a run (measured 2026-11-04: 25 to 55% of each task, median 403k tokens re-read per turn). Keep it small:

- Never paste a report, diff or full test output into the controller's context; work from the 10-line summaries and file paths.
- After every 5 accepted tasks, if unchecked tasks remain, end with one line: `solomon-loop:run: 5 tasks accepted, context reset due. Resume: /solomon-loop:run $ARGUMENTS`. The ledger, lessons and plan checkboxes hold all state, so a fresh session resumes from the next unchecked task. This is not a "continue?" question.

## 2. Stops

Check existing work-order authority before the following actions; obtain only missing authority. Already granted permission remains valid. Critical authority/privacy/spending/recovery failures halt affected work regardless of ordinary dispatch. Other in-scope choices are ledger rulings, never producer overrides of independent acceptance:

1. An irreversible action (delete, force push, drop, overwrite a non-generated file outside the task's files).
2. A security-sensitive action (secrets, auth, permissions, `.env`, credentials).
3. An outward side effect (push, publish, post, send, network write, payment).
4. A hopeless plan (a task that cannot pass its own done check, or two correction attempts failing).
5. Adopting any process change (editing the skill, templates, brief rules or `loop-lens.md` mid-run).

## 3. Promote (end of run)

1. Supported = a finding class that recurred in 2 or more task groups and has a concrete proposed improvement. For each, show the user: finding class, task groups, the exact proposed edit, and where it goes (the repo's brief file, `loop-lens.md` defaults, or the skill's templates). Set `Status` to `supported` and wait for a yes or no per item.
2. Every other candidate: set `Status` to `rejected` with the reason (`one occurrence` or `no concrete change`). Candidates the user declines become `declined`.
3. Apply only what the user approves. An approved change to the skill's own files is `adopted` only after a skill check passes (frontmatter, length, trigger test).
4. Final report: tasks done, tasks waiting on the user, tier and rounds used per task, findings by severity, unfixed Minors, supported candidates, and the paths of `lessons.md` and `ledger.md`.

## Authority

Approved subscription capacity only; no billed API calls or paid fallback. Review acceptance grants no execution/disclosure/spending/release authority. Dispatch and delivery require actual source/action grants, permitted processors, expiry and existing ownership. Critical authority/privacy/spending/recovery failures halt affected pending work and dependents; no automatic restart. Preserve paused work.
