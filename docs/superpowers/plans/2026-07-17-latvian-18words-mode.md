# Latvian "18 vardi" Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a self-contained Latvian anagram-sprint game mode ("18 vardi", clone of 18words.com daily experience) and hide the non-Latvian Wordle modes from the main menu.

**Architecture:** New Daily18 module under `Shared/Daily18/` with its own state, engine, stats, share text, and SwiftUI views; it reuses existing primitives (ArbitraryRandomNumberGenerator, WordValidator.load, CalendarDailyTurnCounter, AppStateStorage, palettes, safeSharingSheet, Analytics). Existing GameLocale/GameHost machinery is untouched; non-Latvian modes are hidden by trimming two locale arrays.

**Tech Stack:** SwiftUI, XCTest, raw .pbxproj project, python3 for one-time word list generation.

**Spec:** `docs/superpowers/specs/2026-07-17-latvian-18words-mode-design.md` (approved).

## Global Constraints

- Work on branch `janis.kirsteins/latvian-18words-mode` (already created; spec commit is on it). Never commit to master.
- RULES.md applies: zero compiler warnings; never relax or disable SwiftLint/SwiftFormat rules; no inline suppressions; no `--no-verify`; no TODO/FIXME comments; follow existing conventions.
- Every user-facing string must be added to ALL THREE localization files in the SAME commit (a pre-commit hook checks key consistency): `Resources/en.lproj/Localizable.strings`, `Resources/fr.lproj/Localizable.strings`, `Resources/lv.lproj/Localizable.strings`. Convention: the key is the English text.
- The pre-commit hook rejects untracked files: `git add` every new file (including plan/doc edits) before committing.
- `make test` runs the full unit test suite; `make lint` runs SwiftLint strict; `make format` runs SwiftFormat. Run `make format` then `make lint` before every commit. All existing tests must keep passing. Never edit `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` by hand.
- Do NOT modify: `Shared/GameLogic/DailyState.swift`, `Shared/GameLogic/Word Comparison/*` Codable shapes (cross-platform parity tests depend on them), or anything under the root-level legacy dirs (`./GameLogic`, `./Misc`, `./Environment`, `./Palettes`, `./Extensions`).
- Word/text content rule: answer files contain lowercase Latvian base forms (lemmas); code compares words in UPPERCASE (the existing loader `WordValidator.load` uppercases).

### pbxproj registration recipe (raw Xcode project - required for every new file)

The project is `SimpleWordGame.xcodeproj/project.pbxproj` (NOT generated - edit it directly). For each new file, make 4 edits, mimicking the existing entries for `Stats.swift` (Swift in app target), `lv_A.txt` (resource), and `WordListTests.swift` (test target):

1. **PBXBuildFile section** (top of file, alphabetical-ish; anywhere in the section works):
   `<BUID> /* <name> in Sources */ = {isa = PBXBuildFile; fileRef = <FUID> /* <name> */; };`
   For .txt resources use `in Resources` instead of `in Sources`.
2. **PBXFileReference section:**
   Swift: `<FUID> /* <name> */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = <name>; sourceTree = "<group>"; };`
   Txt: same but `lastKnownFileType = text`.
   Test files mimic WordListTests.swift: `{isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = <name>; sourceTree = "<group>"; };`
3. **PBXGroup children:** add `<FUID> /* <name> */,` to the right group:
   - New Swift app files: the `Daily18` group (create it once inside the `Shared` group `E7F299592837DABA005792DA`, see Task 2; it has `path = Daily18;`).
   - .txt resources: the group that contains `lv_A.txt` (around line 471).
   - Test files: the group that contains `WordListTests.swift` (around line 353).
4. **Build phase:** add `<BUID> /* <name> in Sources */,` to:
   - App Swift files: the PBXSourcesBuildPhase list containing `Stats.swift in Sources` (around line 948).
   - Resources: the PBXResourcesBuildPhase list containing `lv_A.txt in Resources` (around line 806).
   - Test files: the test PBXSourcesBuildPhase list containing `WordListTests.swift in Sources` (around line 854).

UUIDs are 24 hex chars. Use the scheme `D18<seq>` padded to 24 chars, e.g. `D180000000000000000000A1`, incrementing the tail per entry. Before using one, `grep` the pbxproj to confirm it is unused. After editing, `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` must print "OK", and the build must succeed.

### Shared interface reference (defined by these tasks, used across tasks)

- `Daily18State` (Task 2): `init(day: Int)`, `var day: Int`, `var marks: [Daily18Mark]` (18), `var currentIndex: Int`, `var remainingSeconds: Int`, `var phase: Daily18Phase`, `var isTallied: Bool`, `var firstPlayedAt: Date?`, `var finishedAt: Date?`, `var score: Int`; `Daily18Mark` = `.pending | .solved | .failed`; `Daily18Phase` = `.notStarted | .inProgress | .finished`; `Daily18State.wordCount == 18`, `Daily18State.timePerWord == 30`.
- `Daily18Puzzle` (Task 3): `static let structure: [Int]`, `let words: [String]`, `let scrambles: [[String]]`.
- `Daily18PuzzleProvider` (Task 3): `loadAnswerLists() -> [Int: [String]]`, `puzzle(forDay: Int, lists: [Int: [String]]) -> Daily18Puzzle`, `scramble(_ word: String, day: Int, index: Int) -> [String]`.
- `Daily18Dictionary` (Task 3): `static func load() -> Daily18Dictionary`, `func contains(_ word: String) -> Bool` (uppercase input).
- `Daily18Engine` (Task 4): `init(puzzle:state:isAccepted:)`, `@Published private(set) var state`, `@Published private(set) var placed: [Int]`, `@Published private(set) var rejectionCount: Int`, `var currentScramble: [String]`, `var currentTarget: String`, `var currentGuess: String`, `func start(now: Date = Date())`, `func placeLetter(circleIndex: Int)`, `func removeLast()`, `func tick(now: Date = Date())`, `func markTallied()`.
- `Daily18Stats` (Task 5): `init()`, memberwise init, `let played/trophyStreak/maxTrophyStreak/perfectDays: Int`, `let scoreDistribution: [Int]` (19), `let lastTrophyAt: Date?`, `static let trophyThreshold = 8`, `func update(score: Int, finishedAt: Date, with: TurnCounter) -> Daily18Stats`, `func widthRatio(score: Int) -> CGFloat`.
- `Daily18TrophyTier` (Task 5): `percent(forScore: Int) -> Int?`, `emoji(forScore: Int) -> String`, `line(forScore: Int) -> String`.
- `Daily18Share` (Task 6): `squares(for: [Daily18Mark]) -> String`, `scoreText(day: Int, marks: [Daily18Mark]) -> String`, `challengeText(day: Int, marks: [Daily18Mark]) -> String`.
- `Daily18Storage` (Task 7): `stateKey == "daily18.lv"`, `statsKey == "stats18.lv"`, `epoch` (2026-07-17T00:00:00Z), `makeTurnCounter() -> TurnCounter`, `storedState() -> Daily18State?`, `isFinishedToday(at: Date = Date()) -> Bool`.
- `Daily18Host` (Task 7): SwiftUI entry view; `static let gameLocaleAttribute = "lv18"`.

---

### Task 1: Word list resources (generation tool + files + validation tests)

**Files:**
- Create: `tools/generate_lv18_wordlists.py`
- Create: `Resources/lv18_A4.txt` ... `Resources/lv18_A8.txt` (answers)
- Create: `Resources/lv18_D4.txt` ... `Resources/lv18_D8.txt` (acceptance dictionaries)
- Test: `WordlikeTests/Daily18WordListTests.swift`
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register 10 txt resources + 1 test file per the recipe)

**Interfaces:**
- Consumes: `/Users/janis.kirsteins/Downloads/lv_LV-1/lv_LV.dic` (hunspell; entries are `word/FLAGS po:tag` or `word po:tag`).
- Produces: bundle resources `lv18_A{4..8}.txt`, `lv18_D{4..8}.txt` - one lowercase word per line, UTF-8, Latvian alphabet only.

- [ ] **Step 1: Write the generation script**

```python
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
```

- [ ] **Step 2: Run the script**

Run: `python3 tools/generate_lv18_wordlists.py`
Expected output: five `len N: X answers, Y accepted` lines with X roughly 573/1560/2912/4884/6689 for lengths 4/5/6/7/8, Y >= X. If `unmunch` is unavailable Y == X; that is acceptable (lemma-only acceptance is the spec fallback).

- [ ] **Step 3: Curate the answer lists**

Review `Resources/lv18_A4.txt` in full and remove entries that are not real standalone common words (abbreviations, interjections, extremely obscure terms, offensive words). Spot-review the first ~100 lines of each other list and remove the same categories. Words must remain lowercase base forms, one per line. Do NOT edit the `lv18_D*.txt` files (acceptance must stay a superset).

- [ ] **Step 4: Write the failing validation test**

Create `WordlikeTests/Daily18WordListTests.swift`:

```swift
@testable import Wordlike
import XCTest

final class Daily18WordListTests: XCTestCase {
    static let latvianLowercase = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvzāčēģīķļņšūž")
    static let minimumAnswerCounts = [4: 300, 5: 500, 6: 600, 7: 400, 8: 300]

    private func lines(of resource: String) throws -> [String] {
        let url = try XCTUnwrap(
            Bundle.main.url(forResource: resource, withExtension: "txt"),
            "Missing resource \(resource).txt"
        )
        let text = try String(contentsOf: url, encoding: .utf8)
        return text.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    func testAnswerListsAreValid() throws {
        for length in 4 ... 8 {
            let words = try lines(of: "lv18_A\(length)")
            XCTAssertGreaterThanOrEqual(
                words.count,
                Self.minimumAnswerCounts[length]!,
                "lv18_A\(length) below minimum"
            )
            for word in words {
                XCTAssertEqual(word.count, length, "\(word) has wrong length in lv18_A\(length)")
                XCTAssertTrue(
                    word.unicodeScalars.allSatisfy { Self.latvianLowercase.contains($0) },
                    "\(word) has invalid characters in lv18_A\(length)"
                )
            }
            XCTAssertEqual(words.count, Set(words).count, "lv18_A\(length) has duplicates")
        }
    }

    func testAnswersAreSubsetOfAcceptance() throws {
        for length in 4 ... 8 {
            let answers = Set(try lines(of: "lv18_A\(length)"))
            let accepted = Set(try lines(of: "lv18_D\(length)"))
            XCTAssertTrue(
                answers.isSubset(of: accepted),
                "lv18_A\(length) contains words missing from lv18_D\(length): \(answers.subtracting(accepted).prefix(5))"
            )
        }
    }
}
```

