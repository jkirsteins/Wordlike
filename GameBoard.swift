import SwiftUI

class GameState : ObservableObject
{
    let expected: String
    
    @Published var rows: [RowModel]
    @Published var isActives: [Bool]
    
    var isCompleted: Bool {
        rows.allSatisfy { $0.isSubmitted }
    }
    
    init(expected: String) {
        self.expected = expected
        
        let maxIx = 5
        let rowModels = (0..<maxIx).map { _ in 
            RowModel(word: "", expected: expected, isSubmitted: false)
        }
        let isActives = (0..<maxIx).map { _ in
            false
        }
        self._rows = Published(wrappedValue: rowModels)
        self._isActives = Published(wrappedValue: isActives)
    }
}

struct GameBoardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var isActive: Int? = nil
    @StateObject var state: GameState
    
    func allSubmitted(until row: Int) -> Bool {
        if row == 0 {
            return true
        }
        
        return allSubmitted(until: row - 1) &&
        state.rows[row - 1].isSubmitted
    }
    
    func canEdit(row: Int) -> Bool {
        return allSubmitted(until: row) && !state.rows[row].isSubmitted 
    } 
    
    var onCompleteCallback: ((GameState)->())? = nil
    
    func onCompleted(callback: @escaping (GameState)->()) -> some View {
        var copy = self
        copy.onCompleteCallback = callback
        return copy
    }
    
    func recalculateActive() {
        for ix in 0..<state.rows.count {
            if canEdit(row: ix) {
                isActive = ix
                print("Set", ix, "to active")
                return
            }
            print("Set nothing to active", state.rows.map { $0.isSubmitted })
        }
    }
    
    @State var didCompleteCallback = false
    
    var body: some View {
        PaletteSetterView {
            VStack {
                
                ForEach(0..<state.rows.count) {
                    ix in 
                    VStack { 
                        
                        EditableRow(
                            model: $state.rows[ix], 
                            tag: ix,
                            isActive: $isActive)
                            
//                        Text(verbatim: "Row \(ix) Edit: \(canEdit(row:ix)) Submit: \(state.rows[ix].isSubmitted)")
//                        Text(verbatim: "All submitted \(allSubmitted(until: ix))")
//                        Text(verbatim: "isActive \(isActive) vs \(ix)")
                    }
                    
                }
            }
        }
        .onChange(of: state.rows) {
            _ in 
            
            if let onCompleteCallback =
                self.onCompleteCallback, 
                state.isCompleted, 
                !didCompleteCallback {
                
                didCompleteCallback = true
                
                DispatchQueue.main.async {
                    onCompleteCallback(state)
                }
            }  
        }
        .onTapGesture {
            recalculateActive()
        }
        .onAppear {
            isActive = 0
        }
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameBoardView(state: GameState(expected: "board"))
    }
}
