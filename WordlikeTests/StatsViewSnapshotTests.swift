import SnapshotTesting
import SwiftUI
@testable import Wordlike
import XCTest

final class StatsViewSnapshotTests: XCTestCase {
    /// Lost game: all 6 rows submitted, none matching expected.
    /// isCompleted == true (shows answer + link), isWon == false (no confetti).
    private static let lostState = GameState(
        initialized: true,
        expected: TurnAnswer(word: "fuels", day: 2, locale: .en_US),
        rows: [
            RowModel(
                word: WordModel("clear", locale: .en_US),
                expected: WordModel("fuels", locale: .en_US),
                isSubmitted: true
            ),
            RowModel(
                word: WordModel("duels", locale: .en_US),
                expected: WordModel("fuels", locale: .en_US),
                isSubmitted: true
            ),
            RowModel(
                word: WordModel("deals", locale: .en_US),
                expected: WordModel("fuels", locale: .en_US),
                isSubmitted: true
            ),
            RowModel(
                word: WordModel("fouls", locale: .en_US),
                expected: WordModel("fuels", locale: .en_US),
                isSubmitted: true
            ),
            RowModel(
                word: WordModel("feels", locale: .en_US),
                expected: WordModel("fuels", locale: .en_US),
                isSubmitted: true
            ),
            RowModel(
                word: WordModel("fulls", locale: .en_US),
                expected: WordModel("fuels", locale: .en_US),
                isSubmitted: true
            ),
        ],
        isTallied: false,
        date: Date(timeIntervalSince1970: 0)
    )

    private static let sampleStats = Stats(
        played: 10, won: 7, maxStreak: 5, streak: 0,
        guessDistribution: [0, 1, 3, 2, 1, 0], lastWinAt: nil
    )

    /// Noon UTC on a fixed date - gives a deterministic 12:00:00 countdown.
    private static let fixedNoon: Date = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal.date(
            from: DateComponents(year: 2025, month: 6, day: 15, hour: 12)
        )!
    }()

    private static let utcTurnCounter: TurnCounter = CalendarDailyTurnCounter(
        start: WordValidator.MAR_22_2022,
        cal: .gregorianUtc
    )

    @MainActor
    func testStatsViewAfterLoss() {
        let view = StatsView(stats: Self.sampleStats, state: Self.lostState)
            .environment(\.palette, LightPalette2())
            .environment(\.turnCounter, Self.utcTurnCounter)
            .environment(\.now) { Self.fixedNoon }
            .environment(\.locale, .init(identifier: "en_US"))

        let hc = UIHostingController(rootView: view)
        hc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 700)

        assertSnapshot(
            of: hc,
            as: .image(precision: 0.99, size: CGSize(width: 390, height: 700))
        )
    }
}
