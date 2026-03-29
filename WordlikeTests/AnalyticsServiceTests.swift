import Foundation
@testable import Wordlike
import XCTest

final class AnalyticsServiceTests: XCTestCase {
    func testMockRecordsActions() {
        let mock = MockAnalyticsService()
        mock.trackAction(name: "test.action", attributes: ["key": "value"])
        XCTAssertEqual(mock.trackedActions.count, 1)
        XCTAssertEqual(mock.trackedActions[0].name, "test.action")
        XCTAssertEqual(mock.trackedActions[0].attributes["key"] as? String, "value")
    }

    func testMockRecordsErrors() {
        let mock = MockAnalyticsService()
        mock.trackError(message: "Something failed", source: "test", attributes: ["code": "500"])
        XCTAssertEqual(mock.trackedErrors.count, 1)
        XCTAssertEqual(mock.trackedErrors[0].message, "Something failed")
        XCTAssertEqual(mock.trackedErrors[0].source, "test")
        XCTAssertEqual(mock.trackedErrors[0].attributes["code"] as? String, "500")
    }

    func testHasActionHelper() {
        let mock = MockAnalyticsService()
        mock.trackAction(name: "game.won", attributes: [:])
        XCTAssert(mock.hasAction(named: "game.won"))
        XCTAssertFalse(mock.hasAction(named: "game.lost"))
    }

    func testNoOpConforms() {
        let noop = NoOpAnalyticsService()
        noop.trackAction(name: "test", attributes: [:])
        noop.trackError(message: "test", source: "test", attributes: [:])
    }
}
