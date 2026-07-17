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
}
