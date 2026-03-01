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
        XCTAssertEqual(word, "ANĪSS")
    }
    
    func testFrWordOnMar1_2026() {
        let counter = DailyTurnCounter(start: WordValidator.MAR_22_2022)
        let date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let ti = counter.turnIndex(at: date, in: .current)

        let answers = WordValidator.loadAnswers(seed: 14384982345, locale: .fr_FR)
        let word = answers[ti % answers.count]
        XCTAssertEqual(word, "STORE")
    }
}
