#!/usr/bin/env python3
"""One-time generator for the 18 vardi word lists.

Reads the hunspell Latvian dictionary (base-form lemmas) and emits:
  Resources/lv18_A{4..8}.txt  answer candidates (lowercase lemmas)
  Resources/lv18_D{4..8}.txt  acceptance dictionaries (superset of answers)

Answers must be base forms: hunspell .dic entries are lemmas already
(nominative singular / infinitive), so filtering the entry list satisfies
the base-form requirement. Proper nouns are excluded by requiring a
lowercase first letter.
"""
import re
import subprocess
import shutil
import sys
from pathlib import Path

DIC = Path("/Users/janis.kirsteins/Downloads/lv_LV-1/lv_LV.dic")
AFF = Path("/Users/janis.kirsteins/Downloads/lv_LV-1/lv_LV.aff")
OUT = Path(__file__).resolve().parent.parent / "Resources"

ALPHABET = re.compile(r"^[abcdefghijklmnopqrstuvzāčēģīķļņšūž]+$")


def lemmas():
    result = []
    with DIC.open(encoding="utf-8") as f:
        next(f)  # first line is the entry count
        for line in f:
            word = line.split("/")[0].split()[0].strip() if line.strip() else ""
            if word and ALPHABET.match(word):
                result.append(word)
    return sorted(set(result))


def unmunched():
    """All surface forms via hunspell's unmunch, if available."""
    if not shutil.which("unmunch"):
        return []
    try:
        out = subprocess.run(
            ["unmunch", str(DIC), str(AFF)],
            capture_output=True, timeout=300,
        ).stdout.decode("utf-8", errors="ignore")
    except Exception:
        return []
    return [w.strip().lower() for w in out.splitlines() if ALPHABET.match(w.strip().lower())]


def main():
    base = lemmas()
    accept = sorted(set(base) | set(unmunched()))

    for n in range(4, 9):
        answers = [w for w in base if len(w) == n]
        dictionary = [w for w in accept if len(w) == n]
        (OUT / f"lv18_A{n}.txt").write_text("\n".join(answers) + "\n", encoding="utf-8")
        (OUT / f"lv18_D{n}.txt").write_text("\n".join(dictionary) + "\n", encoding="utf-8")
        print(f"len {n}: {len(answers)} answers, {len(dictionary)} accepted")


if __name__ == "__main__":
    sys.exit(main())
