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
