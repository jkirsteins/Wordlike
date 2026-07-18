@testable import Wordlike
import XCTest

final class Daily18EngineTests: XCTestCase {
    /// Two tiny words keep tests readable; the engine does not
    /// depend on the full 18-slot structure.
    private func makeEngine(accepted: Set<String> = []) -> Daily18Engine {
        var state = Daily18State(day: 0)
        state.marks = Array(repeating: .pending, count: 2)
        let puzzle = Daily18Puzzle(
            words: ["SALA", "MĀJA"],
            scrambles: [["L", "A", "S", "A"], ["A", "M", "J", "Ā"]]
        )
        return Daily18Engine(
            puzzle: puzzle,
            state: state,
            isAccepted: { accepted.contains($0) }
        )
    }

    private func place(_ engine: Daily18Engine, _ word: String) {
        for letter in word.map(String.init) {
            let scramble = engine.currentScramble
            let index = scramble.indices.first {
                scramble[$0] == letter && !engine.placed.contains($0)
            }!
            engine.placeLetter(circleIndex: index)
        }
    }

    func testStartTransitionsToInProgress() {
        let engine = makeEngine()
        XCTAssertEqual(engine.state.phase, .notStarted)
        engine.start()
        XCTAssertEqual(engine.state.phase, .inProgress)
        XCTAssertNotNil(engine.state.firstPlayedAt)
    }

    func testSolvingTargetAdvancesWithFreshTimer() {
        let engine = makeEngine()
        engine.start()
        engine.tick()
        place(engine, "SALA")
        XCTAssertEqual(engine.state.marks[0], .solved)
        XCTAssertEqual(engine.state.currentIndex, 1)
        XCTAssertEqual(engine.state.remainingSeconds, Daily18State.timePerWord)
        XCTAssertTrue(engine.placed.isEmpty)
    }

    func testDictionaryAnagramIsAccepted() {
        let engine = makeEngine(accepted: ["ALAS"])
        engine.start()
        place(engine, "ALAS")
        XCTAssertEqual(engine.state.marks[0], .solved)
    }

    func testRejectionClearsPlacementAndCounts() {
        let engine = makeEngine()
        engine.start()
        place(engine, "ASAL")
        XCTAssertEqual(engine.state.marks[0], .pending)
        XCTAssertTrue(engine.placed.isEmpty)
        XCTAssertEqual(engine.rejectionCount, 1)
        XCTAssertEqual(engine.state.currentIndex, 0)
    }

    func testRemoveLastUndoesPlacement() {
        let engine = makeEngine()
        engine.start()
        engine.placeLetter(circleIndex: 2)
        engine.placeLetter(circleIndex: 1)
        engine.removeLast()
        XCTAssertEqual(engine.placed, [2])
    }

    func testDuplicateCircleCannotBePlacedTwice() {
        let engine = makeEngine()
        engine.start()
        engine.placeLetter(circleIndex: 1)
        engine.placeLetter(circleIndex: 1)
        XCTAssertEqual(engine.placed, [1])
    }

    func testTimeoutFailsWordAndRevealsBeforeAdvancing() {
        let engine = makeEngine()
        engine.start()
        for _ in 0 ..< Daily18State.timePerWord {
            engine.tick()
        }
        XCTAssertEqual(engine.state.marks[0], .failed)
        XCTAssertTrue(engine.isRevealing)
        XCTAssertEqual(engine.state.currentIndex, 0)

        for _ in 0 ..< Daily18Engine.revealDuration {
            engine.tick()
        }
        XCTAssertFalse(engine.isRevealing)
        XCTAssertEqual(engine.state.currentIndex, 1)
        XCTAssertEqual(engine.state.remainingSeconds, Daily18State.timePerWord)
    }

    func testInputIgnoredDuringReveal() {
        let engine = makeEngine()
        engine.start()
        for _ in 0 ..< Daily18State.timePerWord {
            engine.tick()
        }
        XCTAssertTrue(engine.isRevealing)

        engine.placeLetter(circleIndex: 0)
        XCTAssertTrue(engine.placed.isEmpty)
        engine.removeLast()
        XCTAssertTrue(engine.placed.isEmpty)
    }

    func testTimeoutOnLastWordRevealsThenFinishes() {
        let engine = makeEngine()
        engine.start()
        place(engine, "SALA")
        for _ in 0 ..< Daily18State.timePerWord {
            engine.tick()
        }
        XCTAssertTrue(engine.isRevealing)
        XCTAssertEqual(engine.state.phase, .inProgress)

        for _ in 0 ..< Daily18Engine.revealDuration {
            engine.tick()
        }
        XCTAssertEqual(engine.state.phase, .finished)
        XCTAssertEqual(engine.state.score, 1)
    }

    func testResumeAfterDeathMidRevealRevealsAgainThenAdvances() {
        // Simulates process death during the reveal: the persisted state
        // has the failed mark and an expired timer, but currentIndex has
        // not advanced yet. A fresh engine must not get stuck.
        var state = Daily18State(day: 0)
        state.marks = Array(repeating: .pending, count: 2)
        state.phase = .inProgress
        state.marks[0] = .failed
        state.remainingSeconds = 0
        let puzzle = Daily18Puzzle(
            words: ["SALA", "MĀJA"],
            scrambles: [["L", "A", "S", "A"], ["A", "M", "J", "Ā"]]
        )
        let engine = Daily18Engine(
            puzzle: puzzle,
            state: state,
            isAccepted: { _ in false }
        )

        for _ in 0 ..< (1 + Daily18Engine.revealDuration) {
            engine.tick()
        }
        XCTAssertEqual(engine.state.currentIndex, 1)
        XCTAssertEqual(engine.state.remainingSeconds, Daily18State.timePerWord)
    }

    func testFinishingLastWordEndsRun() {
        let engine = makeEngine()
        engine.start()
        place(engine, "SALA")
        place(engine, "MĀJA")
        XCTAssertEqual(engine.state.phase, .finished)
        XCTAssertNotNil(engine.state.finishedAt)
        XCTAssertEqual(engine.state.score, 2)
    }

    func testTickIgnoredWhenNotInProgress() {
        let engine = makeEngine()
        engine.tick()
        XCTAssertEqual(engine.state.remainingSeconds, Daily18State.timePerWord)
    }
}