- [ ] **Step 5: Register files in pbxproj and run the test**

Register the 10 txt files (Resources group + Resources build phase) and the test file (tests group + test Sources phase) per the Global Constraints recipe. Then:

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: all tests PASS including the two new ones. (They fail before registration because the resources are not in the bundle - that is the red step.)

- [ ] **Step 6: Commit**

```bash
git add tools/generate_lv18_wordlists.py Resources/lv18_*.txt WordlikeTests/Daily18WordListTests.swift SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add Latvian 18 vardi word list resources and validation tests"
```

---

### Task 2: Daily18State model

**Files:**
- Create: `Shared/Daily18/Daily18State.swift`
- Test: `WordlikeTests/Daily18StateTests.swift`
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (create the `Daily18` group inside the `Shared` group `E7F299592837DABA005792DA` with `path = Daily18;`, then register both files)

**Interfaces:**
- Produces: `Daily18Phase`, `Daily18Mark`, `Daily18State` exactly as below. IMPORTANT: RawRepresentable + Codable structs in this codebase MUST hand-write CodingKeys and init(from:)/encode(to:) (see `Stats.swift`) - otherwise the stdlib RawRepresentable Codable default recurses infinitely.

- [ ] **Step 1: Write the failing test**

```swift
@testable import Wordlike
import XCTest

final class Daily18StateTests: XCTestCase {
    func testFreshState() {
        let state = Daily18State(day: 7)
        XCTAssertEqual(state.day, 7)
        XCTAssertEqual(state.marks.count, 18)
        XCTAssertTrue(state.marks.allSatisfy { $0 == .pending })
        XCTAssertEqual(state.currentIndex, 0)
        XCTAssertEqual(state.remainingSeconds, 30)
        XCTAssertEqual(state.phase, .notStarted)
        XCTAssertFalse(state.isTallied)
        XCTAssertEqual(state.score, 0)
    }

    func testScoreCountsSolvedMarks() {
        var state = Daily18State(day: 0)
        state.marks[0] = .solved
        state.marks[1] = .failed
        state.marks[5] = .solved
        XCTAssertEqual(state.score, 2)
    }

    func testRawValueRoundTrip() {
        var state = Daily18State(day: 3)
        state.marks[0] = .solved
        state.phase = .inProgress
        state.remainingSeconds = 12
        state.currentIndex = 1
        state.firstPlayedAt = Date(timeIntervalSince1970: 1_784_246_500)

        let restored = Daily18State(rawValue: state.rawValue)
        XCTAssertEqual(restored, state)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `make test`
Expected: FAIL (Daily18State not defined -> build error).

- [ ] **Step 3: Write the implementation**

`Shared/Daily18/Daily18State.swift`:

```swift
import Foundation

enum Daily18Phase: String, Codable, Equatable {
    case notStarted
    case inProgress
    case finished
}

enum Daily18Mark: String, Codable, Equatable {
    case pending
    case solved
    case failed
}

/// Persistent state of one day's 18 vardi run.
/// Stored under `Daily18Storage.stateKey`.
struct Daily18State: RawRepresentable {
    static let wordCount = 18
    static let timePerWord = 30

    var day: Int
    var marks: [Daily18Mark]
    var currentIndex: Int
    var remainingSeconds: Int
    var phase: Daily18Phase
    var isTallied: Bool
    var firstPlayedAt: Date?
    var finishedAt: Date?

    init(day: Int) {
        self.day = day
        self.marks = Array(repeating: .pending, count: Self.wordCount)
        self.currentIndex = 0
        self.remainingSeconds = Self.timePerWord
        self.phase = .notStarted
        self.isTallied = false
        self.firstPlayedAt = nil
        self.finishedAt = nil
    }

    var score: Int {
        marks.filter { $0 == .solved }.count
    }

    // RawRepresentable (JSON string, mirrors Stats)

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
}

extension Daily18State: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case day
        case marks
        case currentIndex
        case remainingSeconds
        case phase
        case isTallied
        case firstPlayedAt
        case finishedAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.day = try values.decode(Int.self, forKey: .day)
        self.marks = try values.decode([Daily18Mark].self, forKey: .marks)
        self.currentIndex = try values.decode(Int.self, forKey: .currentIndex)
        self.remainingSeconds = try values.decode(Int.self, forKey: .remainingSeconds)
        self.phase = try values.decode(Daily18Phase.self, forKey: .phase)
        self.isTallied = try values.decode(Bool.self, forKey: .isTallied)
        self.firstPlayedAt = try values.decodeIfPresent(Date.self, forKey: .firstPlayedAt)
        self.finishedAt = try values.decodeIfPresent(Date.self, forKey: .finishedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(day, forKey: .day)
        try container.encode(marks, forKey: .marks)
        try container.encode(currentIndex, forKey: .currentIndex)
        try container.encode(remainingSeconds, forKey: .remainingSeconds)
        try container.encode(phase, forKey: .phase)
        try container.encode(isTallied, forKey: .isTallied)
        try container.encodeIfPresent(firstPlayedAt, forKey: .firstPlayedAt)
        try container.encodeIfPresent(finishedAt, forKey: .finishedAt)
    }
}
```

- [ ] **Step 4: Register in pbxproj (create Daily18 group), run tests**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Shared/Daily18/Daily18State.swift WordlikeTests/Daily18StateTests.swift SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add Daily18State model for 18 vardi mode"
```

---

### Task 3: Puzzle provider and acceptance dictionary

**Files:**
- Create: `Shared/Daily18/Daily18Puzzle.swift`
- Test: `WordlikeTests/Daily18PuzzleTests.swift`
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register both)

**Interfaces:**
- Consumes: `ArbitraryRandomNumberGenerator(seed:)` (`Shared/Misc/ArbitraryRandomNumberGenerator.swift`), `WordValidator.load(_:)` (uppercases and strips), resources from Task 1.
- Produces: `Daily18Puzzle`, `Daily18PuzzleProvider`, `Daily18Dictionary` per the Shared interface reference.

- [ ] **Step 1: Write the failing test**

```swift
@testable import Wordlike
import XCTest

final class Daily18PuzzleTests: XCTestCase {
    func testStructureIs18WordsWithSpecLengths() {
        XCTAssertEqual(
            Daily18Puzzle.structure,
            [4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 8, 8]
        )
    }

    func testPuzzleIsDeterministicAndFollowsStructure() {
        let lists = Daily18PuzzleProvider.loadAnswerLists()
        let a = Daily18PuzzleProvider.puzzle(forDay: 5, lists: lists)
        let b = Daily18PuzzleProvider.puzzle(forDay: 5, lists: lists)
        let c = Daily18PuzzleProvider.puzzle(forDay: 6, lists: lists)

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a.words, c.words)
        XCTAssertEqual(a.words.map(\.count), Daily18Puzzle.structure)
        XCTAssertEqual(a.words, a.words.map { $0.uppercased() })
    }

    func testScrambleUsesSameLettersAndHidesSolution() {
        for day in 0 ..< 50 {
            let scramble = Daily18PuzzleProvider.scramble("KAROGS", day: day, index: 3)
            XCTAssertEqual(scramble.sorted(), ["A", "G", "K", "O", "R", "S"])
            XCTAssertNotEqual(scramble.joined(), "KAROGS")
        }
    }

    func testScrambleIsDeterministic() {
        XCTAssertEqual(
            Daily18PuzzleProvider.scramble("MĀJA", day: 2, index: 0),
            Daily18PuzzleProvider.scramble("MĀJA", day: 2, index: 0)
        )
    }

    func testDictionaryContainsAnswersAndRejectsGarbage() {
        let lists = Daily18PuzzleProvider.loadAnswerLists()
        let dictionary = Daily18Dictionary.load()
        let puzzle = Daily18PuzzleProvider.puzzle(forDay: 0, lists: lists)

        for word in puzzle.words {
            XCTAssertTrue(dictionary.contains(word), "\(word) missing from acceptance dictionary")
        }
        XCTAssertFalse(dictionary.contains("QQQQ"))
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `make test`
Expected: FAIL (types not defined).

- [ ] **Step 3: Write the implementation**

`Shared/Daily18/Daily18Puzzle.swift`:

```swift
import Foundation

/// One day's 18 vardi puzzle: the answers and their scrambled letters.
struct Daily18Puzzle: Equatable {
    /// Word length per slot, in play order (2x4, 5x5, 6x6, 3x7, 2x8).
    static let structure = [4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 8, 8]

    /// Uppercase answers, one per slot.
    let words: [String]

    /// Per-slot scrambled letters as single-character uppercase strings.
    let scrambles: [[String]]
}

enum Daily18PuzzleProvider {
    /// Seed for the one-time deterministic shuffle of each answer list.
    static let listSeed: UInt64 = 4242

    static var countsPerDay: [Int: Int] {
        Daily18Puzzle.structure.reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }

    static func loadAnswerLists() -> [Int: [String]] {
        var result: [Int: [String]] = [:]
        for length in 4 ... 8 {
            var rng = ArbitraryRandomNumberGenerator(seed: listSeed &+ UInt64(length))
            result[length] = WordValidator.load("lv18_A\(length)").shuffled(using: &rng)
        }
        return result
    }

