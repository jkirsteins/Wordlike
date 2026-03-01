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
        let gen0 = WordValidator.load("lv_A")

        // Gen 1 words should appear after all gen 0 words
        XCTAssertTrue(answers.count > gen0.count,
                       "With gen 1 file present, total answers (\(answers.count)) must exceed gen 0 count (\(gen0.count))")

        // The first gen0.count entries should be exactly the gen 0 words (shuffled)
        let gen0Set = Set(gen0)
        let headSet = Set(answers.prefix(gen0.count))
        XCTAssertEqual(gen0Set, headSet, "First \(gen0.count) answers should be gen 0 words")
    }

    func testGen0OrderUnchangedWithGen1Present() {
        // Loading with only gen 0 should produce the same prefix as loading with gen 0 + gen 1
        let gen0Only = WordValidator.load("lv_A")
        var rng = ArbitraryRandomNumberGenerator(seed: UInt64(14384982345))
        let gen0Shuffled = gen0Only.shuffled(using: &rng)

        let allAnswers = WordValidator.loadAnswers(seed: 14384982345, locale: .lv_LV(simplified: false))
        let prefix = Array(allAnswers.prefix(gen0Only.count))

        XCTAssertEqual(prefix, gen0Shuffled, "Gen 0 order must be identical whether or not gen 1 is present")
    }
}
