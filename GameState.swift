import SwiftUI

class GameState : ObservableObject, Identifiable, Equatable
{
    static func == (lhs: GameState, rhs: GameState) -> Bool {
        return
        lhs.isCompleted == rhs.isCompleted &&
        lhs.rows == rhs.rows
    }
    
    var id = UUID()
    
    @Published var initialized: Bool
    
    @Published var expected: String
    @Published var rows: [RowModel]
    
    var isWon: Bool {
        rows.first(where: { $0.isSubmitted && $0.word == expected }) != nil
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
    
    convenience init(expected: String) {
        let rowModels = (0..<5).map { _ in 
            RowModel(word: "", expected: expected, isSubmitted: false)
        }
        self.init(initialized: true, expected: expected, rows: rowModels)
    }
    
    convenience init() {
        self.init(initialized: false, expected: "", rows: [])
    }
    
    init(initialized: Bool, expected: String, rows: [RowModel]) {
        self.initialized = initialized
        self.expected = expected
        
        let maxIx = 5
//        let rowModels = (0..<maxIx).map { _ in 
//            RowModel(word: "", expected: expected, isSubmitted: false)
//        }
        let isActives = (0..<maxIx).map { _ in
            false
        }
        self._rows = Published(wrappedValue: rows)
        //self._isActives = Published(wrappedValue: isActives)
    }
}
