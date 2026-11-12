#!/usr/bin/env bash
# Regression check for the instruction text, not a security control.
# Fails if the base-pin rules (issue #2) are missing from the prompt files.
# HTML comments and fenced code blocks are stripped before matching, so a rule
# that only sits inside one of them does not count.
# Usage: bash scripts/check-base-pin.sh [root]   (root defaults to the repo root)
set -euo pipefail
root="${1:-$(dirname "$0")/..}"
cd "$root"

fail=0

# strip <file>: drop HTML comments (multiline; an unclosed one runs to EOF), then ``` fences.
strip() {
  perl -0777 -pe 's/<!--.*?(?:-->|\z)//gs' "$1" |
    awk '/^[[:space:]]*(```|~~~)/ { infence = !infence; next } !infence'
}

need() { # file, fixed-string pattern, label  (matches stripped text)
  if ! strip "$1" | grep -qF -- "$2"; then
    echo "FAIL: $1 missing: $3" >&2
    fail=1
  fi
}
need_raw() { # file, fixed-string pattern, label  (matches the raw file; for text that lives in a template fence)
  if ! grep -qF -- "$2" "$1"; then
    echo "FAIL: $1 missing (template): $3" >&2
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
  need "$f" 'git update-ref refs/solomon-loop/<slug>/start' 'run-start ref written by the controller'
  need "$f" 'refs/solomon-loop' 'ref namespace'
  need "$f" 'chain' 'base chain'
  need "$f" 'accepted <sha>' 'accepted head ledgered at check-off'
  need "$f" 'shasum -a 256' 'workspace file hashes'
done
need commands/run.md '[WORKSPACE_HASHES]' 'run.md fills the hash placeholder'
need skills/solomon-loop/reviewer-challenge.md 'worker-report-task-<N>.md' 'reviewer write-rule check'
need skills/solomon-loop/reviewer-challenge.md 'git merge-base --is-ancestor' 'reviewer range check'
need skills/solomon-loop/reviewer-challenge.md 'shasum -a 256' 'reviewer hash re-check'
need skills/solomon-loop/reviewer-challenge.md '[WORKSPACE_HASHES]' 'hash placeholder'
need_raw skills/solomon-loop/reviewer-challenge.md 'shasum -a 256 ledger.md lessons.md loop-lens.md' 'reviewer hash command in the block'
need_raw skills/solomon-loop/reviewer-challenge.md 'Any mismatch is **Critical**' 'hash mismatch is Critical'

if [ "$fail" -eq 0 ]; then echo "base-pin: ok"; fi
exit "$fail"
