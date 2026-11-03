# SolomonLoop

*Wisdom for coding agents: risk before code, challenge before merge.*

A Claude Code plugin that makes subagents write risk before code, cite fetched sources, verify with real commands, survive a reviewer that tries to break the work, and promote a lesson only after it recurs.

![validate](https://github.com/SolomonSmith-dev/solomon-loop/actions/workflows/validate.yml/badge.svg) ![license](https://img.shields.io/badge/license-MIT-blue.svg)

## Install

Inside Claude Code:

```
/plugin marketplace add SolomonSmith-dev/solomon-loop
/plugin install solomon-loop@solomon-loop
```

From a shell:

```
claude plugin marketplace add SolomonSmith-dev/solomon-loop
claude plugin install solomon-loop@solomon-loop
```

Requires Claude Code 2.1 or later. Nothing leaves your machine; there is no telemetry.

## Why this exists

The first plan I ran through subagents came back with zero findings. Every task clean, every report a paragraph saying the code looked fine. Then I read the diffs and found what the reviews had not. The reviewer had read the code. It had not tried to break it. Those are different jobs.

I spent ten years in kitchens before software, dishwasher to head chef. The rule that kept a line alive on a Friday night was mise en place: everything prepped and in reach before the first ticket prints. Nobody works out the sauce during service. SolomonLoop is that rule applied to coding agents. It was built against three failures.

### The review that only re-read the diff

A reviewer that reads the diff and calls it good is a second pair of eyes doing the first pair's job. The loop makes the reviewer attack: one concrete break attempt per named risk, reported as target, attack, result. A result is HELD or BROKE with a file and line. The reviewer may write one throwaway test to get there and must delete it before reporting.

### Risk written after the code

Ask an agent to "add an endpoint" and it adds an endpoint another tenant can reach. The ownership check was never in the task text, so it was never in the code. The loop makes the implementer write a Risk section before the first test: which Review Focus items and security surfaces this task touches, and the test that covers each. "None" needs a reason.

### The lesson learned once and lost

The same class of bug gets fixed in task 4 and again in task 7, and nobody notices it was the same class. Or the opposite: the brief grows a new rule after every single finding until it is 40 rules long and unread. The loop records every Critical or Important finding as a lesson line, counts recurrence across task groups, and promotes a lesson only when it recurs and you say yes.

## What it does

**Define, research, assess risk, implement, verify, challenge, learn, validate, promote.**

Three loops run on those nine steps:

- **Delivery** finishes real work against observable acceptance criteria.
- **Learning** finds why something failed and proposes a testable improvement.
- **Optimization** compares an improvement against a frozen baseline in isolated copies. Clear wins are kept; ties and regressions are rejected.

The delivery loop, per task:

| Step | Who | What |
|---|---|---|
| Define | Controller | The brief is the acceptance criteria: each check as a command plus its expected output. |
| Research | Implementer | Fetch current docs for every library or API touched. URL and date under Sources. |
| Assess risk | Implementer | Write Risk before coding: Review Focus items and surfaces touched, and the test for each. |
| Implement | Implementer | Test-first. Real integration over mocks; a mock only at a named boundary. |
| Verify | Implementer | Run every verify command that exists by this task. Paste the command and the tail of its output. |
| Challenge | Reviewer | One break attempt per named risk and per missed one. Each result is HELD or BROKE with file and line. |
| Learn | Reviewer, then controller | Every Critical or Important finding becomes a lesson line in `lessons.md`. |

The controller is your session. It dispatches one implementer Agent and one reviewer Agent per task, runs fix rounds (up to five, the last two on a fresh implementer), and keeps `ledger.md`, where every decision is one line: what, why, cost if wrong.

After the last task, one whole-branch reviewer runs the Challenge section alone, scoped to cross-task risks. One fix dispatch, one re-review, then Promote.

I do not pretend the third loop is finished. The optimization loop needs fixed eval tasks and A/B worktrees against a frozen baseline, and today it runs by hand, not as a command. What ships is the delivery and learning loops, packaged and installable, with one real run as the example.

## Use

Point setup at a plan file:

```
/solomon-loop:setup docs/plans/your-plan.md
```

It writes three files under `.solomon-loop/<plan-slug>/`, or under `.superpowers/sdd/<plan-slug>/` when that workspace already exists:

- `loop-lens.md`: Review Focus, security and privacy surfaces, verify commands with the task each exists from, and mock boundaries. Filled from the plan and its spec.
- `lessons.md`: the empty candidate table.
- `ledger.md`: the standing ruling that lets the reviewer write one throwaway test, plus any setup decision.

Then run it:

```
/solomon-loop:run docs/plans/your-plan.md
```

Per unchecked task: the implementer gets the task text, the acceptance checks, the relevant lens entries and the worker-report block. It commits and reports Sources, Risk, Mocks, Verification and TDD evidence before anything else. The reviewer gets the diff, that report and the challenge block, and returns findings by severity, every break attempt, a clean `git status --porcelain`, and lesson lines. Findings start fix rounds. The run then copies lessons, appends the ruling, checks the task off and moves to the next task without asking.

It stops for five things only:

1. An irreversible action: delete, force push, drop, overwrite outside the task's files.
2. A security-sensitive action: secrets, auth, permissions, `.env`.
3. An outward side effect: push, publish, post, send, payment.
4. A hopeless plan: a task that cannot pass its own done check, or round 5 still failing.
5. Adopting any process change mid-run.

Everything else is a ruling in the ledger, and the run keeps going.

After a run the workspace holds the whole record:

```
.solomon-loop/<plan-slug>/
  loop-lens.md                  what every worker and reviewer read first
  ledger.md                     one line per ruling, in order
  lessons.md                    candidate table with recurrence counts
  worker-report-task-N.md       one per task: Sources, Risk, Mocks, Verification
  reviewer-report-task-N.md     one per task: findings, break attempts, lessons
```

Add `.solomon-loop/` to `.gitignore` unless you want the record tracked.

### With superpowers

When `superpowers:subagent-driven-development` (SDD) is loaded, it runs the work and SolomonLoop adds to it:

- SDD's dispatcher and prompts run every dispatch; `/solomon-loop:run` defers to them instead of building its own briefs.
- The workspace becomes `.superpowers/sdd/<plan>/`; the lens, lessons and rulings live in SDD's ledger.
- The worker-report block is appended to SDD's implementer prompt; the challenge block is appended after SDD's reviewer Part 2 and to the final whole-branch review.
- Fix rounds, re-review scoping and the circuit breaker stay SDD's. Stops are SDD's four plus the one above.

## What a run looks like

[`examples/todo-api/`](examples/todo-api/) holds one unedited run on a small todo API. The reviewer's Challenge pass produced one BROKE. The files are what the run wrote, with nothing cleaned up afterwards.

Read the reviewer report first, for the attempt table. Then the worker report, for the Risk section written before the code. Then `lessons.md`, to see how the BROKE became a candidate.

## How lessons get promoted

1. **Candidate.** A reviewer finding becomes one row in `lessons.md`: task group, finding class, root cause, proposed improvement, recurrences 1.
2. **Recurrence.** A later review reports the same class in a different task group; the row's count goes up. Recurrence inside one task group does not count.
3. **Supported.** Two or more task groups and a concrete proposed change. One-offs and ties are rejected with the reason.
4. **User approves.** At the end of the run you see each supported row with the exact edit and where it goes: the repo's brief file, the `loop-lens` defaults or the skill's templates. Declines are recorded.
5. **Adopted.** The approved edit lands. A change to the skill's own files counts only after a skill check passes.

An agent never edits its own rules mid-run. Passing tests do not prove the process is improving; recurrence counts do.

## Credits

- [obra/superpowers](https://github.com/obra/superpowers): the loop first ran as a layer on its subagent-driven-development dispatcher and still plugs into it.
- [Matt Pocock's skills](https://github.com/mattpocock/skills): the "Why this exists" README pattern of named pains.
- [Anthropic's plugin docs](https://code.claude.com/docs/en/plugins): packaging, marketplace and validation.

Written by Solomon Smith, CS senior at CSUSB, ten years in kitchens before software.

## License

MIT. Copyright (c) 2026 Solomon Smith. See [LICENSE](LICENSE).

<!-- Register: persuasive. Anchored on: DocMind README opener, PhishGuard "Why this exists". -->
