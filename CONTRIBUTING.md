# Contributing

## Issues

Issues are welcome. Paste the relevant report sections (worker report, reviewer challenge, ledger rulings) so the finding can be reproduced from what the loop actually produced.

## Pull requests

A PR that changes the loop's rules or templates follows the loop's own rule: cite the finding class and at least two runs where it recurred (rows in `.solomon-loop/lessons.md`). A lesson that appeared in one run does not change the rules.

Documentation, typo and packaging PRs need no recurrence evidence.

## Style

- No em dashes in prose. Use a comma, a colon or a new sentence.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`).
- Run `claude plugin validate . --strict` before opening a PR.
