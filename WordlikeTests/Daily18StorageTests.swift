@testable import Wordlike
import XCTest

final class Daily18StorageTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: Daily18Storage.stateKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Daily18Storage.stateKey)
        super.tearDown()
    }

    func testKeysMatchSpec() {
        XCTAssertEqual(Daily18Storage.stateKey, "daily18.lv")
        XCTAssertEqual(Daily18Storage.statsKey, "stats18.lv")
    }

    func testStoredStateRoundTrip() {
        XCTAssertNil(Daily18Storage.storedState())

        var state = Daily18State(day: 2)
        state.phase = .finished
        UserDefaults.standard.set(state.rawValue, forKey: Daily18Storage.stateKey)

        XCTAssertEqual(Daily18Storage.storedState(), state)
    }

    func testIsFinishedTodayRequiresTodayAndFinished() {
        let counter = Daily18Storage.makeTurnCounter()
        let today = counter.turnIndex(at: Date())

        var state = Daily18State(day: today)
        state.phase = .inProgress
        UserDefaults.standard.set(state.rawValue, forKey: Daily18Storage.stateKey)
        XCTAssertFalse(Daily18Storage.isFinishedToday())

        state.phase = .finished
        UserDefaults.standard.set(state.rawValue, forKey: Daily18Storage.stateKey)
        XCTAssertTrue(Daily18Storage.isFinishedToday())

        state.day = today - 1
        UserDefaults.standard.set(state.rawValue, forKey: Daily18Storage.stateKey)
        XCTAssertFalse(Daily18Storage.isFinishedToday())
    }
}
