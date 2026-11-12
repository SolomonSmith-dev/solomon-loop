#!/usr/bin/env bash
# Tests scripts/lessons-root.sh against normal, linked, separate-git-dir and bare repos.
set -u

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
helper="$here/lessons-root.sh"
tmp="$(mktemp -d)" || exit 1
trap '/bin/rm -rf "$tmp"' EXIT
base="$(cd "$tmp" && pwd -P)/with space"
mkdir -p "$base"

fails=0
g() { git -c user.name=t -c user.email=t@example.invalid -c init.defaultBranch=main -c commit.gpgsign=false "$@"; }
canon() { (cd "$1" && pwd -P); }

check() { # name expected_dir run_dir
  local name="$1" want got
  want="$(canon "$2")"
  got="$(cd "$3" && bash "$helper" 2>/dev/null)"
  if [ "$got" = "$want" ]; then echo "PASS: $name"; else echo "FAIL: $name (want '$want', got '$got')"; fails=$((fails+1)); fi
}

# normal repo
g init -q "$base/normal" && g -C "$base/normal" commit -q --allow-empty -m init
check "normal repo" "$base/normal" "$base/normal"

# linked worktree, run from inside it
g -C "$base/normal" worktree add -q "$base/linked" -b linked
check "linked worktree resolves to main checkout" "$base/normal" "$base/linked"

# separate git dir
mkdir -p "$base/sep/work"
g init -q --separate-git-dir "$base/sep/meta" "$base/sep/work"
g -C "$base/sep/work" commit -q --allow-empty -m init
check "separate-git-dir resolves to work tree, not its parent" "$base/sep/work" "$base/sep/work"

# linked worktree of a separate-git-dir repo: main checkout is not recorded, must fail loudly
g -C "$base/sep/work" worktree add -q "$base/sep/linked" -b seplinked
err="$(cd "$base/sep/linked" && bash "$helper" 2>&1 >/dev/null)"; rc=$?
if [ "$rc" -ne 0 ] && [ -n "$err" ]; then echo "PASS: separate-git-dir linked worktree fails loudly"; else echo "FAIL: separate-git-dir linked (rc=$rc, stderr='$err')"; fails=$((fails+1)); fi

# bare repo: must fail with stderr
g init -q --bare "$base/bare.git"
err="$(cd "$base/bare.git" && bash "$helper" 2>&1 >/dev/null)"; rc=$?
if [ "$rc" -ne 0 ] && [ -n "$err" ]; then echo "PASS: bare repo exits non-zero with stderr"; else echo "FAIL: bare repo (rc=$rc, stderr='$err')"; fails=$((fails+1)); fi

# not a repo
mkdir -p "$base/plain"
err="$(cd "$base/plain" && GIT_CEILING_DIRECTORIES="$base" bash "$helper" 2>&1 >/dev/null)"; rc=$?
if [ "$rc" -ne 0 ] && [ -n "$err" ]; then echo "PASS: non-repo exits non-zero with stderr"; else echo "FAIL: non-repo (rc=$rc, stderr='$err')"; fails=$((fails+1)); fi

[ "$fails" -eq 0 ] || { echo "$fails failure(s)"; exit 1; }
echo "all passed"
