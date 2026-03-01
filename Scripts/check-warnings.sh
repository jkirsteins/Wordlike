#!/usr/bin/env bash
#
# Build and fail if any compiler warnings are produced.
# Called by pre-commit as an always_run hook.
#
set -euo pipefail

echo "Building (checking for warnings)..."

BUILD_OUTPUT=$(xcodebuild \
    -project SimpleWordGame.xcodeproj \
    -scheme "SimpleWordGame (iOS)" \
    -destination 'generic/platform=iOS Simulator' \
    build 2>&1)

# Filter real compiler warnings (ignore third-party metadata processor noise)
WARNINGS=$(echo "$BUILD_OUTPUT" | grep " warning:" | grep -v "appintentsmetadataprocessor" || true)

if [ -n "$WARNINGS" ]; then
    echo "Build produced warnings:"
    echo "$WARNINGS"
    exit 1
fi

echo "No warnings found."
