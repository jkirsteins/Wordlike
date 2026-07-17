# Latvian "18 vardi" Game Mode + Latvian-Only Main Menu

Date: 2026-07-17
Status: Approved (user pre-approved review gate)

## Summary

Two changes:

1. Hide the non-Latvian game modes (en_US, en_GB, fr_FR) from the main menu. All
   supporting code, resources, stats, and tests stay in the codebase; the modes are
   hidden, not removed.
2. Add a new self-contained Latvian game mode, "18 vardi", cloning the daily
   experience of 18words.com (studied by playing a full match on 2026-07-17,
   puzzle #33), restyled with Wordlike's existing visual language.

Scope is daily-only for v1: no archive, no practice/relax modes.

## Reference: observed 18words.com behavior

- Daily puzzle, numbered (#N) and dated. 18 anagram words per day in a fixed
  length structure and order: 2 four-letter, 5 five-letter, 6 six-letter,
  3 seven-letter, 2 eight-letter (verified in their source comment and gameplay).
- Per word: scrambled letter circles, empty slot row, 30 second countdown
  (TIME = 30 in their source). Tapping (or typing) a letter fills the next slot.
  When all slots are filled the guess auto-submits.
- Accepted iff the guess equals the target word OR is any valid dictionary word
  using all the letters (their check: word !== target && !VALID.has(word) ->
  reject). Rejection: shake animation, "incorrect" flash, slots clear, letters
  return, the timer keeps running (no extra penalty).
- Timeout: the word's tile in the 18-tile progress grid turns red and the game
  advances to the next word with a fresh 30 s. A miss never ends the run.
- Solve: tile turns green, next word, fresh 30 s.
- Duplicate letters appear as separate circles (e.g. GUESS shows two S circles).
- End screen: "You scored X of 18 words!", a percentile/trophy line from a
  hardcoded score lookup (no backend):
  18 -> Top 1% (crown emoji), 17 -> Top 2% (trophy), 16 -> Top 3% (trophy),
  15 -> Top 5% (trophy), 12-14 -> Top 10% (medal), 10-11 -> Top 20% (medal),
  8-9 -> Top 50% (medal), below 8 -> "No trophy earned today" (broken heart).
- Share text (captured from clipboard):
  line 1: hourglass emoji + "18 words challenge #33"; blank line;
  "flame emoji I scored 16/18 words"; blank line; three rows of six squares
  (green square emoji for solved, red square emoji for missed, reading order =
  word order); blank line; trophy line; blank line; site URL.
  "Challenge friend" variant replaces the trophy line with a
  "Can you beat my score?" line.
- Local persistence per day: {day, survived, marks[18], onTime, timestamp}.
- Post-game: countdown to next daily puzzle.

## Architecture decision

A self-contained Daily18 feature module. No new GameLocale case and no GameMode
refactor: the existing "mode == GameLocale" machinery (GameHost, DailyState,
WordValidator, keyboards) continues to serve the hidden Wordle modes untouched.
The new mode has its own views, state types, and storage keys, and reuses
Wordlike's primitives: palettes/TileBackground colors, TurnCounter daily
indexing, @AppStateStorage persistence wrapper, safeSharingSheet, haptics,
AnalyticsService.

New code lives under Shared/Daily18/ (game logic + views), resources under
Resources/, tests under WordlikeTests/.

## 1. Gameplay and daily content

### Rules (faithful clone)

- 18 words per day, fixed structure and order: lengths 4,4,5,5,5,5,5,6,6,6,6,6,6,7,7,7,8,8.
- 30 seconds per word, reset on each new word. Countdown is visible and turns
  urgent (red) at 5 seconds or less.
- Tap a letter circle to fill the next empty slot. The backspace control and
  tapping any filled slot both remove the most recently placed letter (v1 keeps
  removal last-in-first-out; no arbitrary-slot editing).
- Auto-submit when the last slot fills.
- Accept iff guess == target OR acceptance dictionary contains the guess.
- Reject: shake + clear slots + return letters; timer keeps running; no penalty.
- Timeout: mark word failed (red), advance. Solve: mark green, advance.
- After word 18, show results.
- One puzzle per day; finished puzzles cannot be replayed.
- Mid-run state persists continuously; app relaunch resumes the same word with
  the remaining time that was left (like the web game's 1 Hz save).

### Daily puzzle generation (offline, deterministic)

- Day index: CalendarDailyTurnCounter with a new epoch constant for this mode
  (set to the release date so day 0 is puzzle #1). Same rollover semantics as
  existing modes. Puzzle number shown to users is dayIndex + 1.
- Answer files, one per length: lv18_A4.txt ... lv18_A8.txt (one lowercase word
  per line, UTF-8, Latvian diacritics preserved).
- Selection mirrors WordValidator's pattern: each file's list is shuffled once
  with a fixed seed (deterministic PRNG already used for existing modes), then
  the day's words are taken by index arithmetic with wraparound:
  four-letter slots use indices 2*day and 2*day+1 mod count, five-letter slots
  5*day .. 5*day+4 mod count, six-letter 6*day .. 6*day+5, seven-letter
  3*day .. 3*day+2, eight-letter 2*day, 2*day+1, each mod that file's count.
- Scramble: per-word deterministic shuffle seeded by (day, wordIndex); if the
  shuffle yields the solution order, apply one more deterministic swap. Everyone
  sees the same scramble on the same day.

### Content pipeline (from user-provided hunspell dictionary)

Source: /Users/janis.kirsteins/Downloads/lv_LV-1/lv_LV.dic (+ lv_LV.aff),
67k lemma entries with POS tags. Committed outputs are plain text files; the
generation script is a one-time tool (commit it under tools/ for reproducibility).

- Answers (curated): candidate pool = lowercase entries (excludes proper nouns)
  of char length 4-8 counted in Unicode characters, base forms only (hunspell
  lemmas already are nominative singular / infinitive; this satisfies the
  requirement that answers are always base forms). From the pool, an AI-curated
  familiarity pass selects common, family-friendly words; the user spot-checks
  the committed lists. Minimum curated sizes: 300 / 500 / 600 / 400 / 300 words
  for lengths 4 / 5 / 6 / 7 / 8 (candidate pool is roughly 573 / 1560 / 2912 /
  4884 / 6689, so these minimums are attainable; wraparound indexing means any
  size still yields a puzzle every day).
- Acceptance dictionary: lv18_D4.txt ... lv18_D8.txt = all lowercase lemmas of
  the matching length, plus affix-expanded surface forms (hunspell unmunch with
  lv_LV.aff) if the tooling produces a manageable set; filtered to lengths 4-8,
  lowercased, deduplicated. Every answer word must also appear in its acceptance
  file. Inflected forms are acceptable as guesses (base-form rule applies to
  answers only).

## 2. UI and flow (Wordlike visual style)

### Main menu

- Locale.supportedLocales (Shared/Extensions/LocaleExtensions.swift) -> [.lv_LV].
- AppView.listedLocales -> [.lv_LV].
- NavigationList renders the Latvian Wordle row as today, then a dedicated
  "18 vardi" row beneath it: LV flag asset, title "18 vardi" (localized display
  name), today's status (not played / in progress / final score as "16/18"),
  and a compact trophy-streak widget, matching LanguageRow's anatomy so the menu
  stays uniform.
- EN/GB/FR rows disappear because supportedLocales drives the ForEach. Their
  debug reset rows in SettingsView may remain.

### Pre-game screen (destination of the menu row, before starting)

- 18-tile grid preview (neutral tiles), "#N | date" line, large Play button.
- If today's puzzle is already finished, this screen shows the results summary
  instead (see below); there is no way to replay.

### Game screen

- Top: 18-tile progress grid; tiles colored live (palette correct-color for
  solved, incorrect/red for missed, neutral for pending).
- "VARDS i/18" label (localized), large countdown seconds, red when <= 5 s.
- Slot row: outlined empty tiles sized to the word length (4-8), same corner
  radius and stroke language as the Wordle board tiles.
- Letter circles: two centered rows (as on the web), adapted Tile styling from
  the app palette; a used circle dims/highlights while placed.
- Backspace control below the circles.
- Feedback: reject = slot-row shake + clear; solve = brief green flash of the
  grid tile + advance; timeout = tile turns red, short pause, next word.
  Haptics via existing feedback helpers on solve/miss.
- High-contrast palette setting honored (palette system is global).
- Input is tap-only in v1; no hardware keyboard handling, no keyboard view.

### Results (shown after word 18 and on revisit for the day)

- Final 18-tile grid.
- Headline: localized "You found X of 18 words!".
- Trophy line (localized) from the hardcoded tier table.
- Share score + Challenge friend buttons.
- Countdown to the next puzzle (existing next-turn countdown logic pattern).

### Localization

All new UI strings localized in en, fr, lv (RULES.md). Game content (the words)
is Latvian regardless of UI language. Mode display name: "18 vardi" with proper
Latvian spelling (a-macron) in content/lv strings; en/fr strings may reuse the
same brand name.

## 3. Persistence, stats, sharing, integration

### Persistence (UserDefaults via @AppStateStorage; new keys, hidden modes untouched)

- Key "daily18.lv": Daily18State (Codable):
  day: Int, marks: [Mark] (18 entries: pending/solved/failed), currentIndex: Int,
  remainingSeconds: Int, phase (notStarted / inProgress / finished),
  firstPlayedAt / finishedAt: Date?.
- Key "stats18.lv": Daily18Stats (Codable):
  played: Int, scoreDistribution: [Int] (19 buckets, index = score 0-18),
  trophyStreak: Int, maxTrophyStreak: Int, perfectDays: Int,
  lastTrophyDay / lastPlayedDay tracking for streak math using the TurnCounter
  period logic (consecutive daily periods, same approach as Stats.update).
- Trophy day = score >= 8 (site's own trophy threshold). Perfect day = 18.
  Perfect days are a plain counter, no streak, per user decision.

### Stats sheet (adapted from existing stats view styling)

- Headline stat tiles: Played, Trophy streak, Max trophy streak, Perfect days.
- Horizontal-bar histogram (same bar styling as the Wordle guess distribution)
  with one bar per score 0-18; today's score bar highlighted.

### Trophy tier table (hardcoded, localized)

score 18: top 1%; 17: top 2%; 16: top 3%; 15: top 5%; 12-14: top 10%;
10-11: top 20%; 8-9: top 50%; 0-7: no trophy today.

### Sharing (existing safeSharingSheet plumbing)

Share score text (localized, Latvian shown as primary example):

    18 vardi #33

    16/18 vardi atrasti

    [row of 6 squares]
    [row of 6 squares]
    [row of 6 squares]

    [trophy line]

Squares: green square emoji for solved, red square emoji for missed, in word
order, 6 per row x 3 rows. Challenge variant: trophy line replaced with a
localized "Can you beat my score?" line. No URL line in v1 (no web presence for
this mode); may add an App Store link later.

The aggregate "share a summary" flow in AppView appends an 18 vardi line when
today's run is finished (score + squares), alongside the Latvian Wordle line.

### Integration

- Analytics: reuse existing event names with game_locale attribute "lv18"
  (game.started, game.won/game.lost semantics: won = trophy day; also send the
  score as an attribute). RUM view name for the game screen (e.g. "Game18").
- StatsTransfer: export/import extended with the two new keys so device
  migration carries the mode's data.
- Versioning: bump via make bump-minor when shipping (not by hand).

## Testing (XCTest, run with make test)

- Puzzle determinism: same day -> same 18 words and same scrambles; different
  days differ.
- Structure invariant: generated puzzle always has lengths
  4,4,5,5,5,5,5,6,6,6,6,6,6,7,7,7,8,8 in order.
- Acceptance: target accepted; a known valid anagram from the acceptance file
  accepted; a non-word rejected; guesses must use exactly the given letters.
- Flow: timeout marks failed and advances; solve marks solved and advances;
  finishing word 18 transitions to finished.
- Stats: trophy streak increments on consecutive trophy days and resets after a
  gap or sub-8 score; perfectDays increments only on 18; distribution buckets.
- Share text: exact format snapshot for a known state (both variants).
- Resources: lv18_A*/lv18_D* files exist, non-empty, lowercase, valid Latvian
  characters, correct lengths, answers subset of acceptance lists.
- Existing tests (including cross-platform parity tests) must keep passing;
  no changes to DailyState/WordModel Codable shapes.

## Out of scope (v1)

- Archive / replay of past days, practice and relax modes.
- Hardware keyboard input for this mode.
- Server-backed percentiles or any networking.
- Removing (rather than hiding) EN/GB/FR code or resources.
