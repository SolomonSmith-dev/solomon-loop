# Worker report sections (Solomon Loop)

Append this block to the implementer's brief (standalone) or to SDD's implementer prompt (with superpowers). Fill each `[PLACEHOLDER]` from the workspace `loop-lens.md` before dispatch.

```
## Solomon Loop (binding for this task)

Record work-order ID/lineage, exact candidate revision and persisted correction_count (initial production is not a correction). At most TWO correction attempts TOTAL across restart/model/producer/reassignment/successor changes. An independent reviewer owns acceptance; self-review is evidence only. Escalate unresolved failure to the owner after two unsuccessful attempts. Never treat review as execution/release authority.

Your report file must contain these sections, in this order, before the standard ones:

- **Sources:** every doc you read for a library or external API this task touches: URL + date. Fetch current docs; do not work from memory.
- **Risk:** written BEFORE you write code. Which of these Review Focus items your task touches:
  [REVIEW_FOCUS]
  and which of these security/privacy surfaces:
  [SECURITY_SURFACES]
  For each one touched, name the test that covers it. "None" only with a reason.
- **Mocks:** any mock or stub you used and why. Prefer real integration. Mocks are allowed only at: [MOCK_BOUNDARIES]. Any other mock is a finding.
- **Verification:** the exact commands you ran, with the tail of each output:
  [VERIFY_COMMANDS]
- **TDD Evidence:** RED and GREEN, as the standard report format describes.

Then the standard sections: files changed, self-review, concerns.

Write the full report to [REPORT_PATH]. Your final message back is at most 10 lines and nothing else:
STATUS: done | blocked | needs-decision
COMMIT: <sha>
REPORT: [REPORT_PATH]
VERIFY: <pass/fail per verify command, one line>
RISK TOUCHED: <Review Focus items and surfaces, or none>
CONCERNS: <one line each, max 3, or none>
```
