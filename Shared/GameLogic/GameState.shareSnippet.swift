import SwiftUI

extension Optional where Wrapped == TileBackgroundType {
    var shareSymbol: String {
        if let wrappedVal = self {
            return wrappedVal.shareSymbol
        }
        
        return "⬛"
    }
}

extension TileBackgroundType {
    var shareSymbol: String {
        switch(self) {
        case .rightPlace:
            return "🟩"
        case .wrongPlace:
            return "🟨"
        default:
            return "⬛"
        }
    }
}

/// Extension that contains the logic for generating
/// the shareable snippet of a finished round.
extension GameState
{
    public func shareSymbol(for revealState: TileBackgroundType?) -> String {
        return revealState.shareSymbol
    }
    
    public func shareSnippet(hideFirstRow: Bool) -> String {
        
        var rowValues: [String] = []
        
        var isFirst = true
        for row in self.rows {
            var result = ""
            guard row.isSubmitted else {
                break
            }
            
            // add expected from this row as 2nd step
            for ix in 0..<row.word.count {
                let rs = row.revealState(ix)
                result += shareSymbol(for: rs) 
            }
            
            if self.submittedRows > 1 && isFirst && hideFirstRow {
                result = String(repeating: "⬜️", count: 5)
            }
            
            isFirst = false
            rowValues.append(result) 
        }
        
        var tries: String
        if isWon {
            tries = "\(self.submittedRows)/6"
        } else {
            tries = "X/6"
        }
        
        if rows.checkHardMode(expected: self.expected.word) {
            tries = "\(tries)*"
        }
        
        let flag: String = self.expected.locale.flag
        
        var result = "\(Bundle.main.displayName) \(flag) \(self.expected.day) \(tries)\n\n"
        
        result += rowValues.joined(separator: "\n")
        
        /* Add a last newline, in case sharer wants
        to add a comment (so it's not on the same line by 
        default */
        return result + "\n"
    }
}

struct Internal_ShareSnippet_Test: View {
    let comment: String
    let expected: String 
    let guesses: [String] 
    let day: Int
    let validator = WordValidator(locale: .en_US)
    var hideFirstRow = false
    
    var body: some View {
        let state = GameState(
            initialized: true, 
            expected: TurnAnswer(
                word: WordModel(expected, locale: .en_US), 
                day: day, 
                locale: .en_US, 
                validator: validator), 
            rows: 
                guesses.map { w in
                    RowModel(
                        word: w, 
                        expected: expected, 
                        isSubmitted: true, 
                        locale: .en_US)
                },
            isTallied: false,
            date: Date() 
        )
        return VStack {
            Text(comment)
            Text(state.shareSnippet(hideFirstRow: hideFirstRow))
        }
    }
}

struct Internal_ShareSnippet_Test_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Internal_ShareSnippet_Test(
                comment: "Should not hide first row",
                expected: "comma",
                guesses: ["plain",
                          "comma"],
                day: 5,
                hideFirstRow: false)
                .border(.red)
            
            Internal_ShareSnippet_Test(
                comment: "Should hide first row",
                expected: "comma",
                guesses: ["plain",
                          "comma"],
                day: 5,
                hideFirstRow: true)
                .border(.red)
            
            Internal_ShareSnippet_Test(
                comment: "Should not hide first row when only one row available",
                expected: "comma",
                guesses: ["comma"],
                day: 5,
                hideFirstRow: true)
                .border(.red)
            
            Internal_ShareSnippet_Test(
                comment: "Should have asterisk (hard mode)",
                expected: "comma", 
                guesses: ["plain", 
                          "warms",
                          "thema",
                          "aboma",
                          "douma",
                          "momma"], 
                day: 5)
                .border(.red)
            
            Internal_ShareSnippet_Test(
                comment: "No hard mode (missing 'a' on second guess)",
                expected: "baton", 
                guesses: [
                    "leaps",
                    "fuels",
                    "baton"
                ], 
                day: 2)
                .border(.red)
            
            Internal_ShareSnippet_Test(
                comment: "No hard mode (incorrect rightPlace)",
                expected: "baton", 
                guesses: ["balts", 
                          "toads",
                          "baton"], 
                day: 2)
                .border(.red)
        }
    }
}