    static func puzzle(forDay day: Int, lists: [Int: [String]]) -> Daily18Puzzle {
        var nextOffset: [Int: Int] = [:]
        var words: [String] = []

        for length in Daily18Puzzle.structure {
            guard let list = lists[length], !list.isEmpty else {
                fatalError("Missing lv18 answer list for length \(length)")
            }

            let perDay = countsPerDay[length] ?? 0
            let offset = nextOffset[length] ?? 0
            let index = (day * perDay + offset) % list.count
            words.append(list[index])
            nextOffset[length] = offset + 1
        }

        let scrambles = words.enumerated().map { index, word in
            scramble(word, day: day, index: index)
        }

        return Daily18Puzzle(words: words, scrambles: scrambles)
    }

    static func scramble(_ word: String, day: Int, index: Int) -> [String] {
        let letters = Array(word).map { String($0) }
        var rng = ArbitraryRandomNumberGenerator(
            seed: 981_712 &+ UInt64(day) &* 100 &+ UInt64(index)
        )
        var shuffled = letters.shuffled(using: &rng)

        if shuffled == letters, Set(letters).count > 1 {
            for swapIndex in 1 ..< shuffled.count where shuffled[swapIndex] != shuffled[0] {
                shuffled.swapAt(0, swapIndex)
                break
            }
        }

        return shuffled
    }
}

/// Acceptance dictionary: any word here (or the target itself) is a
/// valid submission, mirroring 18words.com behavior.
final class Daily18Dictionary {
    let wordsByLength: [Int: Set<String>]

    init(wordsByLength: [Int: Set<String>]) {
        self.wordsByLength = wordsByLength
    }

    static func load() -> Daily18Dictionary {
        var result: [Int: Set<String>] = [:]
        for length in 4 ... 8 {
            result[length] = Set(WordValidator.load("lv18_D\(length)"))
        }
        return Daily18Dictionary(wordsByLength: result)
    }

    func contains(_ word: String) -> Bool {
        wordsByLength[word.count]?.contains(word) == true
    }
}
```

- [ ] **Step 4: Register in pbxproj, run tests**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS. Note: `testScrambleUsesSameLettersAndHidesSolution` could only fail for a pathological seed; if it does, adjust the constant `981_712` and re-run - do not weaken the assertion.

- [ ] **Step 5: Commit**

```bash
git add Shared/Daily18/Daily18Puzzle.swift WordlikeTests/Daily18PuzzleTests.swift SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add deterministic 18 vardi puzzle provider and acceptance dictionary"
```

---

### Task 4: Game engine

**Files:**
- Create: `Shared/Daily18/Daily18Engine.swift`
- Test: `WordlikeTests/Daily18EngineTests.swift`
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register both)

**Interfaces:**
- Consumes: `Daily18Puzzle`, `Daily18State`, `Daily18Mark`, `Daily18Phase`.
- Produces: `Daily18Engine` per the Shared interface reference. `placed` holds indices into `currentScramble` in placement order; a full `placed` auto-submits; rejection clears `placed` and bumps `rejectionCount`.

- [ ] **Step 1: Write the failing test**

```swift
@testable import Wordlike
import XCTest

final class Daily18EngineTests: XCTestCase {
    /// Two tiny words keep tests readable; the engine does not
    /// depend on the full 18-slot structure.
    private func makeEngine(accepted: Set<String> = []) -> Daily18Engine {
        var state = Daily18State(day: 0)
        state.marks = Array(repeating: .pending, count: 2)
        let puzzle = Daily18Puzzle(
            words: ["SALA", "MĀJA"],
            scrambles: [["L", "A", "S", "A"], ["A", "M", "J", "Ā"]]
        )
        return Daily18Engine(
            puzzle: puzzle,
            state: state,
            isAccepted: { accepted.contains($0) }
        )
    }

    private func place(_ engine: Daily18Engine, _ word: String) {
        for letter in word.map(String.init) {
            let scramble = engine.currentScramble
            let index = scramble.indices.first {
                scramble[$0] == letter && !engine.placed.contains($0)
            }!
            engine.placeLetter(circleIndex: index)
        }
    }

    func testStartTransitionsToInProgress() {
        let engine = makeEngine()
        XCTAssertEqual(engine.state.phase, .notStarted)
        engine.start()
        XCTAssertEqual(engine.state.phase, .inProgress)
        XCTAssertNotNil(engine.state.firstPlayedAt)
    }

    func testSolvingTargetAdvancesWithFreshTimer() {
        let engine = makeEngine()
        engine.start()
        engine.tick()
        place(engine, "SALA")
        XCTAssertEqual(engine.state.marks[0], .solved)
        XCTAssertEqual(engine.state.currentIndex, 1)
        XCTAssertEqual(engine.state.remainingSeconds, Daily18State.timePerWord)
        XCTAssertTrue(engine.placed.isEmpty)
    }

    func testDictionaryAnagramIsAccepted() {
        let engine = makeEngine(accepted: ["ALAS"])
        engine.start()
        place(engine, "ALAS")
        XCTAssertEqual(engine.state.marks[0], .solved)
    }

    func testRejectionClearsPlacementAndCounts() {
        let engine = makeEngine()
        engine.start()
        place(engine, "ASAL")
        XCTAssertEqual(engine.state.marks[0], .pending)
        XCTAssertTrue(engine.placed.isEmpty)
        XCTAssertEqual(engine.rejectionCount, 1)
        XCTAssertEqual(engine.state.currentIndex, 0)
    }

    func testRemoveLastUndoesPlacement() {
        let engine = makeEngine()
        engine.start()
        engine.placeLetter(circleIndex: 2)
        engine.placeLetter(circleIndex: 1)
        engine.removeLast()
        XCTAssertEqual(engine.placed, [2])
    }

    func testDuplicateCircleCannotBePlacedTwice() {
        let engine = makeEngine()
        engine.start()
        engine.placeLetter(circleIndex: 1)
        engine.placeLetter(circleIndex: 1)
        XCTAssertEqual(engine.placed, [1])
    }

    func testTimeoutFailsWordAndAdvances() {
        let engine = makeEngine()
        engine.start()
        for _ in 0 ..< Daily18State.timePerWord {
            engine.tick()
        }
        XCTAssertEqual(engine.state.marks[0], .failed)
        XCTAssertEqual(engine.state.currentIndex, 1)
        XCTAssertEqual(engine.state.remainingSeconds, Daily18State.timePerWord)
    }

    func testFinishingLastWordEndsRun() {
        let engine = makeEngine()
        engine.start()
        place(engine, "SALA")
        place(engine, "MĀJA")
        XCTAssertEqual(engine.state.phase, .finished)
        XCTAssertNotNil(engine.state.finishedAt)
        XCTAssertEqual(engine.state.score, 2)
    }

