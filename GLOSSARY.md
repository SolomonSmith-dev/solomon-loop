# Glossary

| Term | Definition |
| :- | :- |
| loop-lens | The per-plan file (`loop-lens.md`) holding the Review Focus, security surfaces, verify commands and mock boundaries that every worker and reviewer reads before acting. |
| Review Focus | The short list of concerns the reviewer must check first for this plan, written before any code exists. |
| security surface | A place where untrusted input, credentials or another owner's data can reach the code under change. Each one is named in the loop-lens and must be addressed in the worker report. |
| mock boundary | The line between what tests may fake and what they must exercise for real. Mocking past the boundary makes a verify command meaningless. |
| verify command | A real shell command, with its expected passing and failing output, that proves a task's claim. A check that cannot fail is not a verify command. |
| worker report | The structured block an implementer subagent returns: risks written before code, sources fetched and cited, verify commands run with output, and open questions. |
| challenge | The reviewer subagent's attempt to break each risk claim in the worker report, by reading code, running commands or constructing a counterexample. |
| HELD | A challenge outcome: the reviewer tried to break the claim and could not. |
| BROKE | A challenge outcome: the reviewer found a counterexample or a failing command, so the task returns for a fix round. |
| lesson | One row in `lessons.md`: task group, finding class, root cause, proposed improvement, recurrence count and status. |
| candidate | Lesson status for a finding seen once. It is recorded and nothing else changes. |
| supported | Lesson status once the same finding class recurred in a second task group. It is eligible for promotion. |
| rejected | Lesson status when the controller decides the proposed improvement is wrong or would not have prevented the finding. |
| declined | Lesson status when the improvement is sound but the owner chooses not to adopt it, with the reason recorded. |
| adopted | Lesson status once the improvement has been written into the loop's rules or templates. |
| ruling | The controller's one-line decision on a reviewer finding (accept, fix, or override with reason), recorded in the ledger. |
| ledger | The per-plan `ledger.md` that records each dispatch, challenge outcome, ruling and lesson line in order. |
| promote | Moving a supported lesson into the loop's rules or templates. Requires the same finding class in at least two task groups. |
| task group | A set of plan tasks that touch the same component or concern. Recurrence is counted across task groups, not within one. |
