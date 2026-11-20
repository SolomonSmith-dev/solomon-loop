#!/usr/bin/env bash
# Fail if validate.yml still has floating action tags or an unpinned claude-code install.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
wf="$root/.github/workflows/validate.yml"

if [[ ! -f "$wf" ]]; then
  echo "missing $wf"
  exit 1
fi

unpinned="$(grep -E 'uses:' "$wf" | grep -vE 'uses: [-A-Za-z0-9_./]+@[0-9a-f]{40}' || true)"
if [[ -n "$unpinned" ]]; then
  echo "unpinned actions:"
  printf '%s\n' "$unpinned"
  exit 1
fi

# Every claude-code npm install must be semver-pinned. One good pin must not
# hide a second @latest / untagged install.
bad_cc="$(grep -E 'npm install -g @anthropic-ai/claude-code' "$wf" | grep -vE '@anthropic-ai/claude-code@[0-9]+\.[0-9]+\.[0-9]+([[:space:]]|$)' || true)"
if [[ -n "$bad_cc" ]]; then
  echo "unpinned claude-code install:"
  printf '%s\n' "$bad_cc"
  exit 1
fi

if ! grep -Eq 'npm install -g @anthropic-ai/claude-code@[0-9]+\.[0-9]+\.[0-9]+' "$wf"; then
  echo "claude-code install is missing a semver pin"
  exit 1
fi

if ! grep -Eq 'scripts/test-workflow-pins\.sh' "$wf"; then
  echo "validate.yml does not invoke test-workflow-pins.sh"
  exit 1
fi

echo "workflow pins ok"
