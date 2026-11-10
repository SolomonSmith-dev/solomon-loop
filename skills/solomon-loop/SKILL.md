---
name: solomon-loop
description: "Use when executing a plan with subagents (one implementer per task plus a reviewer), when the user says \"run this with the loop\", \"solomon loop\" or \"loop this\", or when superpowers:subagent-driven-development is active. Adds the define, research, assess risk, implement, verify, challenge loop to every dispatch and logs lessons to one cross-run file. Not for a one-off edit with no plan."
---

# Solomon Loop

A process for making coding agents deliver reliable, secure work. Written by Solomon Smith for his own runs; the loop keeps his name.

**Define, research, assess risk, implement, verify, challenge, record lessons.**

Three loops:

- **Delivery:** finish real work against observable acceptance criteria.
- **Learning:** every run appends its lessons to one cross-run file; the owner reviews that file on a schedule.
- **Optimization:** compare an improvement against a fixed baseline in isolated copies. Keep supported improvements; reject regressions and ties.

The user sets direction and makes product decisions. Agents research, implement, verify, review failures and test improvements. **Any change to the shared process needs the user's yes before adoption.** Passing tests alone does not prove the workflow is improving.

Roles: the **controller** is the session running the plan. It dispatches one **implementer** Agent per task and keeps the production ledger. An **independent reviewer**, never chosen by the producer, reviews each task and owns exact-revision acceptance; production cannot self-accept or overrule findings. Shortcut: `/solomon-loop:setup <plan>` does the setup below and `/solomon-loop:run <plan>` runs the delivery loop.

## Setup (once per plan)

Workspace: `.solomon-loop/<plan-slug>/` in the repo root, where the slug is the plan's filename without the `.md` extension. Add it to `.gitignore` unless the user wants it tracked.

1. Write `loop-lens.md` from [loop-lens.template.md](loop-lens.template.md), filled from the plan and spec. Four short lists:
   - **Review Focus:** the plan's named failure modes (its Review Focus or risk section). None named: derive 3 to 6 from the spec and ledger a Ruling.
   - **Security/privacy surfaces:** auth, ownership checks, crypto, secrets or personal data in logs, data leaving the device, plus anything project-specific.
   - **Verify commands:** focused tests, full suite, typecheck, dependency audit, any repo check script, with the task number from which each exists.
   - **Mock boundaries:** the external services where a mock is allowed. Everything else uses real integration (real DB, real app, real primitives, real browser).
2. Find or create the cross-run lessons file `.solomon-loop/lessons.md` at the repo root from [lessons.template.md](lessons.template.md). One file for all runs; leave an existing file alone. It sits outside any per-plan workspace so a finished run cannot delete it.
3. Create `ledger.md` with the plan path, date and one line per setup decision. Every later decision is a line `Ruling (YYYY-MM-DD, Task N): <what> | <why> | <cost if wrong>` (setup rulings use `Task 0`).
4. If the repo has a shared brief file (for example `AGENTS.md`), add a short "Solomon Loop" section pointing at `loop-lens.md` and the worker sections. Edit a workspace copy, not a tracked file, unless the user says otherwise.

## Delivery loop (every task)

| Step | Who | What |
|---|---|---|
| Define | Controller | The brief is the acceptance criteria. Add the observable checks (command + expected output) to the dispatch. |
| Research | Implementer | Fetch current docs for every library or external API touched. List URL + date under **Sources**. |
| Assess risk | Implementer | Write **Risk** BEFORE coding: which Review Focus items and surfaces the task touches, and the test covering each. "None" only with a reason. |
| Implement | Implementer | Test-first. Real integration over mocks; a mock only at a listed boundary, named under **Mocks**. |
| Verify | Implementer | Run every verify command that exists by this task. Paste each command and the tail of its output. |
| Challenge | Reviewer | Full-tier tasks only: one concrete break attempt per named risk and per missed one. A break is Critical or Important. Report-compliance gaps are Minor unless they hide a shown defect. |
| Record | Reviewer, then controller | Every Critical/Important finding gets a lesson line. Controller appends it to the cross-run lessons file. |

Per unchecked task, the controller:

0. Derives the review tier: **light** only when every path in the task's files and actual diff is docs, tests or fixtures (the allowlist in `/solomon-loop:run` 1a); anything else, including instruction files such as `SKILL.md`, `AGENTS.md`, `CLAUDE.md` or anything under `skills/`, `commands/`, `agents/`, `prompts/`, `hooks/`, `.claude/`, `.github/`, is **full**. Record `git rev-parse HEAD` as the task base before the first dispatch and diff from it. Light skips only the Challenge. The plan may raise a tier, never lower it. Ledger the tier.
1. Dispatches one implementer Agent. The brief holds the task text, the acceptance checks, and [worker-report.md](worker-report.md) appended with its placeholders filled from `loop-lens.md`. The implementer commits its work, writes its report file with the loop sections first, and returns a summary of at most 10 lines. Reviewers do the same. The controller works from summaries and paths, never full reports, and confirms `git rev-parse HEAD` equals the reported commit before review and before check-off. After every 5 accepted tasks with unchecked tasks remaining, it ends the turn so a fresh session resumes from the plan checkboxes (`/solomon-loop:run` 1f).
2. Has an independent reviewer Agent dispatched, never one the implementer picked, with the diff, the implementer's report, and [reviewer-challenge.md](reviewer-challenge.md) appended. The Challenge pass allows exactly one throwaway test file, deleted before the report; `git status --porcelain` must be clean afterwards. Ledger this as a standing Ruling at setup.
3. On real findings, allow at most TWO correction attempts TOTAL per work-order lineage after initial production. Persist `correction_count` and lineage in the ledger and reports across restarts, model/producer changes, reassignment and successor orders addressing the same failure. An independent reviewer handles each scoped re-review. After two unsuccessful attempts, preserve findings and escalate to the owner; do not mark failed work complete or reset the count.
4. Appends the reviewer's lessons to the cross-run lessons file; records completion only after exact-revision acceptance by the independent reviewer and the actual done check. Review acceptance grants no execution/disclosure/spending/release authority.

