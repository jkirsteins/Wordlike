#!/usr/bin/env bash
#
# Check word list files for leading or trailing blank lines.
# Called by pre-commit with filenames as arguments.
# Fails if any file has blank lines — they must be removed manually.
#
set -euo pipefail

bad=()

for f in "$@"; do
    if [ ! -s "$f" ]; then
        continue
    fi

    head_byte=$(head -c1 "$f" | xxd -p)
    tail_two=$(tail -c2 "$f" | xxd -p)

    if [ "$head_byte" = "0a" ] || [ "$tail_two" = "0a0a" ]; then
        bad+=("$f")
    fi
done

if [ ${#bad[@]} -gt 0 ]; then
    echo "ERROR: The following word list files have leading or trailing blank lines:"
    for f in "${bad[@]}"; do
        echo "  $f"
    done
    echo "Remove the blank lines before committing."
    exit 1
fi
