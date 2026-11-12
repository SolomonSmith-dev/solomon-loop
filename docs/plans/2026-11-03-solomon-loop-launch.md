# SolomonLoop launch plan, 2026-11-03

Spec: docs/spec/solomon-loop.md. Method: one fresh subagent per task, controller reviews each. Every brief: use `/bin/cp -f` and `/bin/rm -f`, never bare `cp` or `rm`; no em dashes; no attribution trailers.

### Task 1: Scaffold the plugin repo
Owner: Claude (subagent)
Files: .claude-plugin/plugin.json, .claude-plugin/marketplace.json, LICENSE, CONTRIBUTING.md, GLOSSARY.md, CHANGELOG.md, .gitignore
Steps:
1. Write plugin.json (name solomon-loop, version 1.0.0, description, author Solomon Smith, homepage, repository, license MIT, keywords) and marketplace.json (name solomon-loop, owner, one plugin entry, source ./).
2. MIT LICENSE, CONTRIBUTING (issues welcome, lessons PRs need two recurrences), GLOSSARY (loop-lens, lesson, candidate, supported, challenge, HELD/BROKE, promote, ruling), CHANGELOG Keep a Changelog with 1.0.0 Unreleased.
Done check: `claude plugin validate . --strict`
Fails when: exit code 1 or any line starting with `✖` or `warning`

### Task 2: Port the skill to standalone with the SDD adapter
Owner: Claude (subagent)
Files: skills/solomon-loop/SKILL.md, worker-report.md, reviewer-challenge.md, loop-lens.template.md
Steps:
1. Copy the three files from ~/dotfiles/skills/solomon-loop. Rewrite SKILL.md: description starts with "Use when"; setup and delivery sections no longer require superpowers; a "With superpowers" section says exactly what changes (SDD dispatcher, `.superpowers/sdd/<plan>/` workspace, blocks appended to SDD prompts).
2. Add loop-lens.template.md with the four lists and placeholders.
Done check: `bash ~/.claude/skills/skill-check/scripts/static-check.sh skills/solomon-loop && grep -c "superpowers" skills/solomon-loop/SKILL.md`
Fails when: static-check exits non-zero, or the grep count is 0 (adapter missing) or SKILL.md exceeds 500 lines

### Task 3: Write the two commands
Owner: Claude (subagent)
Files: commands/setup.md, commands/run.md
Steps:
1. setup.md: frontmatter (description, argument-hint), reads $ARGUMENTS plan path, derives slug, picks workspace (`.superpowers/sdd/<plan>/` if present else `.solomon-loop/<slug>/`), writes loop-lens.md from the template and lessons.md header, prints the paths.
2. run.md: per unchecked task dispatch implementer Agent with worker block then reviewer Agent with challenge block, ledger.md with rulings, fix rounds up to 5, stops list, promote step at the end.
Done check: `claude plugin validate . --strict && grep -l "argument-hint" commands/*.md | wc -l`
Fails when: validate exits non-zero or the count is not 2

### Task 4: CI workflow
Owner: Claude (subagent)
Files: .github/workflows/validate.yml
Steps:
1. Verify locally that `claude plugin validate` works with no credentials: `env -i PATH="$PATH" HOME=$(mktemp -d) claude plugin validate . --strict`. If it fails for auth, write a shell fallback `scripts/check-plugin.sh` that parses both JSON files with jq and checks referenced paths exist.
2. Workflow on push and pull_request: checkout, install Claude Code (`npm i -g @anthropic-ai/claude-code`) or run the fallback, run validate, run a markdown link check (lychee action) on README.md.
Done check: `env -i PATH="$PATH" HOME=$(mktemp -d) claude plugin validate . --strict; echo $?` and `yq . .github/workflows/validate.yml >/dev/null`
Fails when: the chosen validate step exits non-zero without credentials, or yq reports a parse error

### Task 5: Real example run on a throwaway repo
Owner: Claude (subagent)
Files: examples/todo-api/{plan.md,loop-lens.md,worker-report-task-1.md,reviewer-report-task-1.md,lessons.md,ledger.md,README.md}
Steps:
1. In a scratch dir, create a tiny Node or Python todo API with a 2-task plan (add item with validation, list items per owner).
2. Run `/solomon-loop:setup` then `/solomon-loop:run` via `claude -p` with the plugin loaded from `--plugin-dir`, or dispatch the Agents by hand following commands/run.md exactly. The reviewer must get a real BROKE on at least one risk (cross-owner read is a good target).
3. Copy the produced files into examples/todo-api with a README explaining what to look at.
Done check: `grep -l "BROKE" examples/todo-api/reviewer-report-task-1.md && grep -c "supported\|rejected" examples/todo-api/lessons.md`
Fails when: no file contains BROKE, or lessons.md has neither a supported nor a rejected row