    func testTickIgnoredWhenNotInProgress() {
        let engine = makeEngine()
        engine.tick()
        XCTAssertEqual(engine.state.remainingSeconds, Daily18State.timePerWord)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `make test`
Expected: FAIL (Daily18Engine not defined).

- [ ] **Step 3: Write the implementation**

`Shared/Daily18/Daily18Engine.swift`:

```swift
import Foundation

/// UI-independent 18 vardi game state machine. The hosting view owns
/// the 1 Hz timer and calls `tick()`; everything else is event-driven.
final class Daily18Engine: ObservableObject {
    let puzzle: Daily18Puzzle
    let isAccepted: (String) -> Bool

    @Published private(set) var state: Daily18State

    /// Indices into `currentScramble`, in placement order.
    @Published private(set) var placed: [Int] = []

    /// Increments on every rejected submission (drives the shake).
    @Published private(set) var rejectionCount = 0

    init(
        puzzle: Daily18Puzzle,
        state: Daily18State,
        isAccepted: @escaping (String) -> Bool
    ) {
        self.puzzle = puzzle
        self.state = state
        self.isAccepted = isAccepted
    }

    var wordCount: Int {
        state.marks.count
    }

    var currentScramble: [String] {
        guard state.currentIndex < puzzle.scrambles.count else { return [] }
        return puzzle.scrambles[state.currentIndex]
    }

    var currentTarget: String {
        guard state.currentIndex < puzzle.words.count else { return "" }
        return puzzle.words[state.currentIndex]
    }

    var currentGuess: String {
        placed.map { currentScramble[$0] }.joined()
    }

    func start(now: Date = Date()) {
        guard state.phase == .notStarted else { return }
        state.phase = .inProgress
        state.firstPlayedAt = now
        state.remainingSeconds = Daily18State.timePerWord
    }

    func placeLetter(circleIndex: Int) {
        guard state.phase == .inProgress,
              currentScramble.indices.contains(circleIndex),
              !placed.contains(circleIndex)
        else {
            return
        }

        placed.append(circleIndex)

        if placed.count == currentScramble.count {
            submit(now: Date())
        }
    }

    func removeLast() {
        guard state.phase == .inProgress, !placed.isEmpty else { return }
        placed.removeLast()
    }

    func tick(now: Date = Date()) {
        guard state.phase == .inProgress else { return }
        state.remainingSeconds -= 1
        if state.remainingSeconds <= 0 {
            state.marks[state.currentIndex] = .failed
            advance(now: now)
        }
    }

    func markTallied() {
        state.isTallied = true
    }

    private func submit(now: Date) {
        let guess = currentGuess
        if guess == currentTarget || isAccepted(guess) {
            state.marks[state.currentIndex] = .solved
            advance(now: now)
        } else {
            rejectionCount += 1
            placed = []
        }
    }

    private func advance(now: Date) {
        placed = []
        if state.currentIndex + 1 >= wordCount {
            state.phase = .finished
            state.finishedAt = now
        } else {
            state.currentIndex += 1
            state.remainingSeconds = Daily18State.timePerWord
        }
    }
}
```

- [ ] **Step 4: Register in pbxproj, run tests**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Shared/Daily18/Daily18Engine.swift WordlikeTests/Daily18EngineTests.swift SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add 18 vardi game engine"
```

---

### Task 5: Stats and trophy tiers

**Files:**
- Create: `Shared/Daily18/Daily18Stats.swift`
- Test: `WordlikeTests/Daily18StatsTests.swift`
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register both)
- Modify: `Resources/en.lproj/Localizable.strings`, `Resources/fr.lproj/Localizable.strings`, `Resources/lv.lproj/Localizable.strings` (trophy strings)

**Interfaces:**
- Consumes: `TurnCounter` protocol (`point(_:isInPrecedingPeriodFrom:)`), `BucketTurnCounter` (existing, for tests: `init(start: Date, bucket: TimeInterval)`), `Daily18State.wordCount`.
- Produces: `Daily18Stats`, `Daily18TrophyTier` per the Shared interface reference.

- [ ] **Step 1: Add localized strings (all three files, same commit)**

`Resources/en.lproj/Localizable.strings`:
```
"Top %lld%% of players today" = "Top %lld%% of players today";
"No trophy earned today" = "No trophy earned today";
```
`Resources/fr.lproj/Localizable.strings`:
```
"Top %lld%% of players today" = "Top %lld %% des joueurs aujourd'hui";
"No trophy earned today" = "Pas de trophée aujourd'hui";
```
`Resources/lv.lproj/Localizable.strings`:
```
"Top %lld%% of players today" = "Šodien esi starp labākajiem %lld%% spēlētāju";
"No trophy earned today" = "Šodien trofeja nav nopelnīta";
```

- [ ] **Step 2: Write the failing test**

```swift
@testable import Wordlike
import XCTest

final class Daily18StatsTests: XCTestCase {
    let counter = BucketTurnCounter(start: Date(timeIntervalSince1970: 0), bucket: 100)

    func testFreshStats() {
        let stats = Daily18Stats()
        XCTAssertEqual(stats.played, 0)
        XCTAssertEqual(stats.scoreDistribution.count, 19)
        XCTAssertEqual(stats.trophyStreak, 0)
        XCTAssertEqual(stats.perfectDays, 0)
    }

    func testTrophyDayStartsStreakAndFillsDistribution() {
        let updated = Daily18Stats().update(
            score: 10,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        XCTAssertEqual(updated.played, 1)
        XCTAssertEqual(updated.trophyStreak, 1)
        XCTAssertEqual(updated.maxTrophyStreak, 1)
        XCTAssertEqual(updated.scoreDistribution[10], 1)
        XCTAssertEqual(updated.perfectDays, 0)
        XCTAssertNotNil(updated.lastTrophyAt)
    }

    func testConsecutiveTrophyDaysExtendStreak() {
        let first = Daily18Stats().update(
            score: 9,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        let second = first.update(
            score: 18,
            finishedAt: Date(timeIntervalSince1970: 150),
            with: counter
        )
        XCTAssertEqual(second.trophyStreak, 2)
        XCTAssertEqual(second.maxTrophyStreak, 2)
        XCTAssertEqual(second.perfectDays, 1)
    }

    func testGapResetsStreak() {
        let first = Daily18Stats().update(
            score: 9,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        let afterGap = first.update(
            score: 12,
            finishedAt: Date(timeIntervalSince1970: 350),
            with: counter
        )
        XCTAssertEqual(afterGap.trophyStreak, 1)
        XCTAssertEqual(afterGap.maxTrophyStreak, 1)
    }

    func testSubTrophyScoreBreaksStreakButCounts() {
        let first = Daily18Stats().update(
            score: 9,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        let second = first.update(
            score: 5,
            finishedAt: Date(timeIntervalSince1970: 150),
            with: counter
        )
        XCTAssertEqual(second.trophyStreak, 0)
        XCTAssertEqual(second.played, 2)
        XCTAssertEqual(second.scoreDistribution[5], 1)
        XCTAssertEqual(second.maxTrophyStreak, 1)
    }

    func testRawValueRoundTrip() {
        let stats = Daily18Stats().update(
            score: 17,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        XCTAssertEqual(Daily18Stats(rawValue: stats.rawValue), stats)
    }

    func testTrophyTiersMatch18WordsDotCom() {
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 18), 1)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 17), 2)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 16), 3)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 15), 5)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 14), 10)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 12), 10)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 11), 20)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 10), 20)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 9), 50)
        XCTAssertEqual(Daily18TrophyTier.percent(forScore: 8), 50)
        XCTAssertNil(Daily18TrophyTier.percent(forScore: 7))
        XCTAssertEqual(Daily18TrophyTier.emoji(forScore: 18), "👑")
        XCTAssertEqual(Daily18TrophyTier.emoji(forScore: 16), "🏆")
        XCTAssertEqual(Daily18TrophyTier.emoji(forScore: 10), "🏅")
        XCTAssertEqual(Daily18TrophyTier.emoji(forScore: 0), "💔")
    }
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `make test`
Expected: FAIL (types not defined).

- [ ] **Step 4: Write the implementation**

`Shared/Daily18/Daily18Stats.swift`:

```swift
import SwiftUI

/// Aggregate 18 vardi statistics, stored under `Daily18Storage.statsKey`.
struct Daily18Stats: RawRepresentable {
    static let trophyThreshold = 8

    let played: Int
    /// Index == score (0...18).
    let scoreDistribution: [Int]
    let trophyStreak: Int
    let maxTrophyStreak: Int
    let perfectDays: Int
    let lastTrophyAt: Date?

    init(
        played: Int,
        scoreDistribution: [Int],
        trophyStreak: Int,
        maxTrophyStreak: Int,
        perfectDays: Int,
        lastTrophyAt: Date?
    ) {
        self.played = played
        self.scoreDistribution = scoreDistribution
        self.trophyStreak = trophyStreak
        self.maxTrophyStreak = maxTrophyStreak
        self.perfectDays = perfectDays
        self.lastTrophyAt = lastTrophyAt
    }

    init() {
        self.played = 0
        self.scoreDistribution = Array(repeating: 0, count: Daily18State.wordCount + 1)
        self.trophyStreak = 0
        self.maxTrophyStreak = 0
        self.perfectDays = 0
        self.lastTrophyAt = nil
    }

    func update(score: Int, finishedAt: Date, with counter: TurnCounter) -> Daily18Stats {
        let isTrophy = score >= Self.trophyThreshold

        let streakable: Bool
        if let lastTrophyAt = lastTrophyAt {
            streakable = counter.point(lastTrophyAt, isInPrecedingPeriodFrom: finishedAt)
        } else {
            streakable = false
        }

        let newStreak = isTrophy ? (streakable ? trophyStreak : 0) + 1 : 0

        var distribution = scoreDistribution
        let requiredCount = Daily18State.wordCount + 1
        if distribution.count < requiredCount {
            distribution += Array(repeating: 0, count: requiredCount - distribution.count)
        }
        if (0 ..< requiredCount).contains(score) {
            distribution[score] += 1
        }

        return Daily18Stats(
            played: played + 1,
            scoreDistribution: distribution,
            trophyStreak: newStreak,
            maxTrophyStreak: max(newStreak, maxTrophyStreak),
            perfectDays: perfectDays + (score == Daily18State.wordCount ? 1 : 0),
            lastTrophyAt: isTrophy ? finishedAt : lastTrophyAt
        )
    }

    func widthRatio(score: Int) -> CGFloat {
        let maxCount = CGFloat(scoreDistribution.max() ?? 0)
        guard maxCount > 0, scoreDistribution.indices.contains(score) else { return 0 }
        return CGFloat(scoreDistribution[score]) / maxCount
    }

    // RawRepresentable (JSON string, mirrors Stats)

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
}

extension Daily18Stats: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case played
        case scoreDistribution
        case trophyStreak
        case maxTrophyStreak
        case perfectDays
        case lastTrophyAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.played = try values.decode(Int.self, forKey: .played)
        self.scoreDistribution = try values.decode([Int].self, forKey: .scoreDistribution)
        self.trophyStreak = try values.decode(Int.self, forKey: .trophyStreak)
        self.maxTrophyStreak = try values.decode(Int.self, forKey: .maxTrophyStreak)
        self.perfectDays = try values.decode(Int.self, forKey: .perfectDays)
        self.lastTrophyAt = try values.decodeIfPresent(Date.self, forKey: .lastTrophyAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(played, forKey: .played)
        try container.encode(scoreDistribution, forKey: .scoreDistribution)
        try container.encode(trophyStreak, forKey: .trophyStreak)
        try container.encode(maxTrophyStreak, forKey: .maxTrophyStreak)
        try container.encode(perfectDays, forKey: .perfectDays)
        try container.encodeIfPresent(lastTrophyAt, forKey: .lastTrophyAt)
    }
}

/// Hardcoded score-to-percentile mapping, cloned from 18words.com.
enum Daily18TrophyTier {
    static func percent(forScore score: Int) -> Int? {
        switch score {
        case 18: return 1
        case 17: return 2
        case 16: return 3
        case 15: return 5
        case 12 ... 14: return 10
        case 10 ... 11: return 20
        case 8 ... 9: return 50
        default: return nil
        }
    }

    static func emoji(forScore score: Int) -> String {
        switch score {
        case 18: return "👑"
        case 15 ... 17: return "🏆"
        case 8 ... 14: return "🏅"
        default: return "💔"
        }
    }

    /// Localized line for the results screen and share text.
    static func line(forScore score: Int) -> String {
        guard let percent = percent(forScore: score) else {
            return NSLocalizedString("No trophy earned today", comment: "")
                + " " + emoji(forScore: score)
        }
        let format = NSLocalizedString("Top %lld%% of players today", comment: "")
        return String(format: format, percent) + " " + emoji(forScore: score)
    }
}
```

