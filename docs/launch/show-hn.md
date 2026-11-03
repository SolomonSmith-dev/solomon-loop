# Show HN

## Title

Show HN: SolomonLoop, make Claude Code subagents write risk before code

(71 characters)

## URL

https://github.com/SolomonSmith-dev/solomon-loop

## First comment

I ran plans through Claude Code subagents on real projects and every review came back clean. Then I read the diffs myself and found what the reviews had not. The reviewer had read the code. It had not tried to break it.

SolomonLoop is the fix I have run since. Nine steps: define, research, assess risk, implement, verify, challenge, learn, validate, promote. The two that matter most: the implementer writes a Risk section before any code, naming the security surfaces the task touches and the test for each. The reviewer then makes one concrete break attempt per risk and reports HELD or BROKE with file and line. Findings become lesson lines; a lesson changes the rules only when its class recurs in two task groups.

It started as an addition to obra/superpowers and defers to that dispatcher when loaded. Standalone it ships setup and run commands. MIT, no telemetry.

Write-up with the reasoning per step: https://solomonsmith.dev/blog/solomon-loop/

What I want: your reviewer's BROKE lines as issues. Finding classes from codebases I have not seen are what the loop needs.

(180 words)

*Register: persuasive. Anchored on: DocMind README opener.*
