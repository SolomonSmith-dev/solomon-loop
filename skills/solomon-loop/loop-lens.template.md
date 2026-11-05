# Loop lens: [PLAN_TITLE]

Plan: [PLAN_PATH]. Written [DATE]. Fill every list from the plan and spec; delete the guidance lines once filled. These four lists are the `[PLACEHOLDER]` values for worker-report.md and reviewer-challenge.md.

## Review Focus

Guidance: the plan's named failure modes, 3 to 6 items. None named in the plan: derive them from the spec and ledger a Ruling that says so.

Each item ends with `Paths:` and the repo globs where it lives (used for review tiers).

- [FAILURE_MODE_1]. Paths: `[GLOB]`
- [FAILURE_MODE_2]. Paths: `[GLOB]`
- [FAILURE_MODE_3]. Paths: `[GLOB]`

## Security/privacy surfaces

Guidance: auth, ownership checks, crypto, secrets or personal data in logs, data leaving the device, plus anything this project adds. "None" needs a reason.

Each item ends with `Paths:` and the repo globs where it lives. A surface that cannot be pinned to paths gets `Paths: *` (every task is full tier).

- [SURFACE_1]. Paths: `[GLOB]`
- [SURFACE_2]. Paths: `[GLOB]`

## Verify commands

Guidance: focused tests, full suite, typecheck, dependency audit, any repo check script. Note the task number from which each command exists; earlier tasks skip it.

- `[FOCUSED_TEST_COMMAND]` (from task [N])
- `[FULL_SUITE_COMMAND]` (from task [N])
- `[TYPECHECK_OR_LINT_COMMAND]` (from task [N])
- `[DEPENDENCY_AUDIT_COMMAND]` (from task [N])

## Review tiers

Derived per task by the controller, never chosen by the producer:

- **full**: the task's Files list or its actual diff matches any `Paths:` glob above, or touches a dependency manifest, lockfile, migration, CI config or auth/env config. Parts 1 to 4.
- **light**: nothing matches. Every reviewer section except the Challenge: no break attempts, no throwaway test; report compliance and lessons still run.
- The plan may mark a task `Review tier: full` to raise it. A plan line asking for `light` is ignored and ledgered.

## Mock boundaries

Guidance: only the external services a test may stub (third-party HTTP APIs, paid services, email senders). Everything else is real: real DB, real app, real primitives, real browser. An empty list means no mocks.

- [EXTERNAL_SERVICE_1]

## Review authority and recovery

Work-order lineage: [LINEAGE]. Persist correction_count (initial production excluded): [COUNT]. An independent reviewer, never chosen by the producer, owns exact-revision acceptance. At most TWO correction attempts TOTAL across restarts/models/producers/reassignment/successors; unresolved failure escalates to the owner. Final review gets no extra allowance. Record existing owners, paused dependencies, source/action grants, expiry and approved subscription route; no billed API calls or paid fallback.
