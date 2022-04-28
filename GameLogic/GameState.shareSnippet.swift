import SwiftUI

/// Extension that contains the logic for generating
/// the shareable snippet of a finished round.
extension GameState
{
    public func shareSymbol(for revealState: TileBackgroundType?) -> String {
        switch(revealState) {
        case .rightPlace:
            return "🟩"
        case .wrongPlace:
            return "🟨"
        default:
            return "⬛"
        }
    }
    
    public func shareSnippet(hard: Bool, additional: String?) -> String {
        
        var tries: String
        if isWon {
            tries = "\(self.submittedRows)/6"
        } else {
            tries = "X/6"
        }
        
        if hard {
            tries = "\(tries)*"
        }
        
        if let add = additional {
            tries = "\(tries)\(add)"
        }
        
        let flag: String 
        switch(self.expected.locale) {
            case .en_US:
            flag = "🇺🇸"
            case .en_GB:
            flag = "🇬🇧"
            case .fr_FR:
            flag = "🇫🇷"
            case .lv_LV(_):
            flag = "🇱🇻"
            case .unknown:
            flag = ""
        }
        
        var result = "\(Bundle.main.displayName) \(flag) \(self.expected.day) \(tries)\n\n"
        
        var rowValues: [String] = []
        for row in self.rows {
            var result = ""
            guard row.isSubmitted else {
                break
            }
            
            for ix in 0..<row.wordArray.count {
                result += shareSymbol(for: row.revealState(ix)) 
            }
            
            rowValues.append(result) 
        }
        
        result += rowValues.joined(separator: "\n")
        
        return result
    }
}

struct Internal_ShareSnippet_Test: View {
    let expected: String 
    let guesses: [String] 
    let day: Int
    let validator = WordValidator(locale: .en_US)
    let hard: Bool 
    let additional: String?
    
    var body: some View {
        let state = GameState(
            initialized: true, 
            expected: TurnAnswer(word: expected, day: day, locale: .en_US, validator: validator), 
            rows: 
                guesses.map { w in
                    RowModel(word: w, expected: expected, isSubmitted: true)
                },
            isTallied: false,
            date: Date() 
        )
        return Text(state.shareSnippet(hard: hard, additional: additional))
    }
}

struct Internal_ShareSnippet_Test_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Internal_ShareSnippet_Test(
                expected: "comma", 
                guesses: ["plain", 
                          "warms",
                          "thema",
                          "aboma",
                          "douma",
                          "momma"], 
                day: 5,
                hard: true,
                additional: nil)
                .border(.red)
            
            Internal_ShareSnippet_Test(
                expected: "baton", 
                guesses: ["audio", 
                          "toads",
                          "about",
                          "baton"], 
                day: 2,
                hard: false,
                additional: "^")
                .border(.red)
        }
    }
}
