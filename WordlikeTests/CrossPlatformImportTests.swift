@testable import Wordlike
import XCTest

/// Cross-platform parity: prove the iOS side can correctly import a JSON
/// blob produced by the wordlike-web `webDailyStateToIos` exporter.
///
/// The fixture below was emitted by running
/// `wordlike-web/src/game/iosDailyState.ts -> webDailyStateToIos(...)` for a
/// known web DailyState (PLOMB on 2026-03-01, two submitted rows: CRANE,
/// PLUMB). Re-run the emitter script in the web repo and overwrite this
/// literal if the web export schema ever changes.
///
/// This test deliberately probes only fields that *should* round-trip across
/// both encoders, so it documents parity contract rather than implementation
/// details of either side.
final class CrossPlatformImportTests: XCTestCase {
    /// Recreate the wire bytes that wordlike-web's `webDailyStateToIos`
    /// produces for a known input (PLOMB on 2026-03-01, two submitted
    /// rows: CRANE then PLUMB). Reproduce by running the equivalent
    /// emit script in the wordlike-web repo.
    private static func webEmittedJsonString() -> String {
        func mcm(_ disp: String) -> String {
            let val = disp.lowercased()
            return "{\"values\":[{\"displayValue\":\"\(disp)\"," +
                "\"value\":\"\(val)\"," +
                "\"locale\":{\"current\":0,\"identifier\":\"fr_FR\"}}]}"
        }
        func wordModel(_ letters: String) -> String {
            "{\"word\":[" +
                letters.map { mcm(String($0)) }.joined(separator: ",") +
                "]}"
        }
        let plomb = wordModel("PLOMB")
        func row(_ id: String, _ guess: String, _ submitted: Bool) -> String {
            "{\"id\":\"\(id)\"," +
                "\"word\":\(wordModel(guess))," +
                "\"isSubmitted\":\(submitted)," +
                "\"attemptCount\":0," +
                "\"expected\":\(plomb)}"
        }
        let rows = [
            row("CRANE-PLOMB", "CRANE", true),
            row("PLUMB-PLOMB", "PLUMB", true),
            row("-PLOMB", "", false),
            row("-PLOMB", "", false),
            row("-PLOMB", "", false),
            row("-PLOMB", "", false),
        ].joined(separator: ",")
        return "{\"expected\":\(plomb)," +
            "\"date\":794055600," +
            "\"rows\":[\(rows)]," +
            "\"state\":\"inProgress\"}"
    }

    private func decode() throws -> DailyState {
        let json = Self.webEmittedJsonString()
        let data = try XCTUnwrap(json.data(using: .utf8))
        return try JSONDecoder().decode(DailyState.self, from: data)
    }

    func testDecodesWithoutThrowing() throws {
        XCTAssertNoThrow(try decode())
    }

    func testRecoversAnswerLetters() throws {
        let state = try decode()
        let letters = state.expected.word.compactMap { $0.values.first?.displayValue }.joined()
        XCTAssertEqual(letters, "PLOMB")
    }

    func testRecoversDateAs2026_03_01_inLocalCalendar() throws {
        let state = try decode()
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.year, .month, .day], from: state.date)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 3)
        XCTAssertEqual(comps.day, 1)
    }

    func testRecoversSixRowsWithCorrectSubmissionFlags() throws {
        let state = try decode()
        XCTAssertEqual(state.rows.count, 6)
        XCTAssertEqual(state.rows[0].isSubmitted, true)
        XCTAssertEqual(state.rows[1].isSubmitted, true)
        for i in 2 ..< 6 {
            XCTAssertEqual(state.rows[i].isSubmitted, false, "row \(i) should be unsubmitted")
        }
    }

    func testRecoversFirstSubmittedRowAsCrane() throws {
        let state = try decode()
        let letters = state.rows[0].word.word.compactMap { $0.values.first?.displayValue }.joined()
        XCTAssertEqual(letters, "CRANE")
    }

    func testRecoversSecondSubmittedRowAsPlumb() throws {
        let state = try decode()
        let letters = state.rows[1].word.word.compactMap { $0.values.first?.displayValue }.joined()
        XCTAssertEqual(letters, "PLUMB")
    }
}
