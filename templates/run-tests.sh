#!/usr/bin/env bash
# Stop hook: blocks task completion while the test suite fails.
# Handles re-entrancy (stop_hook_active) to avoid an infinite loop.
#
# TEMPLATE — copy into <target repo>/scripts/run-tests.sh, replace the test
# command below with the one detected in the project, and chmod +x it.
input=$(cat)
if printf '%s' "$input" | grep -Eq '"stop_hook_active" *: *true'; then
  exit 0
fi
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
log=$(mktemp)
if ! npm test >"$log" 2>&1; then
  echo "npm test is failing — fix the tests before finishing the task:" >&2
  tail -20 "$log" >&2
  rm -f "$log"
  exit 2   # exit code 2: blocks the Stop and sends stderr back to the model
fi
rm -f "$log"
exit 0
