# Launch sequence, 2026-11-03 to 2026-11-30

Nothing in this table posts without Solomon's yes on the specific draft. "Agent" means an agent prepares and verifies; "Solomon" means his click or account.

| Date | Action | Who clicks | Done check |
|---|---|---|---|
| Mon 11-03 | Repo public at github.com/SolomonSmith-dev/solomon-loop | Solomon | `curl -s -o /dev/null -w '%{http_code}' https://github.com/SolomonSmith-dev/solomon-loop` prints 200. Fails: 404. |
| Mon 11-03 | CI green on main (`claude plugin validate . --strict`) | Agent | `gh run list -R SolomonSmith-dev/solomon-loop -L 1` shows `completed success`. Fails: `failure`. |
| Tue 11-04 | Install proof in a clean session: both install commands, then setup on the sample plan | Agent runs, Solomon watches | `claude plugin list` prints `solomon-loop` and `test -f .solomon-loop/sample/loop-lens.md` exits 0. Fails: plugin absent or file missing. |
| Wed 11-05 | Tag and release v1.0.0 with CHANGELOG section | Solomon (release button) | `gh release view v1.0.0 -R SolomonSmith-dev/solomon-loop` prints the tag. Fails: `release not found`. |
| Thu 11-06 | README read-through against banned patterns | Agent | The my-voice banned-pattern grep (same command used on `docs/launch/`) run on `README.md` prints nothing and exits 1. Fails: any line printed. |
| Mon 11-10 | Blog post live on solomonsmith.dev; fill the date placeholder | Solomon (publish) | `curl -s https://solomonsmith.dev/<slug> \| grep -c "SolomonLoop"` prints 1 or more. Fails: 0. |
| Tue 11-11 | Replace `[blog post URL]` in show-hn.md, linkedin link stays repo | Agent | `grep -c "\[blog post URL\]" docs/launch/show-hn.md` prints 0. Fails: 1. |
| Wed 11-12 | Submit to the claude.ai plugin directory | Solomon (form) | Confirmation email or submission id saved in `docs/launch/directory-submission.md`. Fails: file absent. |
| Thu 11-13 | LinkedIn post | Solomon | Post URL pasted into `docs/launch/posted.md`. Fails: no URL. |
| Mon 11-17 | Repo passes the 14-day age rule; submit awesome-claude-code issue form (human only, web UI) | Solomon | Issue URL in `posted.md`; bot comment does not say "closed". Fails: auto-closed. |
| Tue 11-18, 7 to 9am Pacific | Show HN (Tue to Thu morning Pacific window; slip to Wed or Thu if Tuesday is missed) | Solomon | HN item URL in `posted.md`. Fails: no URL by Thu 11-20 noon. |
| Tue 11-18, within 1 hour of HN | X thread | Solomon | First tweet URL in `posted.md`. Fails: no URL. |
| Wed 11-19 | r/ClaudeAI post | Solomon | Post URL in `posted.md`, post not removed by mods after 24h. Fails: removed. |
| Thu 11-20 | Reply to every HN, Reddit and X comment with a real question | Agent drafts, Solomon sends | Zero unanswered top-level questions older than 12h, checked by reading the threads. Fails: any. |
| Mon 11-24 | Triage issues: label, reproduce from pasted report sections, answer | Agent drafts, Solomon approves | `gh issue list -R SolomonSmith-dev/solomon-loop --state open` shows no issue without a label. Fails: any unlabeled. |
| Tue 11-25 to Thu 11-27 | v1.1 from lessons: only finding classes that recurred in two or more issues or task groups | Agent builds, Solomon approves each promote | CHANGELOG has a `[1.1.0]` section citing the recurrence for each change. Fails: a change with no cited recurrence. |
| Fri 11-28 | Tag v1.1.0 | Solomon | `gh release view v1.1.0` prints the tag. Fails: `release not found`. |
| Sun 11-30 | Metric snapshot | Agent | `gh api repos/SolomonSmith-dev/solomon-loop --jq .stargazers_count` and count of issues or PRs by accounts other than SolomonSmith-dev, written to `docs/launch/metrics-2026-11-30.md`. Target: 50 stars, 3 stranger issues or PRs. Fails: either number under target, recorded as a miss, not hidden. |

*Register: business. Anchored on: MOTM Percy Meeting Prep preamble.*
