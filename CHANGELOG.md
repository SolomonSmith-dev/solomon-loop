# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2026-11-04

### Added

- Documentation of the GitHub-sourced plugin install in a clean HOME, including enabled-plugin output, the installed skill path, and the first-push CI result.
- Review tiers: each task is **full** or **light**, derived from new `Paths:` globs on every loop-lens Review Focus item and surface, matched against the task's files and its actual diff, plus dependency manifests, lockfiles, migrations, CI and auth/env config. Light tier skips the Challenge. A plan may raise a tier, never lower it.
- Glossary rows for independent reviewer, owner, correction attempt and review tier.

### Changed

- **Breaking:** fix rounds (up to five, the last two on a fresh implementer) are replaced by at most two correction attempts per task lineage, persisted across restarts and model or producer changes. Exhausting them escalates to the owner instead of adjudicating findings.
- An independent reviewer, never chosen by the implementer, owns exact-revision acceptance. Rulings cannot override it, and acceptance grants no release, spending or disclosure authority.
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
