# Word Lists

## File format

Word list files are plain text (UTF-8), one word per line. Lines are
case-insensitive (uppercased at load time). Empty lines, whitespace-only
lines, and lines starting with `#` are ignored by `load()`.

**Important:** Gen 0 answer files (`*_A.txt`) must not have their
leading/trailing newlines removed. `loadRaw()` preserves the original
byte layout so the deterministic shuffle stays compatible with every
previously assigned daily word. See "Compatibility" below.

## Naming convention

```
{locale}_A.txt       — gen 0 answers  (daily puzzle words)
{locale}_A_1.txt     — gen 1 answers  (appended after gen 0 is exhausted)
{locale}_A_2.txt     — gen 2 answers  (appended after gen 1)
{locale}_G.txt       — valid guesses  (accepted but never chosen as answers)
```

Locale prefixes (`fileBaseName`):

| GameLocale | Prefix |
|------------|--------|
| `en_US`    | `en`   |
| `en_GB`    | `en-GB`|
| `fr_FR`    | `fr`   |
| `lv_LV`    | `lv`   |

## Gen 0 word counts

| File | Words | Notes |
|------|-------|-------|
| `en_A.txt` | 2315 | Clean (no empties) |
| `en-GB_A.txt` | 2287 | 1 trailing empty |
| `fr_A.txt` | 1695 | 1 leading + 1 trailing empty |
| `lv_A.txt` | 2399 | 1 trailing empty |

## Daily word selection algorithm

Implemented in `WordValidator.loadAnswers(seed:locale:)`.

1. **Load gen 0 raw** — `loadRaw("{locale}_A")` reads the file byte-for-byte
   and splits on `\n`, preserving empty entries. This keeps the array size
   identical to the original file so the shuffle stays compatible.

2. **Shuffle gen 0** — seeded with `ArbitraryRandomNumberGenerator(seed:)`
   using the app-wide seed (`14384982345`). The Mersenne Twister RNG is
   deterministic: same seed → same permutation, forever.

3. **Patch empties** — any empty strings in the shuffled array are replaced
   with `validWords[i % validWords.count]`. This fixes unwinnable days
   without shifting any other word's position.

4. **Append generations** — for gen `n` (1, 2, …), if
   `{locale}_A_{n}.txt` exists, load it with `load()` (filtered),
   shuffle with seed `seed &+ n`, and append.

5. **Daily lookup** — `turnIndex = calendarDaysSince(Mar 22, 2022)`.
   The word for a given day is `answers[turnIndex % answers.count]`.

## Compatibility

The shuffle order of gen 0 is **frozen**. Changing the gen 0 file content
or the `loadRaw()` function would reassign words for every past and future
day. The empty-string fix deliberately preserves the raw array layout and
only patches empty slots post-shuffle.

New words must go into a new generation file (e.g. `lv_A_1.txt`).
They are appended after all gen 0 entries and shuffled independently,
so they never affect gen 0 ordering.

## How to add new words

1. Create (or append to) `Resources/{locale}_A_{n}.txt` where `n` is the
   next generation number.
2. Add the file to **both** the iOS and macOS targets in Xcode
   (Copy Bundle Resources build phase).
3. Run `WordlikeTests` — the gen tests verify that gen 0 order is unchanged.

## How to add a new locale

1. Create `{prefix}_A.txt` (answers) and `{prefix}_G.txt` (guesses).
2. Add a case to `GameLocale` and `Locale.fileBaseName`.
3. Add both files to the Xcode targets.
4. Add snapshot and playable-day tests in `WordListTests.swift`.
