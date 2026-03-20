#!/usr/bin/env bash
# Checks that all Localizable.strings files have the same set of keys.
# Exits non-zero if any language is missing keys present in another.

set -euo pipefail

RESOURCES_DIR="Resources"
FAILED=0

# Extract sorted keys from a .strings file
extract_keys() {
    grep -E '^[[:space:]]*"[^"]*"[[:space:]]*=' "$1" \
        | sed -E 's/^[[:space:]]*"([^"]*)".*/\1/' \
        | sort
}

# Collect all .lproj directories
LPROJ_DIRS=()
for dir in "$RESOURCES_DIR"/*.lproj; do
    if [ -f "$dir/Localizable.strings" ]; then
        LPROJ_DIRS+=("$dir")
    fi
done

if [ ${#LPROJ_DIRS[@]} -lt 2 ]; then
    echo "Found fewer than 2 Localizable.strings files — nothing to compare."
    exit 0
fi

# Build union of all keys
ALL_KEYS=$(mktemp)
for dir in "${LPROJ_DIRS[@]}"; do
    extract_keys "$dir/Localizable.strings"
done | sort -u > "$ALL_KEYS"

# Check each language against the union
for dir in "${LPROJ_DIRS[@]}"; do
    LANG_KEYS=$(mktemp)
    extract_keys "$dir/Localizable.strings" > "$LANG_KEYS"

    MISSING=$(comm -23 "$ALL_KEYS" "$LANG_KEYS")
    if [ -n "$MISSING" ]; then
        LANG_NAME=$(basename "$dir")
        echo "ERROR: $LANG_NAME/Localizable.strings is missing keys:"
        echo "$MISSING" | while read -r key; do
            echo "  - \"$key\""
        done
        echo ""
        FAILED=1
    fi

    rm -f "$LANG_KEYS"
done

rm -f "$ALL_KEYS"

if [ "$FAILED" -ne 0 ]; then
    echo "Localization key check FAILED. All languages must have the same keys."
    exit 1
fi

echo "Localization key check passed."
