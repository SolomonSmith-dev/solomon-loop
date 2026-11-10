---
name: solomon-loop
description: "Use when executing a plan with subagents (one implementer per task plus a reviewer), when the user says \"run this with the loop\", \"solomon loop\" or \"loop this\", or when superpowers:subagent-driven-development is active. Adds the define, research, assess risk, implement, verify, challenge loop to every dispatch and logs lessons to one cross-run file. Not for a one-off edit with no plan."
---

# Solomon Loop

Adds to `superpowers:subagent-driven-development` (SDD): risk before code, an attacking reviewer, a capped correction count, and lessons logged across runs. Where SDD already does something (task dispatch, TDD, spec and quality review), follow SDD and do not restate it.

**Define, research, assess risk, implement, verify, challenge, record lessons.**

The user sets direction and makes product decisions. **Any change to the shared process needs the user's yes before adoption.**

Roles: the **controller** is the session running the plan. It dispatches one **implementer** Agent per task and keeps the production ledger. An **independent reviewer**, never chosen by the producer, reviews each task and owns exact-revision acceptance; production cannot self-accept or overrule findings. `/solomon-loop:setup <plan>` prepares the workspace (`loop-lens.md`, `ledger.md`, the cross-run lessons file); `/solomon-loop:run <plan>` runs the loop.

## Added to every task

| Step | Who | What |
|---|---|---|
| Define | Controller | The brief is the acceptance criteria. Add the observable checks (command + expected output) to the dispatch. |
| Research | Implementer | Fetch current docs for every library or external API touched. List URL + date under **Sources**. |
| Assess risk | Implementer | Write **Risk** BEFORE coding: which Review Focus items and surfaces the task touches, and the test covering each. "None" only with a reason. |
| Implement | Implementer | Real integration over mocks; a mock only at a listed boundary, named under **Mocks**. |
| Verify | Implementer | Every verify command in `loop-lens.md` that exists by this task: paste the command and the tail of its output. |
| Challenge | Reviewer | Full-tier tasks only: one concrete break attempt per named risk and per missed one. A break is Critical or Important. Report-compliance gaps are Minor unless they hide a shown defect. |
| Record | Reviewer, then controller | Every Critical/Important finding gets a lesson line. Controller appends it to the cross-run lessons file. |

Per unchecked task, the controller:

0. Derives the review tier from file paths, never the producer: **light** only for docs, tests or fixtures; anything else, and every instruction file, is **full** (allowlist in `/solomon-loop:run` 1a). Records the task base `git rev-parse HEAD` before the first dispatch. Light skips only the Challenge.
1. Dispatches one implementer Agent with the task text, the acceptance checks and [worker-report.md](worker-report.md) filled from `loop-lens.md`. Implementers and reviewers write reports to files and return at most 10 lines. The controller works from summaries and paths, and confirms `git rev-parse HEAD` equals the reported commit before review and before check-off. After every 5 accepted tasks it ends the turn so a fresh session resumes from the plan checkboxes.
2. Has an independent reviewer Agent dispatched, never one the implementer picked, with the diff, the implementer's report, and [reviewer-challenge.md](reviewer-challenge.md) appended. The Challenge pass allows exactly one throwaway test file, deleted before the report; `git status --porcelain` must be clean afterwards. Ledger this as a standing Ruling at setup.
3. On real findings, allow at most TWO correction attempts TOTAL per work-order lineage after initial production. Persist `correction_count` and lineage in the ledger and reports across restarts, model/producer changes, reassignment and successor orders addressing the same failure. An independent reviewer handles each scoped re-review. After two unsuccessful attempts, preserve findings and escalate to the owner; do not mark failed work complete or reset the count. This cap overrides any larger round or retry limit in an underlying skill, including the five fix rounds in `superpowers:subagent-driven-development`.
4. Appends the reviewer's lessons to the cross-run lessons file; records completion only after exact-revision acceptance by the independent reviewer and the actual done check. Review acceptance grants no execution/disclosure/spending/release authority.

After the last task: an independent reviewer runs the whole-branch Challenge scoped to cross-task risks. Any correction consumes the affected task lineage's remaining two-attempt allowance; final review grants no extra fix round.

## Cross-run lessons

File: `.solomon-loop/lessons.md` at the repo root. Row: `| Date | Run | Lesson | Evidence | Recurrences |`.

- **Date:** last time the lesson was seen. **Run:** the plan slug. **Lesson:** finding class and the proposed improvement. **Evidence:** path to the reviewer report, with `file:line`.
- **Append rule:** before adding a row, look for one with the same finding class. Found, from a different run: add 1 to `Recurrences`, update `Date`, append the run to `Run` and the pointer to `Evidence`. Found, same run: append the pointer only. Not found: add a row with `Recurrences` 1.
- **Promotion is a scheduled review, not a stage.** On the owner's schedule, the owner reads the file. Rows with `Recurrences` of 2 or more are the candidates. The owner decides what changes; reviewed rows move under a `## Reviewed` heading with the outcome. An approved change to this skill's files counts only after a skill check passes.
- **Standing process, role and authority changes require user approval**, including changes proposed to unblock a broken task. A ledger Ruling cannot waive that requirement. Ordinary implementation fixes within the already approved task remain allowed; they do not authorize process adoption. Already approved policy changes require integration and verification, not repeated approval.

## Optimization loop

Not run inside a delivery run. When the user asks: freeze the current templates as baseline, run baseline and candidate on the same fresh tasks in separate worktrees, compare finding counts, human interventions and security results. Promote only a clear win.

## With superpowers

SDD runs the dispatch; this skill adds to it.

- Reviewer assignment stays independent and the independent reviewer owns acceptance. The original attempt plus at most TWO corrections per lineage, then escalation to the owner, overrides SDD's five fix rounds.
- SDD's workspace `.superpowers/sdd/<plan>/` holds `loop-lens.md`, the reports and the Rulings. The cross-run lessons file stays at `.solomon-loop/lessons.md`.
- Append [worker-report.md](worker-report.md) to SDD's implementer prompt and [reviewer-challenge.md](reviewer-challenge.md) after SDD's Part 2 in the task reviewer and re-reviewer prompts. The final whole-branch review gets the Challenge section only.
- Before each dispatch derive the tier and bind `[REPORT_PATH]`; before each review and before check-off confirm `git rev-parse HEAD` equals the reviewed SHA.
- Never edit the plugin cache.

## Stops

Check existing task authority before destructive, security-sensitive or outward actions; obtain only missing authority. A task that cannot pass its check or exhausts two corrections escalates to the owner. Adopting a standing process change requires user authority. Critical authority/privacy/spending/recovery failure halts affected work; other in-scope decisions are ledger rulings, never overrides of independent acceptance. Approved subscription capacity only; no billed API calls or paid fallback.

## Common mistakes

- Risk section written after the code. It must exist before the first RED.
- "Sources" listing docs from memory. A source is a URL fetched this session, with its date.
- Reviewer Challenge that only re-reads the diff. Each attempt names a target, an attack and a result.
- Counting a recurrence inside one run. Recurrence is counted across runs.
- Pausing between tasks to ask "continue?". Rule, ledger, continue; stop only for the stops.
