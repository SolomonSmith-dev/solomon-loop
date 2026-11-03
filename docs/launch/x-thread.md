# X thread

1/ I ran plans through Claude Code subagents on real projects. Every review came back clean. Then I read the diffs myself and found what the reviews had missed. The reviewer read the code. It never tried to break it. Those are different jobs.

2/ So I wrote the rule down. SolomonLoop: a Claude Code plugin, 9 steps. Define, research, assess risk, implement, verify, challenge, learn, validate, promote. Not a prompt. A process each subagent has to report against.

3/ Step 3, assess risk, is the one people skip. The implementer writes a Risk section BEFORE any code: which security surfaces this task touches, and the test that covers each. "None" needs a reason. Same as mise en place in a kitchen. Prep before service, not during.

4/ Step 6, challenge, catches the bug. The reviewer makes one concrete break attempt per named risk: another tenant's id, a tampered payload, an out-of-range value. Reports target | attack | result: HELD, or BROKE with file:line. Re-reading the diff does not count.

5/ Step 8, validate, keeps the process from bloating. Every finding becomes a lesson line. A lesson is a candidate until the same class recurs in a second task group. One occurrence changes nothing. Two, and it gets proposed. The human approves before any rule changes.

6/ It started as an addition to @obra's superpowers and still defers to that dispatcher when the skill is loaded. Standalone, it ships /solomon-loop:setup and /solomon-loop:run. MIT. No telemetry. Nothing leaves your machine.

7/ Install:
/plugin marketplace add SolomonSmith-dev/solomon-loop
/plugin install solomon-loop@solomon-loop

Run it on one plan. Open an issue with your reviewer's BROKE lines. That is the data the loop needs.
https://github.com/SolomonSmith-dev/solomon-loop

*Register: teaching. Anchored on: 30-Day Challenge prompt design.*
