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
            day: 1,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        XCTAssertEqual(updated.played, 1)
        XCTAssertEqual(updated.trophyStreak, 1)
        XCTAssertEqual(updated.maxTrophyStreak, 1)
        XCTAssertEqual(updated.scoreDistribution[10], 1)
        XCTAssertEqual(updated.perfectDays, 0)
        XCTAssertNotNil(updated.lastTrophyAt)
        // Guards against double-tallying the same day if the process dies
        // between updating stats and marking the engine state tallied.
        XCTAssertEqual(updated.lastTalliedDay, 1)
    }

    func testConsecutiveTrophyDaysExtendStreak() {
        let first = Daily18Stats().update(
            score: 9,
            day: 1,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        let second = first.update(
            score: 18,
            day: 2,
            finishedAt: Date(timeIntervalSince1970: 150),
            with: counter
        )
        XCTAssertEqual(second.trophyStreak, 2)
        XCTAssertEqual(second.maxTrophyStreak, 2)
        XCTAssertEqual(second.perfectDays, 1)
        XCTAssertEqual(second.lastTalliedDay, 2)
    }

    func testGapResetsStreak() {
        let first = Daily18Stats().update(
            score: 9,
            day: 1,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        let afterGap = first.update(
            score: 12,
            day: 4,
            finishedAt: Date(timeIntervalSince1970: 350),
            with: counter
        )
        XCTAssertEqual(afterGap.trophyStreak, 1)
        XCTAssertEqual(afterGap.maxTrophyStreak, 1)
    }

    func testSubTrophyScoreBreaksStreakButCounts() {
        let first = Daily18Stats().update(
            score: 9,
            day: 1,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        let second = first.update(
            score: 5,
            day: 2,
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
            day: 1,
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

    func testExportIncludesDaily18() {
        let stats = Daily18Stats().update(
            score: 12,
            day: 1,
            finishedAt: Date(timeIntervalSince1970: 50),
            with: counter
        )
        UserDefaults.standard.set(stats.rawValue, forKey: Daily18Storage.statsKey)
        defer { UserDefaults.standard.removeObject(forKey: Daily18Storage.statsKey) }

        let document = StatsTransfer.buildExport()
        XCTAssertEqual(document.daily18Stats, stats)
    }

    /// Regression test: `StatsTransfer.buildExport()` must include hidden
    /// (EN/GB/FR) Wordle stats, not just the menu-visible LV locale.
    func testExportIncludesHiddenEnLocaleStats() {
        let stats = Stats(
            played: 3,
            won: 2,
            maxStreak: 1,
            streak: 1,
            guessDistribution: [0, 1, 1, 0, 0, 0],
            lastWinAt: nil
        )
        UserDefaults.standard.set(stats.rawValue, forKey: "stats.en")
        defer { UserDefaults.standard.removeObject(forKey: "stats.en") }

        let document = StatsTransfer.buildExport()
        XCTAssertNotNil(document.stats["en"])
    }

    func testImportRestoresDaily18Stats() throws {
        UserDefaults.standard.removeObject(forKey: Daily18Storage.statsKey)
        let stats = Daily18Stats().update(
            score: 18,
            day: 1,
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
}
