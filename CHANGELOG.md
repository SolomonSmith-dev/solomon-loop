# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- The shared lessons file now resolves the main checkout through `scripts/lessons-root.sh` (first `git worktree list` entry) instead of the git-common-dir parent, which was wrong for `git init --separate-git-dir`. Bare repositories stop with an error.

## [1.0.4] - 2026-11-10

### Changed

- Version bump so installs can tell this text from the 1.0.3 copies already in circulation. The skill, `/solomon-loop:run` and `/solomon-loop:setup` now agree, including the controller-context rules (10-line summaries, context reset after every 5 accepted tasks).
- Private role and system names removed from the public text. `scripts/check-private-names.sh` runs in CI and fails if they return.
- **Breaking:** the per-run Learn, Validate and Promote stages are replaced by one cross-run `.solomon-loop/lessons.md` (date, run, lesson, evidence pointer, recurrences). Recurrence is counted across runs when a row is appended; promotion is the owner's scheduled review of that file. `/solomon-loop:setup` finds or creates the file; the per-run `lessons.md` is gone. The per-run ledger of rulings stays.
- Correction cap wording (owner ruling 2026-11-10): the original attempt plus at most two corrections per lineage, then stop and escalate to the owner. The text now states that this cap overrides any larger round limit in an underlying skill, including the five fix rounds in subagent-driven-development.
- `skills/solomon-loop/SKILL.md` trimmed to what the loop adds over SDD; the Challenge stage, the acceptance-owner rule and the correction cap are unchanged word for word.

## [1.0.3] - 2026-11-04

### Added

- Documentation of the GitHub-sourced plugin install in a clean HOME, including enabled-plugin output, the installed skill path, and the first-push CI result.
- Review tiers: a task is **light** only when every path in its Files list and actual diff is docs, tests or fixtures; any other path, and any instruction file (`SKILL.md`, `AGENTS.md`, `CLAUDE.md`, or files under `skills/`, `commands/`, `agents/`, `prompts/`, `hooks/`, `.claude/`, `.github/`), makes it **full**. Light tier skips only the Challenge; review authority, report compliance and lessons run on every tier. A plan may raise a tier, never lower it.
- Glossary rows for independent reviewer, owner, correction attempt and review tier.

### Changed

- **Breaking:** fix rounds (up to five, the last two on a fresh implementer) are replaced by at most two correction attempts per task lineage, persisted across restarts and model or producer changes. Exhausting them escalates to the owner instead of adjudicating findings.
- An independent reviewer, never chosen by the implementer, owns exact-revision acceptance. Rulings cannot override it, and acceptance grants no release, spending or disclosure authority.
- The controller records each task's base commit in the ledger before the first dispatch and reviews `<base>..<candidate>`, so multi-commit tasks and resumed runs are reviewed whole.
- The controller binds each review to `git rev-parse HEAD`, requires it to match the implementer's reported commit before review and before check-off, and ledgers the accepted SHA.
- Implementers and reviewers write full reports to files and return at most 10 lines. The controller works from summaries and paths, batches ledger, lessons and checkbox edits into one message per task, and emits a resume line every 5 accepted tasks. Measured 2026-11-04: the controller session was 25 to 55% of each task's tokens.
- Report-compliance gaps (missing Risk, Sources, Mocks or Verification) are Minor unless the reviewer shows the defect they hide. Minors never start a correction attempt.
- Launch materials now record blog approval, the site branch and URL, and publication on 2026-11-03; the Show HN draft links to the published write-up.
- The todo-api example notes that it ran under 1.0.0.

## [1.0.0] - 2026-11-03

### Added

- Plugin packaging: `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, installable with two commands.
- Standalone `/solomon-loop:setup` and `/solomon-loop:run` commands that work with vanilla Claude Code.
- Superpowers adapter: defers to subagent-driven-development's dispatcher and workspace when that skill is loaded.
- Example run under `examples/todo-api/` with a real reviewer BROKE and a lessons table.
- CI workflow that runs `claude plugin validate --strict` on every push and pull request.

[Unreleased]: https://github.com/SolomonSmith-dev/solomon-loop/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/SolomonSmith-dev/solomon-loop/compare/v1.0.0...v1.0.3
[1.0.0]: https://github.com/SolomonSmith-dev/solomon-loop/releases/tag/v1.0.0
