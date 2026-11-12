#!/usr/bin/env bash
# Fails if private role or system names appear in the public plugin text.
# Generic terms to use instead: "independent reviewer", "escalate to the owner".
# grep exit 0 = hits (fail), 1 = no hits (ok), >=2 = scan error (fail).
set -u
cd "$(dirname "$0")/.." || exit 2
pattern='review[ _-]?office|il[uú]vatar|hermes'
hits=$(grep -rniE "$pattern" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=graphify-out --exclude=check-private-names.sh --exclude=test-check-private-names.sh)
status=$?
if [ "$status" -ge 2 ]; then
  echo "check-private-names: scan error (grep exit $status)" >&2
  exit 2
fi
if [ "$status" -eq 0 ] && [ -n "$hits" ]; then
  echo "check-private-names: private names found in public text:" >&2
  echo "$hits" >&2
  exit 1
fi
echo "check-private-names: ok"
