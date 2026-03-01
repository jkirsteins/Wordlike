#!/usr/bin/env bash
#
# Run WordlikeTests and fail if any test fails.
# Called by pre-commit as an always_run hook.
#
set -euo pipefail

echo "Running WordlikeTests..."
if xcodebuild test \
    -scheme "SimpleWordGame (iOS)" \
    -destination 'platform=macOS,variant=Mac Catalyst' \
    -configuration Debug \
    -only-testing:WordlikeTests \
    -quiet 2>&1; then
    echo "Tests passed."
else
    echo "Tests FAILED."
    exit 1
fi
