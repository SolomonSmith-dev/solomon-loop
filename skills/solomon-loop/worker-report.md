# Worker report sections (Solomon Loop)

Append this block to the implementer's brief (standalone) or to SDD's implementer prompt (with superpowers). Fill each `[PLACEHOLDER]` from the workspace `loop-lens.md` before dispatch.

```
## Solomon Loop (binding for this task)

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
```
