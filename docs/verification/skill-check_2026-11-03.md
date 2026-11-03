# Skill check: solomon-loop:solomon-loop (plugin, 1.0.0)

Procedure: `~/.claude/skills/skill-check/SKILL.md`, six checks in order. Run 2026-11-03 against `/Users/solomonsmith/Projects/solomon-loop` via `--plugin-dir` (plugin not installed in the real HOME). Scratch: `/private/tmp/claude-501/-Users-solomonsmith-Projects/a26623a7-cbfe-4aa0-8829-d9e5a0965cd3/scratchpad/skillcheck/`.

## Verdict: pass with notes

No safety flag, static clean, plugin loads and lists its skill and both commands, behavior check shows a real difference. The trigger check could not be measured cleanly: this HOME also has the private `~/.claude/skills/solomon-loop` (same bare name), and every hit prompt invoked that one instead of `solomon-loop:solomon-loop`. Re-run the trigger check on a HOME without the private copy before calling the plugin skill proven.

## 1. Safety read

Files read in full: `skills/solomon-loop/{SKILL.md, worker-report.md, reviewer-challenge.md, loop-lens.template.md, lessons.template.md}`, `commands/{run.md, setup.md}`, `.claude-plugin/{plugin.json, marketplace.json}` (icon.png checked with `file`: PNG 1024x1024), `.github/workflows/validate.yml`, `.gitignore`.

- Nothing sends data off the machine. No curl, wget, webhooks, mail, or network writes in any skill or command file.
- No `curl | sh`, no `pip install` from a URL. The only install is in CI: `run: npm install -g @anthropic-ai/claude-code` (validate.yml, GitHub runner only, registry package, no credentials).
- No writes outside the repo: setup.md says "Never write into any other directory. Do not touch tracked files."; the skill says "Never edit the plugin cache."
- No credential requests, no encoded or hidden text, no instructions to ignore rules. `allowed-tools` on both commands is a narrow allowlist (`Bash(test *)`, `Bash(git status *)`, etc.).

Flags: none.

## 2. Static

Injected violation first (`/bin/cp -Rf` of the folder to scratch, then `See @docs/x.md for details.` appended):

```
FAIL: @path force-load found:
98:See @docs/x.md for details.
exit=1
```

Real folder:

```
OK: solomon-loop (      96 lines)
exit=0
```

## 3. Load

`claude -p "Is a skill named solomon-loop available in this session? ..." --plugin-dir /Users/solomonsmith/Projects/solomon-loop --max-turns 3` answered:

> Yes, it's available. **solomon-loop**: "Use whenever a plan is executed with subagents (subagent-driven development, one subagent per task with reviews), loaded together with superpowers:subagent-driven-development, and when Solomon says "run this with my loop", "use the Solomon Loop" or "loop this"."

That is the private skill's description, not the plugin's. A follow-up listing query in the same configuration returned four names, which proves the plugin loaded under its namespace:

```
solomon-loop: Use whenever a plan is executed with subagents (subagent-driven development, one subagent
solomon-loop:run: Run a plan with the Solomon Loop. One implementer Agent then one
solomon-loop:setup: Prepare a Solomon Loop workspace for a plan. Writes loop-lens.md, lessons.md and
solomon-loop:solomon-loop: Use when executing a plan with subagents (one implementer per task plus
```

Load: pass (skill present as `solomon-loop:solomon-loop`, both commands present).

## 4. Trigger

`trigger-check.sh` has no way to pass `--plugin-dir`, so the equivalent loop was run by hand: `claude -p --plugin-dir ... --output-format stream-json --verbose --max-turns 2 "<prompt>"`, counting Skill tool calls whose `input.skill` contains `solomon-loop:solomon-loop`. Prompts: `scratchpad/skillcheck/prompts.json`. Raw output: `raw_0.json` to `raw_5.json`.

```
UNEXPECTED  want=true got=false skills=[solomon-loop,superpowers:subagent-driven-development,] :: I have an implementation plan at docs/plans/share-links.md with six tasks. Execute it by d
UNEXPECTED  want=true got=false skills=[solomon-loop:run,] :: loop this plan: docs/plans/2026-11-03-launch.md
UNEXPECTED  want=true got=false skills=[solomon-loop,superpowers:subagent-driven-development,] :: Let's do subagent-driven development on the auth refactor plan: implementer subagent per t
ok  want=false got=false skills=[] :: Rename the function parseDate to parseIsoDate in src/utils/date.ts and update its two call
ok  want=false got=false skills=[] :: What is a for loop and how is it different from a while loop? Give a short Python example.
ok  want=false got=false skills=[superpowers:writing-plans,] :: Write an implementation plan for adding share links to the notes app, with tasks and done 
```

Reading: misses 0 of 3 triggered (clean). Hits: all three invoked a solomon-loop entry, but the bare-name private skill won twice and the plugin's `solomon-loop:run` command won once; the namespaced plugin skill scored 0 of 3. The loop content is the same, so the intent triggered 3 of 3, but this run cannot show the plugin skill's own description pulling its weight. An isolated `CLAUDE_CONFIG_DIR` was tried and refused with `Not logged in`, so the shadowing could not be removed without touching the real HOME.

## 5. Behavior

Scratch repo `scratchpad/skillcheck/behave-repo` with a two-task plan (`docs/plans/greeting.md`: `hello(name)` then a CLI, with Review Focus and a verify command). Two general-purpose subagents in one turn, each asked for the Task 1 implementer brief, text only. Both briefs read in full from `brief-without.md` (80 lines) and `brief-with.md` (96 lines).

- Without: a competent conventional brief (goal, files, scaffolding, test-first order, done check with known failing outputs, report list) with no Sources, no Risk-before-code, no mock policy, no verify-command list and no commit.
- With: the worker-report block appended with Review Focus, surfaces, mock boundaries and verify commands filled from an inlined loop lens; Risk required before any code, Sources with URL and date, a Ruling line for the derived `pyproject.toml`, `git status --porcelain` as an acceptance check, one commit required.

The skill changes the brief; it is pulling its weight.

## 6. Notes for the author

1. Slug definition disagrees: SKILL.md says "the plan's filename without date and extension"; `commands/setup.md` and `run.md` say "without directory or `.md`" and keep the date (`2026-11-03-launch`). Pick one, or `/solomon-loop:run` and a hand-run session will use two workspaces.
2. Ruling format appears three ways: SKILL.md `Ruling: <what> | <why> | <cost if wrong>`, run.md `Ruling (YYYY-MM-DD, Task N): <decision and reason>`, setup.md `Ruling (YYYY-MM-DD): ...`. One format.
3. Fix rounds 4 and 5: SKILL.md says "a fresh implementer on a more capable model"; run.md says only "a fresh implementer Agent". Say the model step in both or neither.
4. Name collision: anyone with a personal skill called `solomon-loop` gets the shadowing seen in check 4. For this machine, retire `~/dotfiles/skills/solomon-loop` once the plugin is installed, then re-run the trigger check.
5. `trigger-check.sh` (the checker, not the plugin) cannot test an uninstalled plugin; a `--plugin-dir` passthrough would make this check repeatable.
