# awesome-claude-code submission

## Format check (fetched 2026-11-03)

- README entry format: `- [Name](repo-url) by [author](author-url) - one-line description`, followed on many entries by a shields.io badge line (created-at, last-commit, license, stars) that the maintainers' tooling generates.
- Target section: **Agent Orchestration**, subsection **SDLC** (neighbours there: Charrette, Mycelium, napkin-to-blueprint; all plugins that gate code behind design or review steps).
- CONTRIBUTING.md says: do not open a PR. Submit through the issue form at https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml. A human must submit, one resource per submission, no `gh` CLI.
- Eligibility: the repo must be at least 14 days old with signs of active development, or have 100 or more stars. Repo public on 2026-11-03 means the earliest eligible date is **2026-11-17**, which is the first day of week 3 in the sequence.
- Description rule from the maintainers: a description, not a sales pitch, one line, no emojis.

## Entry line (README format)

```
- [SolomonLoop](https://github.com/SolomonSmith-dev/solomon-loop) by [SolomonSmith-dev](https://github.com/SolomonSmith-dev) - A Claude Code plugin that makes subagents write a Risk section before code, cite fetched sources, run real verify commands, and survive a reviewer challenge that reports HELD or BROKE per risk; lessons are promoted into the rules only when the same finding class recurs in two task groups.
```

## Issue form fields (Solomon fills these in the web UI)

- Resource name: SolomonLoop
- Link: https://github.com/SolomonSmith-dev/solomon-loop
- Category: Agent Orchestration / SDLC
- Author: SolomonSmith-dev
- License: MIT
- Description: the entry line above, after the second dash.

## Fallback PR title and body (only if the maintainers ask for a PR)

Title: `Add SolomonLoop to Agent Orchestration / SDLC`

Body:

```
Adds SolomonLoop under Agent Orchestration > SDLC.

A Claude Code plugin that adds nine steps to every subagent dispatch: define, research, assess risk, implement, verify, challenge, learn, validate, promote. The implementer writes risk before code; the reviewer makes one concrete break attempt per risk and reports HELD or BROKE with file:line. Lessons change the rules only when the same finding class recurs in two task groups, and only with the owner's approval.

Repo: https://github.com/SolomonSmith-dev/solomon-loop
License: MIT
Started as an addition to obra/superpowers; defers to its dispatcher when that skill is loaded, runs standalone otherwise.
Author submitting own project.
```

*Register: persuasive. Anchored on: PhishGuard "Why this exists".*
