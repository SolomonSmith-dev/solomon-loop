#!/usr/bin/env bash
# Print the main worktree path: the first `worktree <path>` entry of
# `git worktree list --porcelain`, run in the current directory.
# Exits non-zero with a message on stderr outside a git repo or in a bare repo.
set -u

if ! out="$(git worktree list --porcelain 2>/dev/null)"; then
  echo "lessons-root: not inside a git repository" >&2
  exit 1
fi

first=1
path=""
bare=0
while IFS= read -r line; do
  if [ -z "$line" ]; then break; fi
  case "$line" in
    "worktree "*) [ "$first" -eq 1 ] && path="${line#worktree }"; first=0 ;;
    bare) bare=1 ;;
  esac
done <<EOF
$out
EOF

if [ -z "$path" ]; then
  echo "lessons-root: could not read the main worktree from git worktree list" >&2
  exit 1
fi
if [ "$bare" -eq 1 ]; then
  echo "lessons-root: bare repository has no main checkout; run from a non-bare checkout" >&2
  exit 1
fi

# `git init --separate-git-dir` makes git report the git dir itself as the first
# entry (no `.git` inside it). Then the work tree is only knowable from the main
# work tree, via --show-toplevel; from a linked worktree it is not recorded anywhere.
if [ ! -e "$path/.git" ]; then
  gitdir="$(git rev-parse --absolute-git-dir 2>/dev/null)"
  if [ -n "$gitdir" ] && [ "$(cd "$gitdir" && pwd -P)" = "$(cd "$path" && pwd -P)" ]; then
    top="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [ -n "$top" ]; then printf '%s\n' "$top"; exit 0; fi
  fi
  echo "lessons-root: main checkout of a separate-git-dir repository cannot be found from here; run from its main work tree" >&2
  exit 1
fi
printf '%s\n' "$path"
