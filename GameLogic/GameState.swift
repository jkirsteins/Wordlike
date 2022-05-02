import SwiftUI

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
    @Published var expected: TurnAnswer
    @Published var rows: [RowModel]
    @Published var date: Date
    
    /// Index of the editable row
    var activeIx: Int? {
        for i in 0..<rows.count {
            if !rows[i].isSubmitted {
                return i
            }
        }
        
        return nil 
    }
    
    var isWon: Bool {
        rows.first(where: {
            $0.isSubmitted && $0.word == expected.word 
        }) != nil
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
    
    /// Initializes with mostly dummy values and
    /// `ìnitialized` set to false. This is to
    /// make it possible to create the initial GameState
    /// as a StateObject (which doesn't work well with
    /// optionals).
    convenience init() {
        self.init(
            initialized: false, 
            expected: TurnAnswer(
                word: WordModel("", locale: .current), 
                day: 0, 
                locale: .unknown, 
                validator: DummyValidator()),
            rows: [], 
            isTallied: false, 
            date: Date())
    }
    
    convenience init(expected: TurnAnswer) {
        let rowModels = (0..<Self.MAX_ROWS).map { _ in 
            RowModel(word: WordModel(), expected: expected.word, isSubmitted: false)
        }
        self.init(initialized: true, expected: expected, rows: rowModels, isTallied: false, date: Date())
    }
    
    init(initialized: Bool, expected: TurnAnswer, rows: [RowModel], isTallied: Bool, date: Date) {
        self.initialized = initialized
        self.expected = expected
        self.isTallied = isTallied
        self.date = date
        self._rows = Published(wrappedValue: rows)
    }
}

