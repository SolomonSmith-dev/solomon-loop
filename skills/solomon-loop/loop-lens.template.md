# Loop lens: [PLAN_TITLE]

Plan: [PLAN_PATH]. Written [DATE]. Fill every list from the plan and spec; delete the guidance lines once filled. These four lists are the `[PLACEHOLDER]` values for worker-report.md and reviewer-challenge.md.

## Review Focus

Guidance: the plan's named failure modes, 3 to 6 items. None named in the plan: derive them from the spec and ledger a Ruling that says so.

- [FAILURE_MODE_1]
- [FAILURE_MODE_2]
- [FAILURE_MODE_3]

## Security/privacy surfaces

Guidance: auth, ownership checks, crypto, secrets or personal data in logs, data leaving the device, plus anything this project adds. "None" needs a reason.

- [SURFACE_1]
- [SURFACE_2]

## Verify commands

Guidance: focused tests, full suite, typecheck, dependency audit, any repo check script. Note the task number from which each command exists; earlier tasks skip it.

- `[FOCUSED_TEST_COMMAND]` (from task [N])
- `[FULL_SUITE_COMMAND]` (from task [N])
- `[TYPECHECK_OR_LINT_COMMAND]` (from task [N])
- `[DEPENDENCY_AUDIT_COMMAND]` (from task [N])

## Review tiers

Derived per task by the controller from file paths, never chosen by the producer:

- **light**: every path in the task's Files list and actual diff is docs, tests or fixtures (allowlist in `/solomon-loop:run` 1a). Every reviewer section except the Challenge.
- **full**: anything else. All sections, including the Challenge and its throwaway test.
- The plan may mark a task `Review tier: full` to raise it. A plan line asking for `light` is ignored and ledgered.

## Mock boundaries

Guidance: only the external services a test may stub (third-party HTTP APIs, paid services, email senders). Everything else is real: real DB, real app, real primitives, real browser. An empty list means no mocks.

- [EXTERNAL_SERVICE_1]

## Review authority and recovery

Work-order lineage: [LINEAGE]. Persist correction_count (initial production excluded): [COUNT]. An independent reviewer, never chosen by the producer, owns exact-revision acceptance. At most TWO correction attempts TOTAL across restarts/models/producers/reassignment/successors; unresolved failure escalates to the owner. Final review gets no extra allowance. Record existing owners, paused dependencies, source/action grants, expiry and approved subscription route; no billed API calls or paid fallback.