- [ ] **Step 5: Register in pbxproj, run tests**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Shared/Daily18/Daily18Stats.swift WordlikeTests/Daily18StatsTests.swift Resources/en.lproj/Localizable.strings Resources/fr.lproj/Localizable.strings Resources/lv.lproj/Localizable.strings SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add 18 vardi stats model and trophy tiers"
```

---

### Task 6: Share text builder

**Files:**
- Create: `Shared/Daily18/Daily18Share.swift`
- Test: `WordlikeTests/Daily18ShareTests.swift`
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register both)
- Modify: all three `Localizable.strings` (share strings)

**Interfaces:**
- Consumes: `Daily18Mark`, `Daily18TrophyTier.line(forScore:)`.
- Produces: `Daily18Share.squares/scoreText/challengeText` per the Shared interface reference. Day parameter is the 0-based day index; the visible puzzle number is `day + 1`.

- [ ] **Step 1: Add localized strings (all three files)**

en: `"%lld/18 words found" = "%lld/18 words found";` and `"Can you beat my score?" = "Can you beat my score?";`
fr: `"%lld/18 words found" = "%lld/18 mots trouvés";` and `"Can you beat my score?" = "Peux-tu battre mon score ?";`
lv: `"%lld/18 words found" = "Atrasti %lld/18 vārdi";` and `"Can you beat my score?" = "Vai vari pārspēt manu rezultātu?";`

- [ ] **Step 2: Write the failing test**

```swift
@testable import Wordlike
import XCTest

final class Daily18ShareTests: XCTestCase {
    var marks: [Daily18Mark] {
        var m = [Daily18Mark](repeating: .solved, count: 18)
        m[3] = .failed
        m[4] = .failed
        return m
    }

    func testSquaresAreThreeRowsOfSix() {
        let squares = Daily18Share.squares(for: marks)
        let rows = squares.components(separatedBy: "\n")
        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(rows[0], "🟩🟩🟩🟥🟥🟩")
        XCTAssertEqual(rows[1], "🟩🟩🟩🟩🟩🟩")
        XCTAssertEqual(rows[2], "🟩🟩🟩🟩🟩🟩")
    }

    func testScoreTextFormat() {
        let text = Daily18Share.scoreText(day: 32, marks: marks)
        XCTAssertTrue(text.hasPrefix("18 vārdi #33\n\n"))
        XCTAssertTrue(text.contains("16/18"))
        XCTAssertTrue(text.contains("🟩🟩🟩🟥🟥🟩\n🟩🟩🟩🟩🟩🟩\n🟩🟩🟩🟩🟩🟩"))
        XCTAssertTrue(text.contains(Daily18TrophyTier.line(forScore: 16)))
        XCTAssertTrue(text.hasSuffix("\n"))
    }

    func testChallengeTextSwapsFooter() {
        let text = Daily18Share.challengeText(day: 32, marks: marks)
        XCTAssertFalse(text.contains(Daily18TrophyTier.line(forScore: 16)))
        XCTAssertTrue(text.contains("🫵"))
    }
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `make test`
Expected: FAIL (Daily18Share not defined).

- [ ] **Step 4: Write the implementation**

`Shared/Daily18/Daily18Share.swift`:

```swift
import Foundation

/// Builds the share sheet texts, cloning the 18words.com format.
enum Daily18Share {
    static func squares(for marks: [Daily18Mark]) -> String {
        stride(from: 0, to: marks.count, by: 6).map { start in
            marks[start ..< min(start + 6, marks.count)]
                .map { $0 == .solved ? "🟩" : "🟥" }
                .joined()
        }.joined(separator: "\n")
    }

    static func scoreText(day: Int, marks: [Daily18Mark]) -> String {
        text(
            day: day,
            marks: marks,
            footer: Daily18TrophyTier.line(forScore: score(of: marks))
        )
    }

    static func challengeText(day: Int, marks: [Daily18Mark]) -> String {
        text(
            day: day,
            marks: marks,
            footer: NSLocalizedString("Can you beat my score?", comment: "") + " 🫵"
        )
    }

    private static func score(of marks: [Daily18Mark]) -> Int {
        marks.filter { $0 == .solved }.count
    }

    private static func text(day: Int, marks: [Daily18Mark], footer: String) -> String {
        let scoreLine = String(
            format: NSLocalizedString("%lld/18 words found", comment: ""),
            score(of: marks)
        )

        return [
            "18 vārdi #\(day + 1)",
            "",
            scoreLine,
            "",
            squares(for: marks),
            "",
            footer,
        ].joined(separator: "\n") + "\n"
    }
}
```

- [ ] **Step 5: Register in pbxproj, run tests**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS. (Note: unit tests run with the default locale so `NSLocalizedString` resolves English values; assertions above only rely on locale-independent parts plus `Daily18TrophyTier.line`, which resolves identically inside the test.)

- [ ] **Step 6: Commit**

```bash
git add Shared/Daily18/Daily18Share.swift WordlikeTests/Daily18ShareTests.swift Resources/en.lproj/Localizable.strings Resources/fr.lproj/Localizable.strings Resources/lv.lproj/Localizable.strings SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add 18 vardi share text builder"
```

---

### Task 7: Storage helper, loader, and gameplay views (pre-game + game)

**Files:**
- Create: `Shared/Daily18/Daily18Storage.swift`
- Create: `Shared/Daily18/Daily18Host.swift`
- Create: `Shared/Daily18/Daily18GameView.swift`
- Test: `WordlikeTests/Daily18StorageTests.swift`
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register all)
- Modify: all three `Localizable.strings`

**Interfaces:**
- Consumes: everything from Tasks 2-6; `CalendarDailyTurnCounter.current(start:)`; `AppStateStorage`; `Palette` environment (`@Environment(\.palette)`; colors used: `palette.rightPlaceFill`, `palette.wrongLetterFill`, `palette.normalKeyboardFill` if present - check `Shared/Palettes/Palette.swift` for exact property names before use and prefer `rightPlaceFill` for solved, `Color.red.opacity(0.8)` is NOT acceptable: use the palette's incorrect color, e.g. `wrongLetterFill` for failed and `.quaternary`-style neutral via `wrongLetterFill.opacity(0.4)` for pending); `Analytics.shared.trackAction(name:attributes:)`; `.trackRUMView(name:)` modifier (from DatadogRUM, see `AppView.swift` usage).
- Produces: `Daily18Storage`, `Daily18Loader` (ObservableObject with `@Published var engine: Daily18Engine?` and `func load(day:resuming:)`), `Daily18Host` (public entry view; `static let gameLocaleAttribute = "lv18"`), `Daily18FlowView`, `Daily18PreGameView`, `Daily18GameView`, `Daily18ProgressGrid`, `ShakeEffect`.
- Results-phase UI is a placeholder in this task (`Daily18ResultsPlaceholder` showing the score); Task 8 replaces it.

- [ ] **Step 1: Add localized strings (all three files)**

en:
```
"Word %lld of 18" = "Word %lld of 18";
"Play" = "Play";
"You found %lld of 18 words!" = "You found %lld of 18 words!";
```
fr:
```
"Word %lld of 18" = "Mot %lld sur 18";
"Play" = "Jouer";
"You found %lld of 18 words!" = "Vous avez trouvé %lld mots sur 18 !";
```
lv:
```
"Word %lld of 18" = "Vārds %lld no 18";
"Play" = "Spēlēt";
"You found %lld of 18 words!" = "Tu atradi %lld no 18 vārdiem!";
```
(If a key already exists in the files, keep the existing entry and do not duplicate it.)

- [ ] **Step 2: Write the failing storage test**

`WordlikeTests/Daily18StorageTests.swift`:

```swift
@testable import Wordlike
import XCTest

final class Daily18StorageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: Daily18Storage.stateKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Daily18Storage.stateKey)
        super.tearDown()
    }

    func testKeysMatchSpec() {
        XCTAssertEqual(Daily18Storage.stateKey, "daily18.lv")
        XCTAssertEqual(Daily18Storage.statsKey, "stats18.lv")
    }

    func testStoredStateRoundTrip() {
        XCTAssertNil(Daily18Storage.storedState())

        var state = Daily18State(day: 2)
        state.phase = .finished
        UserDefaults.standard.set(state.rawValue, forKey: Daily18Storage.stateKey)

        XCTAssertEqual(Daily18Storage.storedState(), state)
    }

    func testIsFinishedTodayRequiresTodayAndFinished() {
        let counter = Daily18Storage.makeTurnCounter()
        let today = counter.turnIndex(at: Date())

        var state = Daily18State(day: today)
        state.phase = .inProgress
        UserDefaults.standard.set(state.rawValue, forKey: Daily18Storage.stateKey)
        XCTAssertFalse(Daily18Storage.isFinishedToday())

        state.phase = .finished
        UserDefaults.standard.set(state.rawValue, forKey: Daily18Storage.stateKey)
        XCTAssertTrue(Daily18Storage.isFinishedToday())

        state.day = today - 1
        UserDefaults.standard.set(state.rawValue, forKey: Daily18Storage.stateKey)
        XCTAssertFalse(Daily18Storage.isFinishedToday())
    }
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `make test`
Expected: FAIL (Daily18Storage not defined).

- [ ] **Step 4: Implement Daily18Storage**

`Shared/Daily18/Daily18Storage.swift`:

```swift
import Foundation

/// Storage keys and the day counter for the 18 vardi mode.
enum Daily18Storage {
    static let stateKey = "daily18.lv"
    static let statsKey = "stats18.lv"

    /// 2026-07-17T00:00:00Z. Day 0 is puzzle #1.
    static let epoch = Date(timeIntervalSince1970: 1_784_246_400)

    static func makeTurnCounter() -> TurnCounter {
        CalendarDailyTurnCounter.current(start: epoch)
    }

    static func storedState() -> Daily18State? {
        guard let raw = UserDefaults.standard.string(forKey: stateKey) else {
            return nil
        }
        return Daily18State(rawValue: raw)
    }

    static func isFinishedToday(at now: Date = Date()) -> Bool {
        guard let state = storedState() else { return false }
        return state.phase == .finished
            && state.day == makeTurnCounter().turnIndex(at: now)
    }
}
```

- [ ] **Step 5: Run the storage test**

Run: `make test`
Expected: PASS.

- [ ] **Step 6: Implement host + loader + flow**

`Shared/Daily18/Daily18Host.swift`:

```swift
import DatadogRUM
import SwiftUI

/// Loads word lists off the main thread, then owns the engine.
final class Daily18Loader: ObservableObject {
    @Published var engine: Daily18Engine?

    func load(day: Int, resuming stored: Daily18State?) {
        guard engine == nil else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            let lists = Daily18PuzzleProvider.loadAnswerLists()
            let puzzle = Daily18PuzzleProvider.puzzle(forDay: day, lists: lists)
            let dictionary = Daily18Dictionary.load()

            let state: Daily18State
            if let stored = stored, stored.day == day {
                state = stored
            } else {
                state = Daily18State(day: day)
            }

            DispatchQueue.main.async {
                self.engine = Daily18Engine(
                    puzzle: puzzle,
                    state: state,
                    isAccepted: { dictionary.contains($0) }
                )
            }
        }
    }
}

