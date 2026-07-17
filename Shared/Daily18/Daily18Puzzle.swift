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
