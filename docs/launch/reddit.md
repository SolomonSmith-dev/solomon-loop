# r/ClaudeAI post

## Title

I built a Claude Code plugin that makes subagents write risk before code and lets the reviewer try to break it (SolomonLoop, MIT)

## Body

This is my own project. I am a CS senior at CSUSB and wrote it for my own plans before packaging it.

The problem: I ran plans through subagents on real projects and every review came back clean. Then I read the diffs myself and found what the reviews missed. The reviewer had read the diff. It had not tried anything against it.

SolomonLoop adds nine steps to every subagent dispatch: define, research, assess risk, implement, verify, challenge, learn, validate, promote. The two that do the most work:

- The implementer writes a Risk section before any code, naming the security surfaces the task touches and the test for each. "None" needs a reason.
- The reviewer makes one concrete break attempt per risk (another tenant's id, tampered payload, out-of-range value) and reports target | attack | result: HELD, or BROKE with file:line. It may write one throwaway test to do it and must delete it.

Findings become lesson lines. A lesson changes the rules only when the same class recurs in two task groups, and only after you approve it.

It first ran on top of obra/superpowers and defers to that dispatcher when loaded. Standalone it ships `/solomon-loop:setup` and `/solomon-loop:run`. No telemetry.

Install:

```
/plugin marketplace add SolomonSmith-dev/solomon-loop
/plugin install solomon-loop@solomon-loop
```

Repo: https://github.com/SolomonSmith-dev/solomon-loop

What I am asking for: run it on one plan and post or open an issue with your reviewer's BROKE lines. Finding classes from codebases I have not seen are what the loop needs next.

*Register: persuasive. Anchored on: DocMind README opener.*
