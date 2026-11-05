---
description: Prepare a Solomon Loop workspace for a plan. Writes loop-lens.md, lessons.md and ledger.md next to the plan's SDD workspace or under .solomon-loop/<slug>/.
argument-hint: <plan-path>
allowed-tools: Read, Write, Edit, Bash(test *), Bash(mkdir *), Bash(/bin/ls *), Bash(basename *), Bash(git status *)
---

# Solomon Loop setup

Plan path: `$ARGUMENTS`

## 1. Read the plan

If `$ARGUMENTS` is empty or the file does not exist, stop and print exactly one line:
`solomon-loop:setup: plan not found at <path>. Pass a plan file: /solomon-loop:setup docs/plans/<name>.md`

Otherwise read the plan in full. If the plan names a spec (a `Spec:` line or a link under `docs/spec/`), read that too.

## 2. Derive the slug and pick the workspace

- Slug = the plan's filename without directory or `.md` extension (for `docs/plans/2026-11-03-launch.md` the slug is `2026-11-03-launch`).
- If `.superpowers/sdd/<slug>/` exists in the repo root, that directory is the workspace (superpowers subagent-driven-development owns the plan; this command only adds files there).
- Otherwise create `.solomon-loop/<slug>/` in the repo root and use it.

Never write into any other directory. Do not touch tracked files.

## 3. Write `<workspace>/loop-lens.md`

Read the template at `${CLAUDE_PLUGIN_ROOT}/skills/solomon-loop/loop-lens.template.md` and fill every placeholder from the plan and spec. The four lists:

1. **Review Focus**: the plan's named failure modes (a "Review Focus", "Risks", "Failure modes" or "Fails when" section). If the plan names none, derive 3 to 6 from the spec and the task list, and record that in the ledger (step 5) as `Ruling (YYYY-MM-DD, Task 0): Review Focus derived | plan named none | reviewers may attack the wrong things`.
2. **Security/privacy surfaces**: auth, ownership checks, crypto, secrets or personal data in logs, data leaving the device, plus anything the plan or spec names (tenancy, file permissions, network calls, shelling out).
3. **Verify commands**: focused tests, full suite, typecheck, dependency audit, lint, any repo check script. One line per command in the form `` `<command>` (from Task N) `` where N is the first task after which the command exists. Take commands from the plan's "Done check" lines and the repo's package or build files.
4. **Mock boundaries**: the external services where a mock is allowed (third-party APIs, paid services, email, payment). Everything else is real integration. If the plan touches no external service, write `None: all integration is real`.

Keep each list short. A line nobody can act on is a line to delete.

## 4. Write `<workspace>/lessons.md`

Copy `${CLAUDE_PLUGIN_ROOT}/skills/solomon-loop/lessons.template.md` as-is, minus its trailing HTML comment. If the file already exists, leave it alone and say so.

## 5. Write `<workspace>/ledger.md`

Create it if absent with a title line `# Solomon Loop ledger: <slug>` and this standing ruling, dated today:

```
Ruling (YYYY-MM-DD, Task 0): the task reviewer's Challenge pass may create ONE throwaway test file in the relevant package's test folder, run only that file, then delete it; `git status --porcelain` must show nothing new afterwards and the reviewer's report must say so | a reviewer that cannot run an attack only re-reads the diff | a stray test file lands in the diff
```

Append any `Ruling:` line from step 3. If `ledger.md` already exists, append only rulings that are not already present.

## 6. Preserve review authority

Before dispatch record the work-order lineage and persisted correction_count, preserving any existing count from predecessor/successor work on the same failure. Initial production is separate; at most TWO correction attempts TOTAL. Review Office independently selects reviewers and owns exact-revision acceptance. Producer and SDD cannot reset the count or override findings; unresolved failure escalates through Ilúvatar to Solomon. Review acceptance grants no execution/release authority.

## 7. Report

Print the three absolute paths, one per line, then one line saying which workspace rule applied (`SDD workspace found` or `created .solomon-loop/<slug>/`). Nothing else. Do not start running tasks; that is `/solomon-loop:run <plan-path>`.
