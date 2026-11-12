#!/usr/bin/env bash
# Behavior test for the resume rules in commands/run.md (issue #2): ancestor,
# non-empty range and base chain. Also proves check-base-pin.sh ignores rules
# hidden in HTML comments or code fences.
# Usage: bash scripts/test-base-chain.sh
#        OLD_RULES=1 bash scripts/test-base-chain.sh   # rules as in 57b2cee (ancestor + non-empty only)
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap '/bin/rm -rf "$tmp"' EXIT

pass=0
failn=0
report() { # name, ok|bad
  if [ "$2" = ok ]; then echo "PASS: $1"; pass=$((pass + 1)); else echo "FAIL: $1"; failn=$((failn + 1)); fi
}

# ---- throwaway repo: start, A (malicious), B (benign), U (unrelated history) ----
r="$tmp/repo"
git init -q "$r"
cd "$r"
git config user.name test
git config user.email test@example.invalid
git config commit.gpgsign false
git commit -q --allow-empty -m start
S="$(git rev-parse HEAD)"
echo bad > malicious.txt && git add malicious.txt && git commit -q -m A
A="$(git rev-parse HEAD)"
echo ok > benign.txt && git add benign.txt && git commit -q -m B
B="$(git rev-parse HEAD)"
git checkout -q --orphan other
git rm -rfq . >/dev/null 2>&1 || true
echo u > unrelated.txt && git add unrelated.txt && git commit -q -m U
U="$(git rev-parse HEAD)"
git checkout -q -f --detach "$B"
# The controller writes this at run start (run.md step: git update-ref refs/solomon-loop/<slug>/start).
git update-ref refs/solomon-loop/t/start "$S"

# resume_check <base> <candidate> <prev_accepted|"">   (empty prev = task 1)
# Commands are the ones written in commands/run.md; the sync check below keeps them identical.
resume_check() {
  local base="$1" candidate="$2" prev="$3"
  git merge-base --is-ancestor "$base" "$candidate" || return 1
  [ -n "$(git diff --name-only "$base..$candidate")" ] || return 1
  [ "${OLD_RULES:-0}" = 1 ] && return 0
  if [ -z "$prev" ]; then
    test "$base" = "$(git rev-parse refs/solomon-loop/t/start)" || return 1
  else
    test "$base" = "$prev" || return 1
  fi
  return 0
}

expect() { # name, ACCEPT|REJECT, base, candidate, prev
  local got=REJECT
  if resume_check "$3" "$4" "$5" 2>/dev/null; then got=ACCEPT; fi
  if [ "$got" = "$2" ]; then report "$1 => $got" ok; else report "$1 => got $got, want $2" bad; fi
}

expect "task1 forged base=A (intermediate ancestor), ref start=S" REJECT "$A" "$B" ""
expect "task1 true base=S" ACCEPT "$S" "$B" ""
expect "task2 empty range base=candidate, prev=B" REJECT "$B" "$B" "$B"
expect "task2 unrelated-history base=U, prev=U" REJECT "$U" "$B" "$U"
expect "task2 true base=A, prev accepted head=A" ACCEPT "$A" "$B" "$A"
expect "task2 stale base=S, prev accepted head=A" REJECT "$S" "$B" "$A"

if [ "${OLD_RULES:-0}" != 1 ]; then
  # ---- run.md must carry the same commands the function above runs ----
  for s in 'git merge-base --is-ancestor <base> <candidate>' \
           'git diff --name-only <base>..<candidate>' \
           'git update-ref refs/solomon-loop/<slug>/start' \
           'git rev-parse refs/solomon-loop/<slug>/start'; do
    if grep -qF -- "$s" "$repo/commands/run.md"; then report "run.md carries: $s" ok; else report "run.md missing: $s" bad; fi
  done

  # ---- check-base-pin.sh must not credit rules hidden in comments or fences ----
  mk() { # dir, wrap-mode
    mkdir -p "$1/commands" "$1/skills/solomon-loop" "$1/scripts"
    cp "$repo/scripts/check-base-pin.sh" "$1/scripts/"
    local f
    for f in commands/run.md skills/solomon-loop/SKILL.md skills/solomon-loop/reviewer-challenge.md; do
      case "$2" in
        plain) cp "$repo/$f" "$1/$f" ;;
        comment) { printf '<!--\n'; cat "$repo/$f"; printf '\n-->\n'; } > "$1/$f" ;;
        unclosed) { printf '<!--\n'; cat "$repo/$f"; } > "$1/$f" ;;
        fence) { printf '```\n'; cat "$repo/$f"; printf '\n```\n'; } > "$1/$f" ;;
      esac
    done
  }
  mk "$tmp/plain" plain
  if bash "$tmp/plain/scripts/check-base-pin.sh" "$tmp/plain" >/dev/null 2>&1; then report "check-base-pin passes on real text" ok; else report "check-base-pin passes on real text" bad; fi
  for m in comment unclosed fence; do
    mk "$tmp/$m" "$m"
    if bash "$tmp/$m/scripts/check-base-pin.sh" "$tmp/$m" >/dev/null 2>&1; then report "check-base-pin FAILS when rules sit in a $m" bad; else report "check-base-pin FAILS when rules sit in a $m" ok; fi
  done
fi

echo "---- $pass passed, $failn failed"
[ "$failn" -eq 0 ]
