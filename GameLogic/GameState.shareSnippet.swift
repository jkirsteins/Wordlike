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
    
    public var shareSnippet: String {
        
        let tries: String
        if isWon {
            tries = "\(self.submittedRows)/6"
        } else {
            tries = "X/6"
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
        return Text(state.shareSnippet)
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
                day: 5)
                .border(.red)
            
            Internal_ShareSnippet_Test(
                expected: "baton", 
                guesses: ["audio", 
                          "toads",
                          "about",
                          "baton"], 
                day: 2)
                .border(.red)
        }
    }
}
