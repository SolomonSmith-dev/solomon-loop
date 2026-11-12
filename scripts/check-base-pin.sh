#!/usr/bin/env bash
# Fails if the base-pin rules (issue #2) are missing from the prompt files.
# Usage: bash scripts/check-base-pin.sh [root]   (root defaults to the repo root)
set -euo pipefail
root="${1:-$(dirname "$0")/..}"
cd "$root"

fail=0
need() { # file, fixed-string pattern, label
  if ! grep -qF -- "$2" "$1"; then
    echo "FAIL: $1 missing: $3" >&2
    fail=1
  fi
}

for f in commands/run.md skills/solomon-loop/SKILL.md; do
  need "$f" 'git merge-base --is-ancestor <base> <candidate>' 'merge-base --is-ancestor check'
  need "$f" 'git diff --name-only <base>..<candidate>' 'git diff --name-only range'
  need "$f" 'non-empty' 'non-empty range requirement'
  need "$f" 'Critical' 'Critical on bad range'
  need "$f" 'may write only its own `worker-report-task-<N>.md`, never `ledger.md`' 'implementer write rule'
  need "$f" 'sandboxing' 'residual note'
  need "$f" "base stays in the controller's context" 'base stays in controller context'
  need "$f" 'read only on resume' 'ledger read only on resume'
done
need skills/solomon-loop/reviewer-challenge.md 'worker-report-task-<N>.md' 'reviewer write-rule check'
need skills/solomon-loop/reviewer-challenge.md 'git merge-base --is-ancestor' 'reviewer range check'

if [ "$fail" -eq 0 ]; then echo "base-pin: ok"; fi
exit "$fail"
