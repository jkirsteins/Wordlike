#!/usr/bin/env bash
#
# Pre-push gate: refuse to push if the working tree is dirty.
# Catches unstaged changes (e.g. format drift) and untracked files.
#
set -euo pipefail

dirty=0

# Check for unstaged/staged-but-uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "ERROR: Uncommitted changes detected."
    git diff --stat
    git diff --cached --stat
    dirty=1
fi

# Check for untracked files
untracked=$(git ls-files --others --exclude-standard)
if [ -n "$untracked" ]; then
    echo "ERROR: Untracked files detected."
    echo "$untracked"
    dirty=1
fi

if [ "$dirty" -ne 0 ]; then
    echo ""
    echo "Commit or stash all changes before pushing."
    exit 1
fi
