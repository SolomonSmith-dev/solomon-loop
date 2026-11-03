# SolomonLoop spec

Date: 2026-11-03. Readback confirmed by Solomon in the predev interview.

## Goal

A public Claude Code plugin, `solomon-loop`, that makes subagents write risk before code, cite fetched sources, verify with real commands, survive a reviewer challenge, and only promote lessons that recur. Install in two documented commands. Works with vanilla Claude Code; defers to superpowers subagent-driven-development (SDD) when that skill is loaded.

## Non-goals

- No CLI package, no npm or PyPI publish, no domain.
- No agent-agnostic rewrite (Codex, Hermes read the markdown as-is but are not targeted).
- No post, push or repo creation without Solomon's explicit yes.
- No change to the loop's rules themselves (define, research, assess risk, implement, verify, challenge, learn, validate, promote).

## Interface

Install:
```
/plugin marketplace add SolomonSmith-dev/solomon-loop
/plugin install solomon-loop@solomon-loop
```
Commands:
- `/solomon-loop:setup <plan-path>`: reads a plan file, writes `.solomon-loop/<plan-slug>/loop-lens.md` (Review Focus, security surfaces, verify commands, mock boundaries) and `lessons.md` (candidate table). If `.superpowers/sdd/<plan>/` exists, writes there instead.
- `/solomon-loop:run <plan-path>`: for each unchecked task, dispatches one implementer Agent with the worker-report block, then one reviewer Agent with the challenge block; keeps `ledger.md` with rulings and lesson lines; stops only for the SDD four stops plus "adopt a process change". When SDD is loaded, the skill tells the controller to use SDD's dispatcher and append the blocks to SDD's prompts (today's behavior).
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
