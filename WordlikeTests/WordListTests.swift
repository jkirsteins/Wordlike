import XCTest
@testable import Wordlike

final class WordListTests: XCTestCase {

    // MARK: - Unwinnable day tests (should FAIL before fix)

    func testLvWordOnDec3_2025_isPlayable() {
        let counter = DailyTurnCounter(start: WordValidator.MAR_22_2022)
        let date = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 3))!
        let ti = counter.turnIndex(at: date, in: .current)

        let answers = WordValidator.loadAnswers(seed: 14384982345, locale: .lv_LV(simplified: false))
        let word = answers[ti % answers.count]
        XCTAssertEqual(word.count, 5, "Dec 3, 2025 lv word must be 5 letters, got '\(word)'")
    }

    func testFrWordOnJun24_2023_isPlayable() {
        let counter = DailyTurnCounter(start: WordValidator.MAR_22_2022)
        let date = Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 24))!
        let ti = counter.turnIndex(at: date, in: .current)

        let answers = WordValidator.loadAnswers(seed: 14384982345, locale: .fr_FR)
        let word = answers[ti % answers.count]
        XCTAssertEqual(word.count, 5, "Jun 24, 2023 fr word must be 5 letters, got '\(word)'")
    }

    func testEnGBWordOnDec3_2025_isPlayable() {
        let counter = DailyTurnCounter(start: WordValidator.MAR_22_2022)
        let date = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 3))!
        let ti = counter.turnIndex(at: date, in: .current)

        let answers = WordValidator.loadAnswers(seed: 14384982345, locale: .en_GB)
        let word = answers[ti % answers.count]
        XCTAssertEqual(word.count, 5, "Dec 3, 2025 en_GB word must be 5 letters, got '\(word)'")
    }

    // MARK: - Snapshot tests

    func testLvWordOnMar1_2026() {
        let counter = DailyTurnCounter(start: WordValidator.MAR_22_2022)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let ti = counter.turnIndex(at: date, in: .current)

        let answers = WordValidator.loadAnswers(seed: 14384982345, locale: .lv_LV(simplified: false))
        let word = answers[ti % answers.count]
        XCTAssertEqual(word, "KOPNE")
    }
    
    func testFrWordOnMar1_2026() {
        let counter = DailyTurnCounter(start: WordValidator.MAR_22_2022)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let ti = counter.turnIndex(at: date, in: .current)

        let answers = WordValidator.loadAnswers(seed: 14384982345, locale: .fr_FR)
        let word = answers[ti % answers.count]
        XCTAssertEqual(word, "PLOMB")
    }

    // MARK: - Generational word list tests

    func testGen1WordsAppearAfterGen0() {
        let answers = WordValidator.loadAnswers(seed: 14384982345, locale: .lv_LV(simplified: false))
        let gen0Raw = WordValidator.loadRaw("lv_A")

        // Gen 1 words should appear after all gen 0 (raw) entries
        XCTAssertTrue(answers.count > gen0Raw.count,
                       "With gen 1 file present, total answers (\(answers.count)) must exceed gen 0 count (\(gen0Raw.count))")

        // Gen 1 words should be in the tail
        let gen1 = WordValidator.load("lv_A_1")
        let tail = Set(answers.suffix(gen1.count))
        let gen1Set = Set(gen1)
        XCTAssertEqual(gen1Set, tail, "Last \(gen1.count) answers should be gen 1 words")
    }

    func testGen0OrderUnchangedWithGen1Present() {
        // loadAnswers uses loadRaw for gen 0, so we must match that
        let gen0Raw = WordValidator.loadRaw("lv_A")
        var rng = ArbitraryRandomNumberGenerator(seed: UInt64(14384982345))
        var gen0Shuffled = gen0Raw.shuffled(using: &rng)

        // Replicate the empty-replacement logic
        let validWords = gen0Shuffled.filter { !$0.isEmpty }
        for i in gen0Shuffled.indices where gen0Shuffled[i].isEmpty {
            gen0Shuffled[i] = validWords[i % validWords.count]
        }

        let allAnswers = WordValidator.loadAnswers(seed: 14384982345, locale: .lv_LV(simplified: false))
        let prefix = Array(allAnswers.prefix(gen0Raw.count))

        XCTAssertEqual(prefix, gen0Shuffled, "Gen 0 order must be identical whether or not gen 1 is present")
    }
}
