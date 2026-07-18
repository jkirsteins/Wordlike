import Foundation

/// Builds the share sheet texts, cloning the 18words.com format.
enum Daily18Share {
    static func squares(for marks: [Daily18Mark]) -> String {
        stride(from: 0, to: marks.count, by: 6).map { start in
            marks[start ..< min(start + 6, marks.count)]
                .map { $0 == .solved ? "🟩" : "🟥" }
                .joined()
        }.joined(separator: "\n")
    }

    static func scoreText(day: Int, marks: [Daily18Mark]) -> String {
        text(
            day: day,
            marks: marks,
            footer: Daily18TrophyTier.line(forScore: score(of: marks))
        )
    }

    static func challengeText(day: Int, marks: [Daily18Mark]) -> String {
        text(
            day: day,
            marks: marks,
            footer: NSLocalizedString("Can you beat my score?", comment: "") + " 🫵"
        )
    }

    private static func score(of marks: [Daily18Mark]) -> Int {
        marks.filter { $0 == .solved }.count
    }

    private static func text(day: Int, marks: [Daily18Mark], footer: String) -> String {
        let scoreLine = String(
            format: NSLocalizedString("%lld/18 words found", comment: ""),
            score(of: marks)
        )

        return [
            "18 vārdi #\(day + 1)",
            "",
            scoreLine,
            "",
            squares(for: marks),
            "",
            footer,
        ].joined(separator: "\n") + "\n"
    }
}
