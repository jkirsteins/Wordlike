import SwiftUI

class GameState : ObservableObject, Identifiable
{
    let id = UUID()
    
    @Published var expected: String
    @Published var rows: [RowModel]
    //@Published var isActives: [Bool]
    
    var isCompleted: Bool {
        rows.allSatisfy { $0.isSubmitted }
    }
    
    convenience init(expected: String) {
        let rowModels = (0..<5).map { _ in 
            RowModel(word: "", expected: expected, isSubmitted: false)
        }
        self.init(expected: expected, rows: rowModels)
    }
    
    init(expected: String, rows: [RowModel]) {
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
