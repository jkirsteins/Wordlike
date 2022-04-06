import SwiftUI

extension Bundle {
    var displayName: String {
        if let result = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return result 
        }
        
        if let result = object(forInfoDictionaryKey: "CFBundleName") as? String {
            return result 
        }
        
        return "Game"
    }
}

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
        
        var result = "\(Bundle.main.displayName) \(self.expected.day) \(tries)\n\n"
        
        for row in self.rows {
            guard row.isSubmitted else {
                break
            }
            
            for ix in 0..<row.wordArray.count {
                result += shareSymbol(for: row.revealState(ix)) 
            }
            
            result += "\n"
        }
        
        return result
    }
}

struct ShareSnippet: View {
    let expected: String 
    let guesses: [String] 
    let day: Int
    
    var body: some View {
        let state = GameState(
            initialized: true, 
            expected: DayWord(word: expected, day: day), 
            rows: 
                guesses.map { w in
                     RowModel(word: w, expected: expected, isSubmitted: true)
                 } 
            )
        return Text(state.shareSnippet)
    }
}

struct ShareSnippet_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
        ShareSnippet(expected: "comma", guesses: ["plain", 
                               "warms",
                               "thema",
                               "aboma",
                               "douma",
                               "momma"], day: 5)
        
        ShareSnippet(expected: "baton", guesses: ["audio", 
                                                  "toads",
                                                  "about",
                                                  "baton"], day: 2)
        }
    }
}
