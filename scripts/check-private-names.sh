#!/usr/bin/env bash
# Fails if private role or system names appear in the public plugin text.
# Generic terms to use instead: "independent reviewer", "escalate to the owner".
set -u
cd "$(dirname "$0")/.." || exit 2
pattern='review[ _-]?office|il[uú]vatar|hermes'
hits=$(grep -rniE "$pattern" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=graphify-out --exclude=check-private-names.sh)
if [ -n "$hits" ]; then
  echo "check-private-names: private names found in public text:" >&2
  echo "$hits" >&2
  exit 1
fi
echo "check-private-names: ok"
