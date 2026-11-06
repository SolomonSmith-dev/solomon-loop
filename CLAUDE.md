# CLAUDE.md: solomon-loop

Claude Code plugin: risk-before-code, attacking reviewer, verified commands, promote lessons only when they recur.

## Folder map

- `skills/`
- `commands/`
- `docs/`
- `examples/`
- `graphify-out/`

## Routing

| You want to... | Go to |
|----------------|-------|
| Skills | `skills/` |
| Slash commands | `commands/` |
| Docs / glossary | docs/ · GLOSSARY.md |
| Examples | `examples/` |

## Triggers

| Keyword | Action |
|---------|--------|
| `setup` | Show install: claude plugin marketplace add SolomonSmith-dev/solomon-loop |
| `status` | Summarize skills, validate workflow, open docs risks |

## ICM / Graphify

When `graphify-out/graph.json` exists, answer codebase questions with `graphify query "<q>"` (also `path` / `explain`) before grep or explore agents. Rebuild with `graphify update` after large structural changes. Dual Develop: Hermes-first product build; Cursor for git/PR/evals/parallel. No secrets in commits or docs. Ops spine: `~/Projects/personal-tech-ops`.

## Hard rules

- No secrets, tokens, or `.env` values in commits, docs, or chat logs.
- Prefer project `AGENTS.md` when present; do not fork policy into duplicate files.
- Done means verified commands, not summaries of imagined output.
