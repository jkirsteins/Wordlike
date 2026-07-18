@testable import Wordlike
import XCTest

final class Daily18PuzzleTests: XCTestCase {
    func testStructureIs18WordsWithSpecLengths() {
        XCTAssertEqual(
            Daily18Puzzle.structure,
            [4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 8, 8]
        )
    }

    func testPuzzleIsDeterministicAndFollowsStructure() {
        let lists = Daily18PuzzleProvider.loadAnswerLists()
        let a = Daily18PuzzleProvider.puzzle(forDay: 5, lists: lists)
        let b = Daily18PuzzleProvider.puzzle(forDay: 5, lists: lists)
        let c = Daily18PuzzleProvider.puzzle(forDay: 6, lists: lists)

        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a.words, c.words)
        XCTAssertEqual(a.words.map(\.count), Daily18Puzzle.structure)
        XCTAssertEqual(a.words, a.words.map { $0.uppercased() })
    }

    func testScrambleUsesSameLettersAndHidesSolution() {
        for day in 0 ..< 50 {
            let scramble = Daily18PuzzleProvider.scramble("KAROGS", day: day, index: 3)
            XCTAssertEqual(scramble.sorted(), ["A", "G", "K", "O", "R", "S"])
            XCTAssertNotEqual(scramble.joined(), "KAROGS")
        }
    }

    func testScrambleIsDeterministic() {
        XCTAssertEqual(
            Daily18PuzzleProvider.scramble("MĀJA", day: 2, index: 0),
            Daily18PuzzleProvider.scramble("MĀJA", day: 2, index: 0)
        )
    }

    func testDictionaryContainsAnswersAndRejectsGarbage() {
        let lists = Daily18PuzzleProvider.loadAnswerLists()
        let dictionary = Daily18Dictionary.load()
        let puzzle = Daily18PuzzleProvider.puzzle(forDay: 0, lists: lists)

        for word in puzzle.words {
            XCTAssertTrue(dictionary.contains(word), "\(word) missing from acceptance dictionary")
        }
        XCTAssertFalse(dictionary.contains("QQQQ"))
    }
}