/// Entry point for the 18 vardi mode (menu row destination).
struct Daily18Host: View {
    static let gameLocaleAttribute = "lv18"

    @AppStateStorage(Daily18Storage.stateKey)
    var storedState: Daily18State = Daily18State(day: -1)

    @AppStateStorage(Daily18Storage.statsKey)
    var stats: Daily18Stats = Daily18Stats()

    @StateObject var loader = Daily18Loader()

    let turnCounter = Daily18Storage.makeTurnCounter()

    var body: some View {
        Group {
            if let engine = loader.engine {
                Daily18FlowView(
                    engine: engine,
                    turnCounter: turnCounter,
                    storedState: $storedState,
                    stats: $stats
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            let today = turnCounter.turnIndex(at: Date())
            loader.load(
                day: today,
                resuming: storedState.day == today ? storedState : nil
            )
        }
        .trackRUMView(name: "Game18")
    }
}

/// Switches between pre-game, gameplay, and results, and persists
/// every engine state change.
struct Daily18FlowView: View {
    @ObservedObject var engine: Daily18Engine
    let turnCounter: TurnCounter

    @Binding var storedState: Daily18State
    @Binding var stats: Daily18Stats

    var body: some View {
        Group {
            switch engine.state.phase {
            case .notStarted:
                Daily18PreGameView(
                    day: engine.state.day,
                    startAction: {
                        engine.start()
                        Analytics.shared.trackAction(
                            name: "game.started",
                            attributes: [
                                "game_locale": Daily18Host.gameLocaleAttribute,
                            ]
                        )
                    }
                )
            case .inProgress:
                Daily18GameView(engine: engine)
            case .finished:
                Daily18ResultsPlaceholder(state: engine.state)
            }
        }
        .onReceive(engine.$state) { newState in
            storedState = newState

            if newState.phase == .finished, !newState.isTallied {
                let score = newState.score
                stats = stats.update(
                    score: score,
                    finishedAt: newState.finishedAt ?? Date(),
                    with: turnCounter
                )
                engine.markTallied()
                Analytics.shared.trackAction(
                    name: score >= Daily18Stats.trophyThreshold ? "game.won" : "game.lost",
                    attributes: [
                        "game_locale": Daily18Host.gameLocaleAttribute,
                        "score": score,
                    ]
                )
            }
        }
    }
}

/// Mirrors the 18words.com landing screen.
struct Daily18PreGameView: View {
    let day: Int
    let startAction: () -> Void

    @Environment(\.palette) var palette: Palette

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Daily18ProgressGrid(marks: Array(repeating: .pending, count: Daily18State.wordCount))
                .frame(maxWidth: 280)

            Text(verbatim: "18 vārdi")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(verbatim: "#\(day + 1) | " + DateFormatter.localizedString(
                from: Date(), dateStyle: .medium, timeStyle: .none
            ))
            .font(.body)
            .foregroundColor(.secondary)

            Button(action: startAction) {
                Text("Play")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
}

/// Temporary results screen; replaced by Daily18ResultsView in a
/// follow-up task.
struct Daily18ResultsPlaceholder: View {
    let state: Daily18State

    var body: some View {
        VStack(spacing: 16) {
            Daily18ProgressGrid(marks: state.marks)
                .frame(maxWidth: 280)
            Text(
                String(
                    format: NSLocalizedString("You found %lld of 18 words!", comment: ""),
                    state.score
                )
            )
            .font(.title2)
            .fontWeight(.bold)
        }
    }
}
```

- [ ] **Step 7: Implement the game view**

`Shared/Daily18/Daily18GameView.swift`:

```swift
import SwiftUI

/// The 18-tile progress grid (3 rows of 6).
struct Daily18ProgressGrid: View {
    let marks: [Daily18Mark]

    @Environment(\.palette) var palette: Palette

    func color(for mark: Daily18Mark) -> Color {
        switch mark {
        case .solved:
            return palette.rightPlaceFill
        case .failed:
            return palette.wrongLetterFill
        case .pending:
            return palette.wrongLetterFill.opacity(0.3)
        }
    }

    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 6),
                count: 6
            ),
            spacing: 6
        ) {
            ForEach(Array(marks.enumerated()), id: \.offset) { _, mark in
                RoundedRectangle(cornerRadius: 6)
                    .fill(color(for: mark))
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

/// Horizontal shake, driven by an increasing trigger value.
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size _: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: 8 * sin(animatableData * .pi * 4),
                y: 0
            )
        )
    }
}

struct Daily18GameView: View {
    @ObservedObject var engine: Daily18Engine

    @Environment(\.palette) var palette: Palette

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var slotLetters: [String?] {
        let scramble = engine.currentScramble
        return (0 ..< scramble.count).map { slot in
            slot < engine.placed.count ? scramble[engine.placed[slot]] : nil
        }
    }

