#!/usr/bin/env bash
#
# Run snapshot tests and fail if any snapshots differ.
# Called by pre-commit as a pre-push hook.
#
set -euo pipefail

echo "Running snapshot tests..."
if xcodebuild test \
    -scheme "SimpleWordGame (iOS)" \
    -destination 'platform=iOS Simulator,name=iPhone 16e Test' \
    -configuration Debug \
    -only-testing:WordlikeTests/StatsViewSnapshotTests \
    -quiet 2>&1; then
    echo "Snapshot tests passed."
else
    echo "Snapshot tests FAILED."
    exit 1
fi
