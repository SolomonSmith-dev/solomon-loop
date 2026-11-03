# Install proof, 2026-11-03 (local marketplace, before the GitHub push)

Clean HOME (empty temp dir), empty project with `docs/plans/sample.md`.

```
$ claude plugin marketplace add /Users/solomonsmith/Projects/solomon-loop
✔ Successfully added marketplace: solomon-loop (declared in user settings)
$ claude plugin install solomon-loop@solomon-loop --scope user
✔ Successfully installed plugin: solomon-loop@solomon-loop (scope: user)
$ claude plugin list
  ❯ solomon-loop@solomon-loop
    Version: 1.0.0
    Scope: user
    Status: ✔ enabled
```

Headless command run (clean HOME has no login, so this step ran with the real HOME and `--plugin-dir`):

```
$ claude -p "/solomon-loop:setup docs/plans/sample.md" --plugin-dir /Users/solomonsmith/Projects/solomon-loop --permission-mode acceptEdits
.solomon-loop/sample/loop-lens.md
.solomon-loop/sample/lessons.md
.solomon-loop/sample/ledger.md
created .solomon-loop/sample/
```

`loop-lens.md` carried the plan's two Review Focus items, `node --test` as the verify command, and "None: all integration is real" for mocks. `ledger.md` carried the standing throwaway-test Ruling.

Finding: the lessons header block at the end of `loop-lens.template.md` was copied into `loop-lens.md`. Fixed by moving it to `lessons.template.md`.

GitHub-sourced proof: pending the public push (Task 9).

## GitHub-sourced proof (after the public push, 2026-11-03)

Clean HOME (empty temp dir):

```
$ claude plugin marketplace add SolomonSmith-dev/solomon-loop
✔ Successfully added marketplace: solomon-loop (declared in user settings)
$ claude plugin install solomon-loop@solomon-loop --scope user
✔ Successfully installed plugin: solomon-loop@solomon-loop (scope: user)
$ claude plugin list
  ❯ solomon-loop@solomon-loop
    Version: 1.0.0
    Scope: user
    Status: ✔ enabled
```

`SKILL.md` present at `.claude/plugins/cache/solomon-loop/solomon-loop/1.0.0/skills/solomon-loop/SKILL.md`. CI run 41618042811 (validate) passed on the first push.
