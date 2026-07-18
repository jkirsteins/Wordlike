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
