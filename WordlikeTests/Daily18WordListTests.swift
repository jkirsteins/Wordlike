@testable import Wordlike
import XCTest

final class Daily18WordListTests: XCTestCase {
    static let latvianLowercase = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvzāčēģīķļņšūž")
    static let minimumAnswerCounts = [4: 300, 5: 500, 6: 600, 7: 400, 8: 300]

    private func lines(of resource: String) throws -> [String] {
        let url = try XCTUnwrap(
            Bundle.main.url(forResource: resource, withExtension: "txt"),
            "Missing resource \(resource).txt"
        )
        let text = try String(contentsOf: url, encoding: .utf8)
        return text.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    func testAnswerListsAreValid() throws {
        for length in 4 ... 8 {
            let words = try lines(of: "lv18_A\(length)")
            XCTAssertGreaterThanOrEqual(
                words.count,
                try XCTUnwrap(Self.minimumAnswerCounts[length]),
                "lv18_A\(length) below minimum"
            )
            for word in words {
                XCTAssertEqual(word.count, length, "\(word) has wrong length in lv18_A\(length)")
                XCTAssertTrue(
                    word.unicodeScalars.allSatisfy { Self.latvianLowercase.contains($0) },
                    "\(word) has invalid characters in lv18_A\(length)"
                )
            }
            XCTAssertEqual(words.count, Set(words).count, "lv18_A\(length) has duplicates")
        }
    }

    func testAnswersAreSubsetOfAcceptance() throws {
        for length in 4 ... 8 {
            let answers = try Set(lines(of: "lv18_A\(length)"))
            let accepted = try Set(lines(of: "lv18_D\(length)"))
            XCTAssertTrue(
                answers.isSubset(of: accepted),
                "lv18_A\(length) contains words missing from lv18_D\(length): \(answers.subtracting(accepted).prefix(5))"
            )
        }
    }
}
