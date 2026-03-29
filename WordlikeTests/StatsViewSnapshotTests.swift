import SnapshotTesting
import SwiftUI
@testable import Wordlike
import XCTest

private struct FixedTurnCounter: TurnCounter {
    func remainingTtl(at now: Date) -> TimeInterval {
        3600
    }

    func point(_ first: Date, isInPrecedingPeriodFrom second: Date) -> Bool {
        false
    }

    func isFresh(_ stateRef: Date, at now: Date) -> Bool {
        true
    }

    func turnIndex(at now: Date) -> Int {
        0
    }
}

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
        date: Date()
    )

    private static let sampleStats = Stats(
        played: 10, won: 7, maxStreak: 5, streak: 0,
        guessDistribution: [0, 1, 3, 2, 1, 0], lastWinAt: nil
    )

    @MainActor
    func testStatsViewAfterLoss() {
        let view = StatsView(stats: Self.sampleStats, state: Self.lostState)
            .environment(\.palette, LightPalette2())
            .environment(\.turnCounter, FixedTurnCounter())
            .environment(\.locale, .init(identifier: "en_US"))

        let hc = UIHostingController(rootView: view)
        hc.view.frame = CGRect(x: 0, y: 0, width: 390, height: 700)

        assertSnapshot(
            of: hc,
            as: .image(precision: 0.99, size: CGSize(width: 390, height: 700))
        )
    }
}