After the last task: an independent reviewer runs the whole-branch Challenge scoped to cross-task risks. Any correction consumes the affected task lineage's remaining two-attempt allowance; final review grants no extra fix round. Promote only accepted results.

## Cross-run lessons

File: `.solomon-loop/lessons.md` at the repo root. Row: `| Date | Run | Lesson | Evidence | Recurrences |`.

- **Date:** last time the lesson was seen. **Run:** the plan slug. **Lesson:** finding class and the proposed improvement. **Evidence:** path to the reviewer report, with `file:line`.
- **Append rule:** before adding a row, look for one with the same finding class. Found, from a different run: add 1 to `Recurrences`, update `Date`, append the run to `Run` and the pointer to `Evidence`. Found, same run: append the pointer only. Not found: add a row with `Recurrences` 1.
- **Promotion is a scheduled review, not a stage.** On the owner's schedule, the owner reads the file. Rows with `Recurrences` of 2 or more are the candidates. The owner decides what changes; reviewed rows move under a `## Reviewed` heading with the outcome. An approved change to this skill's files counts only after a skill check passes.
- **Standing process, role and authority changes require user approval**, including changes proposed to unblock a broken task. A ledger Ruling cannot waive that requirement. Ordinary implementation fixes within the already approved task remain allowed; they do not authorize process adoption. Already approved policy changes require integration and verification, not repeated approval.

## Optimization loop

Not run inside a delivery run. It needs fixed eval tasks and isolated A/B copies against a frozen baseline. When the user asks for it: freeze the current templates as baseline, run baseline and candidate on the same fresh tasks in separate worktrees, compare finding counts, human interventions and security results. Promote only a clear win; ties and regressions are rejected.

## Stops

Check existing task authority before destructive, security-sensitive or outward actions; obtain only missing authority, never repeat an already granted approval. A task that cannot pass its check or exhausts two corrections escalates to the owner. Adopting a standing process change requires user authority. Critical authority/privacy/spending/recovery failure halts affected work; other in-scope decisions are ledger rulings, never overrides of independent acceptance.

## With superpowers

When `superpowers:subagent-driven-development` (SDD) is loaded, it runs the work and this skill only adds to it:

- SDD's prompt/report mechanics may run dispatch, but reviewer assignment stays independent and the independent reviewer owns acceptance; this approved two-total-attempt policy supersedes conflicting SDD or plugin rules. Do not silently defer the counter or acceptance authority to SDD.
- Workspace becomes SDD's: `.superpowers/sdd/<plan>/`. `loop-lens.md` and the Rulings live there, in SDD's ledger. The cross-run lessons file stays at `.solomon-loop/lessons.md`. Do the setup above after SDD's own setup.
- Before each dispatch, derive the tier and bind `[REPORT_PATH]` (worker and reviewer report files in the workspace); before each review and before check-off, confirm `git rev-parse HEAD` equals the reviewed SHA. SDD's own steps do not do this.
- Implementer: append the [worker-report.md](worker-report.md) block to SDD's implementer prompt. Its sections go in the report file before SDD's own.
- Task reviewer and re-reviewer: append the [reviewer-challenge.md](reviewer-challenge.md) block after SDD's Part 2.
- Final whole-branch review: append the Challenge section only, scoped to cross-task risks.
- Correction attempts and circuit breaker follow this skill: TWO TOTAL per work-order lineage, persisted across producer/model/restart/successor changes, then escalation to the owner.
- Stops: SDD's four plus this skill's one (adopting a process change).
- Never edit the plugin cache. The additions live in this skill's folder and in the plan's SDD workspace.

## Common mistakes

- Risk section written after the code. It must exist before the first RED.
- "Sources" listing docs from memory. A source is a URL fetched this session, with its date.
- Reviewer Challenge that only re-reads the diff. Each attempt names a target, an attack and a result.
- Leaving the throwaway test file behind, or committing it.
- Counting a recurrence inside one run. Recurrence is counted across runs.
- Rating a missing report section Important when no defect is shown. It is Minor and starts no correction.
- Pausing between tasks to ask "continue?". Rule, ledger, continue; stop only for the five stops.

## Authority and evidence

Use approved subscription capacity only; no billed API calls or paid fallback. Source/action grants, processor purpose, expiry and existing owners constrain dispatch and delivery. Critical authority/privacy/spending/recovery failure halts affected work and dependents. Preserve paused work. Prompts and static checks do not prove deterministic enforcement or runtime acceptance.
