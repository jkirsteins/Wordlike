import SwiftUI

struct DayWord
{
    let word: String
    let day: Int
    let locale: String
}

// TODO: rename to TurnState
class GameState : ObservableObject, Identifiable, Equatable
{
    static let MAX_ROWS = 6
    
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        return lhs.isCompleted == rhs.isCompleted &&
        lhs.rows == rhs.rows
    }
    
    var id = UUID()
    
    @Published var initialized: Bool
    @Published var isTallied: Bool
    @Published var expected: DayWord
    @Published var rows: [RowModel]
    @Published var date: Date
    
    var keyboardHints: KeyboardHints {
        var result: Dictionary<String, TileBackgroundType> = [:]
        
        let submittedRows = rows.filter({$0.isSubmitted})
        
        for srow in submittedRows {
            for ix in 0..<srow.word.count {
                let state = srow.revealState(ix)
                let char = srow.char(guessAt: ix)
                
                // don't allow overriding rightPlace
                guard result[char] != .rightPlace else {
                    continue 
                }
                
                guard result[char] != state else { 
                    continue
                }
                
                guard 
                    [
                        .rightPlace, 
                        .wrongPlace,
                        .wrongLetter
                ].contains(state) else {
                    continue
                }
                
                result[char] = state
            }
        }
        
        return KeyboardHints(
            hints: result, 
            locale: expected.locale)  
    }
    
    var isWon: Bool {
        rows.first(where: { $0.isSubmitted && $0.word.uppercased() == expected.word.uppercased() }) != nil
    }
    
    var submittedRows: Int {
        rows.filter({ $0.isSubmitted }).count
    }
    
    var isExhausted: Bool {
        rows.allSatisfy { $0.isSubmitted }
    }
    
    var isCompleted: Bool {
        isWon || isExhausted 
    }
    
    convenience init(expected: DayWord) {
        let rowModels = (0..<Self.MAX_ROWS).map { _ in 
            RowModel(word: "", expected: expected.word, isSubmitted: false)
        }
        self.init(initialized: true, expected: expected, rows: rowModels, isTallied: false, date: Date())
    }
    
    convenience init() {
        self.init(initialized: false, expected: DayWord(word: "", day: 0, locale: "?"), rows: [], isTallied: false, date: Date())
    }
    
    init(initialized: Bool, expected: DayWord, rows: [RowModel], isTallied: Bool, date: Date) {
        self.initialized = initialized
        self.expected = expected
        self.isTallied = isTallied
        self.date = date
        let isActives = (0..<Self.MAX_ROWS).map { _ in
            false
        }
        self._rows = Published(wrappedValue: rows)
    }
}

struct KeyboardHintsTestInternalView: View {
    var body: some View {
        let state = GameState(initialized: true, expected: DayWord(word: "fuels", day: 1, locale: "en"), 
                  rows: [
                    RowModel(word: "abcde", expected: "fuels", isSubmitted: true, attemptCount: 0)
                  ], isTallied: true, date: Date())
        
        return Text(verbatim: "\(state.keyboardHints)")
    }
}

struct KeyboardHintsTestInternalView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardHintsTestInternalView()
    }
}

