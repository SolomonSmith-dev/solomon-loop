# Reviewer additions (Solomon Loop)

Append this block to the reviewer's brief (standalone) or to SDD's task-reviewer prompt after Part 2 (with superpowers), and to the re-review prompt for the fix it covers. Standalone, Parts 1 and 2 are spec compliance and code quality; Part 3 starts here. Fill `[PLACEHOLDER]` values from the workspace `loop-lens.md`.

```
## Part 3: Challenge

Review Office independently assigns this review and owns exact-revision acceptance; the producer cannot choose the accepting reviewer, self-accept or overrule findings. Verify persisted lineage/correction_count: at most TWO correction attempts TOTAL after initial production, across restarts/models/producers/reassignment/successors. Two unsuccessful attempts escalate via Ilúvatar to Solomon. Acceptance grants no execution/disclosure/spending/release authority.

For each risk the implementer's **Risk** section names, and any of these the diff touches that it missed:
  Review Focus: [REVIEW_FOCUS]
  Surfaces: [SECURITY_SURFACES]
try ONE concrete break: an attack, an edge input, another tenant's id, an unauthorized caller, a tampered payload, a missing or out-of-range value.

You may create ONE throwaway test file in the relevant package's test folder, run only that file, then delete it. `git status --porcelain` must show nothing new afterwards; say so in the report. This is the only write you may make.

Report each attempt as: target | attack | result (HELD, or BROKE with file:line). A BROKE is Critical or Important.

Also check, each missing item is Important:
- **Risk** section is missing, or says "None" without a reason, or was clearly written after the code.
- **Sources** missing for a new library or external API call.
- A mock outside these boundaries: [MOCK_BOUNDARIES].
- **Verification** lacks any of: [VERIFY_COMMANDS].

## Part 4: Lessons

For every Critical or Important finding (Parts 1 to 3), one line:

finding-class (short kebab-case) | why the worker likely missed it (brief gap, missing context, process gap) | a testable improvement to the brief, the shared brief file, or this reviewer block

No Critical or Important findings: write "Lessons: none".
```
