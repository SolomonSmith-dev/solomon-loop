#!/usr/bin/env bash
# Tests check-private-names.sh: normal run passes, a grep scan error fails.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap '/bin/rm -rf "$tmp"' EXIT
fail=0

out=$(bash "$here/check-private-names.sh" 2>&1); rc=$?
if [ "$rc" -ne 0 ] || [ "$out" != "check-private-names: ok" ]; then
  echo "FAIL normal run: rc=$rc out=$out" >&2; fail=1
else
  echo "PASS normal run exits 0 with ok"
fi

printf '#!/bin/sh\nexit 2\n' > "$tmp/grep"
chmod +x "$tmp/grep"
out=$(PATH="$tmp:$PATH" bash "$here/check-private-names.sh" 2>"$tmp/err"); rc=$?
err=$(cat "$tmp/err")
if [ "$rc" -eq 0 ]; then echo "FAIL fake grep exit 2: script exited 0" >&2; fail=1
elif printf '%s' "$out" | grep -q 'ok'; then echo "FAIL fake grep exit 2: printed ok on stdout" >&2; fail=1
elif [ -z "$err" ]; then echo "FAIL fake grep exit 2: no stderr message" >&2; fail=1
else echo "PASS grep exit 2 fails (rc=$rc), no ok, stderr: $err"; fi

exit "$fail"