### Task 6: README in Solomon's voice
Owner: Claude (subagent, loads ~/.claude/skills/my-voice fully, persuasive register)
Files: README.md
Steps:
1. Hero: name, tagline "Wisdom for coding agents: risk before code, challenge before merge", one sentence of what, install block within the first 25 lines, CI badge.
2. Sections: Why this exists, What it does (the nine steps, three loops), Install, Use (setup, run, with superpowers), What a run looks like (link examples), How lessons get promoted, Credits (obra/superpowers, Matt Pocock skills patterns), License.
Done check: `grep -nE "leverage|seamless|robust|delve|excited|passionate|—" README.md; awk 'NR<=25' README.md | grep -c "plugin marketplace add"`
Fails when: the first grep prints any line, or the second count is 0

### Task 7: Clean-session install proof (local, then GitHub)
Owner: Claude (subagent)
Files: docs/verification/install-proof_2026-11-03.md
Steps:
1. In an empty dir with HOME set to a temp dir: `claude plugin marketplace add /Users/solomonsmith/Projects/solomon-loop` then `claude plugin install solomon-loop@solomon-loop`, then `claude plugin list`.
2. Run `claude -p "/solomon-loop:setup docs/plans/sample.md"` on a sample plan copied in; check the loop-lens file.
3. After the GitHub push (Task 9) repeat with `SolomonSmith-dev/solomon-loop` as the source. Paste outputs into the proof file.
Done check: `grep -c "solomon-loop" docs/verification/install-proof_2026-11-03.md && test -f <tmp>/.solomon-loop/sample/loop-lens.md`
Fails when: `claude plugin list` output in the proof lacks solomon-loop, or the test fails

### Task 8: skill-check on the plugin skill
Owner: Claude (subagent, runs /skill-check per ~/.claude/skills/skill-check/SKILL.md)
Files: docs/verification/skill-check_2026-11-03.md, ~/dotfiles/skills/skills-ledger.md (row only)
Steps:
1. Safety read, static, load, trigger (3 hits, 3 near-misses), behavior, verdict. Write the report.
Done check: `grep -E "^\| solomon-loop .*(pass|pass with notes)" ~/dotfiles/skills/skills-ledger.md`
Fails when: no row, or verdict is fail

### Task 9: Create the public repo and push
Owner: Solomon (decision) then Claude
Where: Claude Code prompt. Solomon says yes to: `gh repo create SolomonSmith-dev/solomon-loop --public --source . --push`, then tag v1.0.0.
Done check: `gh repo view SolomonSmith-dev/solomon-loop --json visibility,defaultBranchRef`
Fails when: 404, or visibility is not PUBLIC. Blocks Task 7 step 3 only.

### Task 10: Launch post drafts
Owner: Claude (subagent with my-voice)
Files: docs/launch/blog-post.md, show-hn.md, linkedin.md, x-thread.md, reddit.md, awesome-claude-code-pr.md, sequence.md (4 weeks, dates, who clicks)
Done check: `/bin/ls docs/launch | wc -l` and the banned-pattern grep from Task 6 across docs/launch
Fails when: fewer than 7 files, or any banned line

### Task 11: Site section draft for solomonsmith.dev
Owner: Claude
Files: shared notes folder of this session: `solomon-loop_site-section_2026-11-03.md` (project page section plus the blog post, for the site session)
Done check: `test -s "<shared notes>/solomon-loop_site-section_2026-11-03.md"`
Fails when: file missing or empty

### Task 12: Dogfood locally
Owner: Claude
Files: ~/dotfiles/skills/solomon-loop (becomes symlink), dotfiles commit
Steps: install the plugin from GitHub in Solomon's real HOME; replace the dotfiles folder with a symlink into the installed plugin's skills/solomon-loop.
Done check: `readlink ~/dotfiles/skills/solomon-loop`
Fails when: readlink prints nothing. Runs last; coordinated with the dotfiles session if it is active.

### Task 13: Record draft and HQ report
Owner: Claude
Files: HQ shared notes folder `solomon-loop_tasks_2026-11-03.md`
Done check: `test -s` on the file, and the report message under 150 words sent to local_2bb3c352-0784-426e-82e7-f73980eca8b5
Fails when: file empty or message not sent