    /// Circle rows split like the web original: ceil(n/2) then the rest.
    var circleRows: [[Int]] {
        let indices = Array(engine.currentScramble.indices)
        let firstRowCount = (indices.count + 1) / 2
        return [
            Array(indices.prefix(firstRowCount)),
            Array(indices.dropFirst(firstRowCount)),
        ]
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 20) {
                Daily18ProgressGrid(marks: engine.state.marks)
                    .frame(maxWidth: 280)

                Text(
                    String(
                        format: NSLocalizedString("Word %lld of 18", comment: ""),
                        engine.state.currentIndex + 1
                    )
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

                Text(verbatim: "\(max(0, engine.state.remainingSeconds))")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundColor(
                        engine.state.remainingSeconds <= 5 ? .red : .primary
                    )
                    .monospacedDigit()

                slotRow(width: proxy.size.width)
                    .modifier(
                        ShakeEffect(animatableData: CGFloat(engine.rejectionCount))
                    )
                    .animation(
                        .linear(duration: 0.4),
                        value: engine.rejectionCount
                    )

                circles(width: proxy.size.width)

                Button(action: { engine.removeLast() }) {
                    Image(systemName: "delete.left")
                        .font(.title2)
                }
                .disabled(engine.placed.isEmpty)
                .safeTint(.primary)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .onReceive(timer) { _ in
            engine.tick()
        }
        .onChange(of: engine.state.currentIndex) { _ in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .onChange(of: engine.rejectionCount) { _ in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    func slotRow(width: CGFloat) -> some View {
        let count = max(1, engine.currentScramble.count)
        let side = min(52, (width - CGFloat(count + 1) * 6) / CGFloat(count))

        return HStack(spacing: 6) {
            ForEach(Array(slotLetters.enumerated()), id: \.offset) { _, letter in
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            letter == nil
                                ? Color.secondary.opacity(0.5)
                                : palette.rightPlaceStroke,
                            lineWidth: 1.5
                        )
                    if let letter = letter {
                        Text(verbatim: letter)
                            .font(.system(size: side * 0.5, weight: .bold))
                    }
                }
                .frame(width: side, height: side)
            }
        }
        .onTapGesture {
            engine.removeLast()
        }
    }

    func circles(width: CGFloat) -> some View {
        let maxPerRow = max(1, circleRows.map(\.count).max() ?? 1)
        let side = min(64, (width - CGFloat(maxPerRow + 1) * 10) / CGFloat(maxPerRow))

        return VStack(spacing: 10) {
            ForEach(Array(circleRows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { circleIndex in
                        circleButton(circleIndex: circleIndex, side: side)
                    }
                }
            }
        }
    }

    func circleButton(circleIndex: Int, side: CGFloat) -> some View {
        let isUsed = engine.placed.contains(circleIndex)

        return Button(action: {
            engine.placeLetter(circleIndex: circleIndex)
        }) {
            ZStack {
                Circle()
                    .fill(
                        isUsed
                            ? palette.rightPlaceFill
                            : palette.wrongLetterFill.opacity(0.3)
                    )
                Text(verbatim: engine.currentScramble[circleIndex])
                    .font(.system(size: side * 0.42, weight: .bold))
                    .foregroundColor(isUsed ? .white : .primary)
            }
            .frame(width: side, height: side)
        }
        .disabled(isUsed)
    }
}
```

NOTE: before building, open `Shared/Palettes/Palette.swift` and confirm the exact property names (`rightPlaceFill`, `rightPlaceStroke`, `wrongLetterFill`). If names differ, use the actual palette properties for correct/incorrect fills - do not hardcode colors. `safeTint` is an existing helper (see its use in `NavigationList.swift`); if it does not compile on a plain Button context, use `.tint(.primary)` guarded the same way the codebase does.

- [ ] **Step 8: Register all files in pbxproj, build and test**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS, zero warnings.

- [ ] **Step 9: Commit**

```bash
git add Shared/Daily18/Daily18Storage.swift Shared/Daily18/Daily18Host.swift Shared/Daily18/Daily18GameView.swift WordlikeTests/Daily18StorageTests.swift Resources/en.lproj/Localizable.strings Resources/fr.lproj/Localizable.strings Resources/lv.lproj/Localizable.strings SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add 18 vardi storage, host flow, and gameplay views"
```

---

### Task 8: Results screen and stats view

**Files:**
- Create: `Shared/Daily18/Daily18ResultsView.swift`
- Create: `Shared/Daily18/Daily18StatsView.swift`
- Modify: `Shared/Daily18/Daily18Host.swift` (replace `Daily18ResultsPlaceholder` usage and delete the placeholder struct)
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register the two new files)
- Modify: all three `Localizable.strings`

**Interfaces:**
- Consumes: `Daily18State`, `Daily18Stats`, `Daily18Share`, `Daily18TrophyTier`, `Daily18ProgressGrid`, `TurnCounter.remainingTtl(at:)`, `ShareableString` (`Shared/Misc/ShareableString.swift`), `.safeSharingSheet(isSharing:activityItems:callback:)` (see `AppView.swift` lines 148-154 for the wrapping pattern).
- Produces: `Daily18ResultsView(state:stats:turnCounter:)`, `Daily18StatsView(stats:todayScore:)`.

- [ ] **Step 1: Add localized strings (all three files)**

en:
```
"Share score" = "Share score";
"Challenge friend" = "Challenge friend";
"Next puzzle in %@" = "Next puzzle in %@";
"Trophy streak" = "Trophy streak";
"Perfect days" = "Perfect days";
```
fr:
```
"Share score" = "Partager le score";
"Challenge friend" = "Défier un ami";
"Next puzzle in %@" = "Prochain puzzle dans %@";
"Trophy streak" = "Série de trophées";
"Perfect days" = "Jours parfaits";
```
lv:
```
"Share score" = "Dalīties ar rezultātu";
"Challenge friend" = "Izaicini draugu";
"Next puzzle in %@" = "Nākamā mīkla pēc %@";
"Trophy streak" = "Trofeju sērija";
"Perfect days" = "Perfektās dienas";
```
Check for pre-existing keys `"Played"` and `"Max streak"` (grep the en file). Add whichever are missing, with fr "Parties jouées" / "Série max" and lv "Spēlētas" / "Garākā sērija".

- [ ] **Step 2: Implement the stats view**

`Shared/Daily18/Daily18StatsView.swift`:

```swift
import SwiftUI

/// Score histogram and headline numbers, adapted from the Wordle
/// stats sheet styling (horizontal bars).
struct Daily18StatsView: View {
    let stats: Daily18Stats
    let todayScore: Int?

    @Environment(\.palette) var palette: Palette

    var headline: some View {
        HStack(alignment: .top, spacing: 24) {
            statCell(value: stats.played, caption: "Played")
            statCell(value: stats.trophyStreak, caption: "Trophy streak")
            statCell(value: stats.maxTrophyStreak, caption: "Max streak")
            statCell(value: stats.perfectDays, caption: "Perfect days")
        }
    }

    func statCell(value: Int, caption: LocalizedStringKey) -> some View {
        VStack {
            Text(verbatim: "\(value)")
                .font(.title2)
                .fontWeight(.bold)
            Text(caption)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }

    func bar(score: Int) -> some View {
        GeometryReader { proxy in
            HStack(spacing: 4) {
                Text(verbatim: "\(score)")
                    .font(.caption.monospacedDigit())
                    .frame(width: 22, alignment: .trailing)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.clear)
                    Rectangle()
                        .fill(
                            score == todayScore
                                ? palette.rightPlaceFill
                                : Color.secondary.opacity(0.5)
                        )
                        .frame(
                            width: max(
                                14,
                                (proxy.size.width - 26) * stats.widthRatio(score: score)
                            )
                        )
                        .overlay(alignment: .trailing) {
                            Text(verbatim: "\(stats.scoreDistribution[score])")
                                .font(.caption2.monospacedDigit())
                                .foregroundColor(.white)
                                .padding(.trailing, 3)
                        }
                }
            }
        }
        .frame(height: 16)
    }

    var body: some View {
        VStack(spacing: 16) {
            headline

            VStack(spacing: 3) {
                ForEach(0 ... Daily18State.wordCount, id: \.self) { score in
                    bar(score: score)
                }
            }
        }
    }
}
```

- [ ] **Step 3: Implement the results view**

`Shared/Daily18/Daily18ResultsView.swift`:

```swift
import SwiftUI

struct Daily18ResultsView: View {
    let state: Daily18State
    let stats: Daily18Stats
    let turnCounter: TurnCounter

    @State var isSharing = false
    @State var shareItems: [UIActivityItemSource] = []

    func countdownText(at now: Date) -> String {
        let remaining = max(0, Int(turnCounter.remainingTtl(at: now)))
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func share(_ text: String) {
        shareItems = [ShareableString(text)]
        isSharing = true
        Analytics.shared.trackAction(
            name: "game.shared",
            attributes: ["game_locale": Daily18Host.gameLocaleAttribute]
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Daily18ProgressGrid(marks: state.marks)
                    .frame(maxWidth: 280)

                Text(
                    String(
                        format: NSLocalizedString(
                            "You found %lld of 18 words!", comment: ""
                        ),
                        state.score
                    )
                )
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

                Text(verbatim: Daily18TrophyTier.line(forScore: state.score))
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Button(action: {
                        share(Daily18Share.scoreText(day: state.day, marks: state.marks))
                    }) {
                        Label("Share score", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        share(Daily18Share.challengeText(day: state.day, marks: state.marks))
                    }) {
                        Label("Challenge friend", systemImage: "person.2")
                    }
                    .buttonStyle(.bordered)
                }
                .disabled(isSharing)

                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(
                        String(
                            format: NSLocalizedString("Next puzzle in %@", comment: ""),
                            countdownText(at: context.date)
                        )
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                }

                Divider()

                Daily18StatsView(stats: stats, todayScore: state.score)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(
            EmptyView()
                .safeSharingSheet(
                    isSharing: $isSharing,
                    activityItems: $shareItems,
                    callback: {
                        isSharing = false
                        shareItems = []
                    }
                )
        )
    }
}
```

- [ ] **Step 4: Swap the placeholder in Daily18Host.swift**

In `Daily18FlowView`, replace:
```swift
            case .finished:
                Daily18ResultsPlaceholder(state: engine.state)
```
with:
```swift
            case .finished:
                Daily18ResultsView(
                    state: engine.state,
                    stats: stats,
                    turnCounter: turnCounter
                )
```
Delete the whole `Daily18ResultsPlaceholder` struct.

- [ ] **Step 5: Register, build, test**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS, zero warnings.

- [ ] **Step 6: Commit**

```bash
git add Shared/Daily18/Daily18ResultsView.swift Shared/Daily18/Daily18StatsView.swift Shared/Daily18/Daily18Host.swift Resources/en.lproj/Localizable.strings Resources/fr.lproj/Localizable.strings Resources/lv.lproj/Localizable.strings SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add 18 vardi results screen with sharing, countdown, and stats"
```

---

### Task 9: Main menu row for 18 vardi

**Files:**
- Create: `Shared/Daily18/Daily18Row.swift`
- Modify: `Shared/GameUI/Root/NavigationList.swift` (add the row after the locale ForEach, around line 409)
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register the new file)

**Interfaces:**
- Consumes: `Daily18Storage`, `Daily18State`, `Daily18Stats`, `TileFlag` (requires `.environment(\.gameLocale, ...)`), `LanguageRowButtonStyle`, `LazyView`, `Analytics.shared`, `AppStateStorage`.
- Produces: `Daily18Row` (menu row view), `Daily18ProgressCaption`, `Daily18StatWidget`.

- [ ] **Step 1: Implement the row**

`Shared/Daily18/Daily18Row.swift`:

```swift
import SwiftUI

/// Caption under the 18 vardi menu row title: today's status.
struct Daily18ProgressCaption: View {
    @AppStateStorage(Daily18Storage.stateKey)
    var storedState: Daily18State = Daily18State(day: -1)

    @Environment(\.palette) var palette: Palette

    var caption: (Text, Color) {
        let today = Daily18Storage.makeTurnCounter().turnIndex(at: Date())

        guard storedState.day == today, storedState.phase != .notStarted else {
            return (Text("Not started"), Color.primary)
        }

        if storedState.phase == .finished {
            return (
                Text(verbatim: "\(storedState.score)/18"),
                palette.completedUiLabel
            )
        }

        return (Text("In progress"), palette.inProgressUiLabel)
    }

    var body: some View {
        caption.0
            .font(.caption)
            .foregroundColor(caption.1)
    }
}

/// Compact trophy-streak widget for the menu row.
struct Daily18StatWidget: View {
    @AppStateStorage(Daily18Storage.statsKey)
    var stats: Daily18Stats = Daily18Stats()

