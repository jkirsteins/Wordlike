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
