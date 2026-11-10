# SolomonLoop spec

Date: 2026-11-03. Readback confirmed by Solomon in the predev interview.

## Goal

A public Claude Code plugin, `solomon-loop`, that makes subagents write risk before code, cite fetched sources, verify with real commands, survive a reviewer challenge, and log lessons to one cross-run file reviewed on a schedule. Install in two documented commands. Works with vanilla Claude Code; defers to superpowers subagent-driven-development (SDD) when that skill is loaded.

## Non-goals

- No CLI package, no npm or PyPI publish, no domain.
- No agent-agnostic rewrite (other agent harnesses can read the markdown as-is but are not targeted).
- No post, push or repo creation without Solomon's explicit yes.
- No change to the loop's rules themselves (define, research, assess risk, implement, verify, challenge; lessons logging changed in 1.0.4).

## Interface

Install:
```
/plugin marketplace add SolomonSmith-dev/solomon-loop
/plugin install solomon-loop@solomon-loop
```
Commands:
- `/solomon-loop:setup <plan-path>`: reads a plan file, writes `.solomon-loop/<plan-slug>/loop-lens.md` (Review Focus, security surfaces, verify commands, mock boundaries) and `lessons.md` (candidate table). If `.superpowers/sdd/<plan>/` exists, writes there instead.
- `/solomon-loop:run <plan-path>`: dispatches one implementer with the worker-report block; an independent reviewer, never chosen by the producer, owns exact-revision acceptance. Persist TWO correction attempts TOTAL per task lineage across restarts/models/producers/reassignment/successors; unresolved failure escalates to the owner. SDD supplies prompt mechanics, never overrides this policy. Review acceptance grants no execution/disclosure/spending/release authority.
- Skill `solomon-loop` (auto-triggers on subagent execution): the loop rules, both templates, the SDD adapter section.

## Repo layout

```
.claude-plugin/plugin.json          name solomon-loop, version 1.0.0, MIT, author, keywords
.claude-plugin/marketplace.json     name solomon-loop, one plugin entry source ./
skills/solomon-loop/SKILL.md        + worker-report.md, reviewer-challenge.md, loop-lens.template.md
commands/setup.md, commands/run.md
examples/todo-api/                  real run output: loop-lens.md, worker report, reviewer report (one BROKE), lessons.md
docs/spec, docs/plans, docs/launch/ (posts awaiting yes), GLOSSARY.md
README.md CHANGELOG.md LICENSE CONTRIBUTING.md .github/workflows/validate.yml
```

## Data

- `loop-lens.md`: four lists, filled per plan. `lessons.md`: table `# | task group | finding class | root cause | proposed improvement | recurrences | status` with status in {candidate, supported, rejected, declined, adopted}.
- Nothing leaves the machine. No telemetry.

## Failure modes

- Plugin validates locally but a clean session cannot install: caught by the clean-session done check before the repo goes public.
- SKILL.md over 500 lines or `@path` force-loads: caught by `/skill-check` static check.
- Example files hand-written instead of produced by a run: the example task's done check requires the ledger from the run.
- README reads as marketing: my-voice persuasive register with banned-pattern check.
- Superpowers users lose today's behavior: the adapter section is tested by loading both skills in a clean session and dispatching one task.

## Done check (whole thing)

In an empty dir, fresh `claude` session: run the two install commands, then `claude plugin list` must print `solomon-loop`; run `/solomon-loop:setup docs/plans/sample.md` and `test -f .solomon-loop/sample/loop-lens.md`. Fails when the plugin is absent from the list, or the file is absent, or `claude plugin validate . --strict` exits non-zero.
