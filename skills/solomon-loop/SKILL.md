---
name: solomon-loop
description: "Use when executing a plan with subagents (one implementer per task plus a reviewer), when the user says \"run this with the loop\", \"solomon loop\" or \"loop this\", or when superpowers:subagent-driven-development is active. Adds the define, research, assess risk, implement, verify, challenge, learn, validate, promote loop to every dispatch. Not for a one-off edit with no plan."
---

# Solomon Loop

A process for making coding agents deliver reliable, secure work. Written by Solomon Smith for his own runs; the loop keeps his name.

**Define, research, assess risk, implement, verify, challenge, learn, validate, promote.**

Three loops:

- **Delivery:** finish real work against observable acceptance criteria.
- **Learning:** find why something failed and propose a testable improvement.
- **Optimization:** compare an improvement against a fixed baseline in isolated copies. Keep supported improvements; reject regressions and ties.

The user sets direction and makes product decisions. Agents research, implement, verify, review failures and test improvements. **Any change to the shared process needs the user's yes before adoption.** Passing tests alone does not prove the workflow is improving.

Roles: the **controller** is the session running the plan. It dispatches one **implementer** Agent per task and one **reviewer** Agent per task, and keeps the ledger. Shortcut: `/solomon-loop:setup <plan>` does the setup below and `/solomon-loop:run <plan>` runs the delivery loop.

## Setup (once per plan)

Workspace: `.solomon-loop/<plan-slug>/` in the repo root, where the slug is the plan's filename without the `.md` extension. Add it to `.gitignore` unless the user wants it tracked.

1. Write `loop-lens.md` from [loop-lens.template.md](loop-lens.template.md), filled from the plan and spec. Four short lists:
   - **Review Focus:** the plan's named failure modes (its Review Focus or risk section). None named: derive 3 to 6 from the spec and ledger a Ruling.
   - **Security/privacy surfaces:** auth, ownership checks, crypto, secrets or personal data in logs, data leaving the device, plus anything project-specific.
   - **Verify commands:** focused tests, full suite, typecheck, dependency audit, any repo check script, with the task number from which each exists.
   - **Mock boundaries:** the external services where a mock is allowed. Everything else uses real integration (real DB, real app, real primitives, real browser).
2. Create `lessons.md` from [lessons.template.md](lessons.template.md).
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
| Challenge | Reviewer | One concrete break attempt per named risk and per missed one. A break is Critical or Important. |
| Learn | Reviewer, then controller | Every Critical/Important finding gets a lesson line. Controller copies it into `lessons.md`. |

Per unchecked task, the controller:

1. Dispatches one implementer Agent. The brief holds the task text, the acceptance checks, and [worker-report.md](worker-report.md) appended with its placeholders filled from `loop-lens.md`. The implementer commits its work and writes its report with the loop sections first.
2. Dispatches one reviewer Agent with the diff, the implementer's report, and [reviewer-challenge.md](reviewer-challenge.md) appended. The Challenge pass allows exactly one throwaway test file, deleted before the report; `git status --porcelain` must be clean afterwards. Ledger this as a standing Ruling at setup.
3. On findings: fix rounds up to 5. Rounds 1 to 3 resume the same implementer; rounds 4 and 5 use a fresh implementer on a more capable model. Each fix gets a scoped re-review with the Challenge block limited to the fixed findings. At round 5, adjudicate each open finding, ledger a Ruling, and move on.
4. Copies lesson lines into `lessons.md`, appends the completion to `ledger.md`, checks the task off in the plan.

After the last task: one whole-branch reviewer with the Challenge section only, scoped to cross-task risks. One fix dispatch, one re-review, then Promote.

## Learning loop (inside the run)

- **Validate:** a lesson is a CANDIDATE. Its test is the finding-class count in later task reviews; baseline is the task groups before it. Bump `Recurrences` when a later review reports the same class.
- **Supported** = the class recurs in 2 or more task groups and a concrete proposed change exists. One-offs and ties are rejected; mark them `rejected` with the reason.
- **No mid-run process changes** without the user's yes, except a fix that unblocks a broken task, ledgered as a Ruling.

## Promote (end of run)

1. After the final review, show the user each supported candidate: finding class, groups it recurred in, the exact proposed edit, and where it goes (the repo's brief file, `loop-lens` defaults, or this skill's templates).
2. Apply only what the user approves. Mark the rest `declined` in `lessons.md`.
3. An approved change to this skill's files gets a skill check (frontmatter, length, trigger test) before it counts as adopted.

## Optimization loop

Not run inside a delivery run. It needs fixed eval tasks and isolated A/B copies against a frozen baseline. When the user asks for it: freeze the current templates as baseline, run baseline and candidate on the same fresh tasks in separate worktrees, compare finding counts, human interventions and security results. Promote only a clear win; ties and regressions are rejected.

## Stops

Four things stop a run: an irreversible or destructive operation; a security-sensitive action; a side effect outside the worktree (merge, push to a shared branch, publish); a plan so broken that every path forward is a guess. The loop adds one: adopting any process change. Everything else is a Ruling in the ledger, and the run keeps going.

## With superpowers

When `superpowers:subagent-driven-development` (SDD) is loaded, it runs the work and this skill only adds to it:

- SDD's dispatcher and prompts (`implementer-prompt.md`, `task-reviewer-prompt.md`, `re-review-prompt.md`, final code reviewer) run every dispatch. Do not build separate briefs; `/solomon-loop:run` defers to SDD.
- Workspace becomes SDD's: `.superpowers/sdd/<plan>/`. `loop-lens.md`, `lessons.md` and the Rulings live there, in SDD's ledger. Do the setup above after SDD's own setup.
- Implementer: append the [worker-report.md](worker-report.md) block to SDD's implementer prompt. Its sections go in the report file before SDD's own.
- Task reviewer and re-reviewer: append the [reviewer-challenge.md](reviewer-challenge.md) block after SDD's Part 2.
- Final whole-branch review: append the Challenge section only, scoped to cross-task risks.
- Fix rounds, re-review scoping and the circuit breaker are SDD's.
- Stops: SDD's four plus this skill's one (adopting a process change).
- Never edit the plugin cache. The additions live in this skill's folder and in the plan's SDD workspace.

## Common mistakes

- Risk section written after the code. It must exist before the first RED.
- "Sources" listing docs from memory. A source is a URL fetched this session, with its date.
- Reviewer Challenge that only re-reads the diff. Each attempt names a target, an attack and a result.
- Leaving the throwaway test file behind, or committing it.
- Promoting a lesson that appeared once. One occurrence is a candidate, not evidence.
- Pausing between tasks to ask "continue?". Rule, ledger, continue; stop only for the five stops.