    var body: some View {
        HStack {
            if stats.played > 0 {
                HStack {
                    Divider()

                    VStack {
                        Text(verbatim: "\(stats.trophyStreak) / \(stats.maxTrophyStreak)")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                        Text("Trophy streak")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .minimumScaleFactor(0.02)
    }
}

/// Menu row for the 18 vardi mode; mirrors LanguageRow's anatomy.
struct Daily18Row: View {
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                TileFlag()
                    .frame(
                        minWidth: 50,
                        maxWidth: 50,
                        minHeight: 32
                    )
                VStack(alignment: .leading) {
                    Text(verbatim: "18 vārdi")
                        .fontWeight(.bold)
                        .fixedSize()

                    Daily18ProgressCaption().fixedSize()
                }
            }

            Spacer()

            Daily18StatWidget()
                .fixedSize()

            Image(systemName: "chevron.forward")
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}
```

("Not started" and "In progress" keys already exist in all three Localizable.strings - verify with grep; add if missing.)

- [ ] **Step 2: Wire into NavigationList**

In `Shared/GameUI/Root/NavigationList.swift`, inside `innerBody`'s `VStack(spacing: 8)`, immediately AFTER the closing brace of `ForEach(Locale.supportedLocales, ...) { ... }` (after its closing `}` around line 409), insert:

```swift
                NavigationLink(destination: {
                    LazyView(
                        Daily18Host()
                            .environment(\.palette, palette)
                            .environment(\.debug, outerDebug || envDebug)
                            .padding()
                            .onAppear {
                                Analytics.shared.trackAction(
                                    name: "language.switched",
                                    attributes: [
                                        "game_locale": Daily18Host.gameLocaleAttribute,
                                    ]
                                )
                            }
                    )
                }, label: {
                    Daily18Row()
                        .environment(\.gameLocale, .lv_LV(simplified: false))
                })
                .buttonStyle(LanguageRowButtonStyle())
```

- [ ] **Step 3: Register, build, test**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS, zero warnings.

- [ ] **Step 4: Commit**

```bash
git add Shared/Daily18/Daily18Row.swift Shared/GameUI/Root/NavigationList.swift SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Add 18 vardi row to the main menu"
```

---

### Task 10: Hide non-Latvian modes and integrate aggregate share

**Files:**
- Modify: `Shared/Extensions/LocaleExtensions.swift:4-6`
- Modify: `Shared/GameUI/Root/AppView.swift:41-46` and the share callback (lines 89-133)
- Modify: `Shared/GameUI/Root/NavigationList.swift` (`Footer.isSharingDisabled`, around line 470)
- Test: `WordlikeTests/Daily18MenuTests.swift` (create)
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (register the test)

**Interfaces:**
- Consumes: `Daily18Storage.isFinishedToday()`, `Daily18Storage.storedState()`, `Daily18Share.squares(for:)`.
- Produces: Latvian-only `Locale.supportedLocales`; aggregate share line for 18 vardi.

- [ ] **Step 1: Write the failing test**

```swift
@testable import Wordlike
import XCTest

final class Daily18MenuTests: XCTestCase {
    func testOnlyLatvianModeIsListed() {
        XCTAssertEqual(Locale.supportedLocales, [.lv_LV])
    }
}
```

Run: `make test` -> FAIL (supportedLocales has 4 entries).

- [ ] **Step 2: Trim supportedLocales**

In `Shared/Extensions/LocaleExtensions.swift` replace:
```swift
    static var supportedLocales: [Locale] {
        [.en_US, .en_GB, .fr_FR, .lv_LV]
    }
```
with:
```swift
    /// Locales shown in the main menu. EN/GB/FR are hidden (not
    /// removed): their code, resources, and stats remain intact.
    static var supportedLocales: [Locale] {
        [.lv_LV]
    }
```

- [ ] **Step 3: Trim AppView.listedLocales and append the 18 vardi share line**

In `Shared/GameUI/Root/AppView.swift` replace:
```swift
    let listedLocales: [Locale] = [
        .en_US,
        .en_GB,
        .fr_FR,
        .lv_LV,
    ]
```
with:
```swift
    let listedLocales: [Locale] = [
        .lv_LV,
    ]
```

In the `shareCallback`, after the `let lines = ...` chain ends (after `.filter { $0 != nil }.map { $0! }`), replace:
```swift
                        guard !lines.isEmpty else {
                            return
                        }
```
with:
```swift
                        var allLines = lines
                        if Daily18Storage.isFinishedToday(),
                           let daily18 = Daily18Storage.storedState()
                        {
                            let squares = Daily18Share
                                .squares(for: daily18.marks)
                                .replacingOccurrences(of: "\n", with: " ")
                            allLines.append("🇱🇻 \(daily18.score)/18\t\(squares)")
                        }

                        guard !allLines.isEmpty else {
                            return
                        }
```
and in the `ShareableString` construction below, replace `+ lines` with `+ allLines`.

- [ ] **Step 4: Enable the share button when only 18 vardi is finished**

In `Shared/GameUI/Root/NavigationList.swift`, `Footer.isSharingDisabled`, insert as the FIRST statement of the computed property:
```swift
        if Daily18Storage.isFinishedToday() {
            return false
        }
```

- [ ] **Step 5: Register the test, run everything**

Run: `plutil -lint SimpleWordGame.xcodeproj/project.pbxproj` -> "OK"
Run: `make test`
Expected: PASS. If any existing test iterates `Locale.supportedLocales` and now covers fewer locales (e.g. WordListTests), that is expected behavior - do NOT restore locales; if a test hardcodes the old 4-locale list, update that test's expectation to `[.lv_LV]`.

- [ ] **Step 6: Commit**

```bash
git add Shared/Extensions/LocaleExtensions.swift Shared/GameUI/Root/AppView.swift Shared/GameUI/Root/NavigationList.swift WordlikeTests/Daily18MenuTests.swift SimpleWordGame.xcodeproj/project.pbxproj
make format && make lint
git commit -m "Hide non-Latvian modes from menu and add 18 vardi to summary share"
```

---

### Task 11: Stats export/import, final verification, version bump

**Files:**
- Modify: `Shared/GameLogic/StatsTransfer.swift`
- Test: extend `WordlikeTests/Daily18StatsTests.swift`
- Modify: `SimpleWordGame.xcodeproj/project.pbxproj` (nothing new to register; verify)

**Interfaces:**
- Consumes: `Daily18Stats`, `Daily18State`, `Daily18Storage`.
- Produces: `StatsExportDocument` gains OPTIONAL fields `daily18Stats: Daily18Stats?` and `daily18State: Daily18State?` (version stays 1; old exports decode because the fields are optional).

- [ ] **Step 1: Write the failing test (append to Daily18StatsTests.swift)**

```swift
    func testExportIncludesDaily18() {
        let stats = Daily18Stats().update(
            score: 12,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        UserDefaults.standard.set(stats.rawValue, forKey: Daily18Storage.statsKey)
        defer { UserDefaults.standard.removeObject(forKey: Daily18Storage.statsKey) }

        let document = StatsTransfer.buildExport()
        XCTAssertEqual(document.daily18Stats, stats)
    }

    func testImportRestoresDaily18Stats() throws {
        UserDefaults.standard.removeObject(forKey: Daily18Storage.statsKey)
        let stats = Daily18Stats().update(
            score: 18,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        let document = StatsExportDocument(
            version: 1,
            exportDate: "2026-07-17",
            stats: [:],
            turnStates: nil,
            daily18Stats: stats,
            daily18State: nil
        )

        try StatsTransfer.performImport(from: document)
        defer { UserDefaults.standard.removeObject(forKey: Daily18Storage.statsKey) }

        let restored = Daily18Stats(
            rawValue: UserDefaults.standard.string(forKey: Daily18Storage.statsKey) ?? ""
        )
        XCTAssertEqual(restored, stats)
    }
```

Run: `make test` -> FAIL (fields do not exist).

- [ ] **Step 2: Extend StatsTransfer**

In `Shared/GameLogic/StatsTransfer.swift`:

Change the document struct to:
```swift
struct StatsExportDocument: Codable {
    let version: Int
    let exportDate: String
    let stats: [String: ExportableStats]
    let turnStates: [String: DailyState]?
    let daily18Stats: Daily18Stats?
    let daily18State: Daily18State?
}
```

In `buildExport()`, before the `return`, add:
```swift
        var daily18Stats: Daily18Stats?
        if let raw = UserDefaults.standard.string(forKey: Daily18Storage.statsKey),
           let parsed = Daily18Stats(rawValue: raw),
           parsed.played > 0
        {
            daily18Stats = parsed
        }

        var daily18State: Daily18State?
        if let state = Daily18Storage.storedState(), state.phase == .finished {
            daily18State = state
        }
```
and change the `return` to:
```swift
        return StatsExportDocument(
            version: 1,
            exportDate: dateFormatter.string(from: Date()),
            stats: exportStats,
            turnStates: turnStates.isEmpty ? nil : turnStates,
            daily18Stats: daily18Stats,
            daily18State: daily18State
        )
```

In `performImport(from:)`, before the closing brace of the function, add:
```swift
        if let daily18Stats = document.daily18Stats {
            UserDefaults.standard.set(
                daily18Stats.rawValue,
                forKey: Daily18Storage.statsKey
            )
        }

        if let daily18State = document.daily18State,
           daily18State.day == Daily18Storage.makeTurnCounter().turnIndex(at: Date())
        {
            UserDefaults.standard.set(
                daily18State.rawValue,
                forKey: Daily18Storage.stateKey
            )
        }
```

Check whether other call sites construct `StatsExportDocument` directly (grep for `StatsExportDocument(`); update any to pass `daily18Stats: nil, daily18State: nil`.

- [ ] **Step 3: Run tests**

Run: `make test`
Expected: PASS (including `CrossPlatformImportTests` - the new fields are optional, so the web fixture without them still decodes).

- [ ] **Step 4: Full verification and version bump**

Run in order; every command must succeed:
```bash
make format
make lint
make test
make bump-minor
```

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Include 18 vardi data in stats transfer and bump minor version"
```

---

## Final self-review checklist (run after Task 11)

- All spec sections implemented: gameplay rules (Task 4), daily content (Tasks 1, 3), UI (Tasks 7-9), stats (Task 5), trophy tiers (Task 5), share (Tasks 6, 8, 10), menu hiding (Task 10), persistence (Tasks 2, 7), analytics (Tasks 7, 8, 9), StatsTransfer (Task 11), localization (Tasks 5-9), tests (all).
- `make test`, `make lint` green on the final commit; zero warnings.
- Branch contains only the planned changes; spec + plan committed.
