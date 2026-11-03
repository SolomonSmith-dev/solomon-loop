# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-11-03

### Added

- Plugin packaging: `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, installable with two commands.
- Standalone `/solomon-loop:setup` and `/solomon-loop:run` commands that work with vanilla Claude Code.
- Superpowers adapter: defers to subagent-driven-development's dispatcher and workspace when that skill is loaded.
- Example run under `examples/todo-api/` with a real reviewer BROKE and a lessons table.
- CI workflow that runs `claude plugin validate --strict` on every push and pull request.

[Unreleased]: https://github.com/SolomonSmith-dev/solomon-loop/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/SolomonSmith-dev/solomon-loop/releases/tag/v1.0.0
