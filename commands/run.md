---
description: Run a plan with the Solomon Loop. One implementer Agent then one reviewer Agent per unchecked task, fix rounds up to 5, rulings in ledger.md, lessons promoted only when they recur.
argument-hint: <plan-path>
allowed-tools: Read, Write, Edit, Agent, Bash(test *), Bash(git status *), Bash(git diff *), Bash(git log *)
---

# Solomon Loop run

Plan path: `$ARGUMENTS`

## 0. Preconditions

1. Load the `solomon-loop` skill (invoke it with the Skill tool) and follow its loop: define, research, assess risk, implement, verify, challenge, learn, validate, promote.
2. If `$ARGUMENTS` is empty or not a file, stop with one line: `solomon-loop:run: plan not found at <path>`.
3. Slug = plan filename without directory or `.md`. Workspace = `.superpowers/sdd/<slug>/` if it exists, else `.solomon-loop/<slug>/`. If the workspace has no `loop-lens.md`, run the steps of `/solomon-loop:setup $ARGUMENTS` first, then continue.
4. Read `loop-lens.md`, `lessons.md` and `ledger.md` from the workspace. Read `${CLAUDE_PLUGIN_ROOT}/skills/solomon-loop/worker-report.md` and `${CLAUDE_PLUGIN_ROOT}/skills/solomon-loop/reviewer-challenge.md`.
5. **With superpowers:** if `superpowers:subagent-driven-development` is loaded in this session, say so in one line and defer to it: SDD dispatches the implementer and reviewer, owns the plan checkboxes and its own ledger. Your only additions are the two blocks below appended to SDD's prompts (worker block to the implementer prompt, challenge block after SDD's Part 2 of the reviewer prompt), plus the lessons and rulings steps. Skip sections 1 to 3 of this file in that case and follow SDD for ordering.

## 1. For each unchecked task, in plan order

A task is unchecked when its heading or checkbox is not marked done (`- [ ]`, or a `### Task N:` heading with no `[x]`). Skip tasks whose Owner is the user (decisions, accounts, hardware); list them at the end as waiting on them.

### 1a. Define: build the implementer brief

The brief contains, in this order:

- The task text verbatim (title, owner, files, steps).
- Acceptance checks: every Done check as `command` plus the expected output, and its "Fails when" line. If the plan gives none, write one observable check from the task's files and say it was derived.
- The relevant Review Focus items, surfaces, verify commands that exist by this task number, and mock boundaries, copied from `loop-lens.md`.
- Repo rules the plan states for every brief (shell aliases to avoid, commit conventions, forbidden trailers).
- The worker-report block from `worker-report.md`, appended last, with `[REVIEW_FOCUS]`, `[SECURITY_SURFACES]`, `[MOCK_BOUNDARIES]` and `[VERIFY_COMMANDS]` filled from `loop-lens.md`.

### 1b. Implement: dispatch the implementer

Dispatch one `Agent` (general-purpose) with the brief. Require the report in the order the worker block states: Sources, Risk, Mocks, Verification, TDD Evidence, then files changed, self-review, concerns. Save the report to `<workspace>/worker-report-task-<N>.md`.

### 1c. Challenge: dispatch the reviewer

Dispatch a second `Agent` with: the task text and acceptance checks, the diff (`git diff` for the task's files, or the file list when the repo is not git), the implementer's report, and the reviewer-challenge block from `reviewer-challenge.md` with its placeholders filled. The reviewer rates each finding Critical, Important or Minor, reports each break attempt as `target | attack | result (HELD or BROKE file:line)`, states that `git status --porcelain` shows nothing new, and ends with Lessons lines or `Lessons: none`. Save to `<workspace>/reviewer-report-task-<N>.md`.

### 1d. Fix rounds

Any Critical or Important finding starts a fix round. Up to 5 rounds per task:

- Rounds 1 to 3: resume the same implementer Agent (SendMessage with its id) with the findings verbatim.
- Rounds 4 and 5: dispatch a fresh implementer Agent with the brief plus all findings so far.
- After each round, re-dispatch the reviewer with the new diff and report (the challenge block scoped to the fix).
- Round 5 still failing: stop and ask the user (hopeless-plan stop). Do not check the task off.

### 1e. Learn and record

- Copy every Lessons line from the reviewer into `lessons.md` as a new row: `#`, task group (the task number or the plan's grouping), finding class, root cause, proposed improvement, `Recurrences` 1, `Status` candidate. If the same finding class already has a row, bump its `Recurrences` and add the task group instead of adding a row.
- Record every decision you made in `ledger.md` as `Ruling (YYYY-MM-DD, Task N): <decision and reason>`: derived checks, scope cuts, an extra verify command, an unblocking fix, which round fixed a finding.
- Check the task off in the plan: `- [ ]` becomes `- [x]`, or add `[x]` to the task heading. Edit only that line.

## 2. Stops

Stop and ask the user before any of these; everything else is a Ruling:

1. An irreversible action (delete, force push, drop, overwrite a non-generated file outside the task's files).
2. A security-sensitive action (secrets, auth, permissions, `.env`, credentials).
3. An outward side effect (push, publish, post, send, network write, payment).
4. A hopeless plan (a task that cannot pass its own done check, or round 5 failing).
5. Adopting any process change (editing the skill, templates, brief rules or `loop-lens.md` mid-run).

## 3. Promote (end of run)

1. Supported = a finding class that recurred in 2 or more task groups and has a concrete proposed improvement. For each, show the user: finding class, task groups, the exact proposed edit, and where it goes (the repo's brief file, `loop-lens.md` defaults, or the skill's templates). Set `Status` to `supported` and wait for a yes or no per item.
2. Every other candidate: set `Status` to `rejected` with the reason (`one occurrence` or `no concrete change`). Candidates the user declines become `declined`.
3. Apply only what the user approves. An approved change to the skill's own files is `adopted` only after a skill check passes (frontmatter, length, trigger test).
4. Final report: tasks done, tasks waiting on the user, rounds used per task, findings by severity, supported candidates, and the paths of `lessons.md` and `ledger.md`.
