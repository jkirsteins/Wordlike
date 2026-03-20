#!/usr/bin/env bash
# Compares current git diff against a snapshot taken before hooks ran.
# Fails if any hook modified files in the working tree.

SNAPSHOT="/tmp/wordlike-pre-commit-snapshot.diff"
AFTER="/tmp/wordlike-pre-commit-after.diff"

git diff > "$AFTER"

if ! diff -q "$SNAPSHOT" "$AFTER" >/dev/null 2>&1; then
    echo "ERROR: Pre-commit hooks modified files in the working tree:"
    diff "$SNAPSHOT" "$AFTER" | grep "^[><]" | head -20
    echo ""
    echo "Fix or stage these changes before committing."
    rm -f "$SNAPSHOT" "$AFTER"
    exit 1
fi

rm -f "$SNAPSHOT" "$AFTER"
