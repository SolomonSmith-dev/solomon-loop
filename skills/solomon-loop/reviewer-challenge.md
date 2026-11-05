# Reviewer additions (Solomon Loop)

Append this block to the reviewer's brief (standalone) or to SDD's task-reviewer prompt after Part 2 (with superpowers), and to the re-review prompt for the fix it covers. Standalone, Parts 1 and 2 are spec compliance and code quality; Part 3 starts here. Fill `[PLACEHOLDER]` values from the workspace `loop-lens.md`. For a **light**-tier task, drop Part 3 and send Parts 1, 2 and 4 only.

```
## Part 3: Challenge

Review Office independently assigns this review and owns exact-revision acceptance; the producer cannot choose the accepting reviewer, self-accept or overrule findings. Verify persisted lineage/correction_count: at most TWO correction attempts TOTAL after initial production, across restarts/models/producers/reassignment/successors. Two unsuccessful attempts escalate via Ilúvatar to Solomon. Acceptance grants no execution/disclosure/spending/release authority.

For each risk the implementer's **Risk** section names, and any of these the diff touches that it missed:
  Review Focus: [REVIEW_FOCUS]
  Surfaces: [SECURITY_SURFACES]
try ONE concrete break: an attack, an edge input, another tenant's id, an unauthorized caller, a tampered payload, a missing or out-of-range value.

You may create ONE throwaway test file in the relevant package's test folder, run only that file, then delete it. `git status --porcelain` must show nothing new afterwards; say so in the report. This is the only write you may make.

Report each attempt as: target | attack | result (HELD, or BROKE with file:line). A BROKE is Critical or Important.

Also check report compliance. Each gap is **Minor** by default:
- **Risk** section is missing, or says "None" without a reason, or was clearly written after the code.
- **Sources** missing for a new library or external API call.
- A mock outside these boundaries: [MOCK_BOUNDARIES].
- **Verification** lacks any of: [VERIFY_COMMANDS].

A compliance gap becomes **Important** only when you show the defect it hides: a BROKE result, a failing or missing check you ran, or file:line behavior that contradicts the spec or current docs. Name that defect in the finding. "The section is missing" alone is never Important. A Minor never starts a correction attempt; it rides along with one that real findings already started.

## Part 4: Lessons

For every Critical or Important finding (Parts 1 to 3), one line:

finding-class (short kebab-case) | why the worker likely missed it (brief gap, missing context, process gap) | a testable improvement to the brief, the shared brief file, or this reviewer block

Compliance Minors also get one line, class prefixed `report-` (for example `report-missing-sources`), so recurrence tracking still sees them.

No Critical or Important findings and no compliance Minors: write "Lessons: none".

Write the full report to [REPORT_PATH]. Your final message back is at most 10 lines and nothing else:
VERDICT: accept | corrections-needed
TIER: full | light
BROKE: <target | file:line, one line each, or none>
IMPORTANT: <count> CRITICAL: <count> MINOR: <count>
LESSONS: <finding classes, comma-separated, or none>
CLEAN TREE: yes | no
```
