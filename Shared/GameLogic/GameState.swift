import SwiftUI
import Combine

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
    @Published var keyboardHints = KeyboardHints()
    
    var cancellables = Set<AnyCancellable>()
    
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
        rows.isWon(expected: expected.word)
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
                validator: WordValidator(locale: .en_US)),
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
    
    required init(initialized: Bool, expected: TurnAnswer, rows: [RowModel], isTallied: Bool, date: Date) {
        self.initialized = initialized
        self.expected = expected
        self.isTallied = isTallied
        self.date = date
        self._rows = Published(wrappedValue: rows)
        
        /* When a row is submitted, we'll refresh
        certain properties - such as keyboard hints */
        self._rows.projectedValue
            .removeDuplicates(by: {
                $0.submittedCount == $1.submittedCount
            })
            .sink {
            newRows in
              
                self.keyboardHints = self.calculateKeyboardHints(from: newRows)
        }.store(in: &cancellables)
    }
}

