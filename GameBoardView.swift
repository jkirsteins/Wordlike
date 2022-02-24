import SwiftUI

struct GameBoardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var isActive: Int? = nil
    @ObservedObject var state: GameState
    
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
    
//    var onCompleteCallback: ((GameState)->())? = nil
    
    func onCompleted(callback: @escaping (GameState)->()) -> some View {
        var didRespond = false
        return self.onChange(of: self.state.rows) {
            _ in 

            guard state.isCompleted, !didRespond else { 
                return }
            didRespond = true
            
            DispatchQueue.main.async {
                callback(state)    
            }  
        }
//        var copy = self
//        copy.onCompleteCallback = callback
//        return copy
    }
    
    func recalculateActive() {
        for ix in 0..<state.rows.count {
            if canEdit(row: ix) {
                isActive = ix
                return
            }
        }
    }
    
    @State var didCompleteCallback = false
    
    @State var test = RowModel(expected: "test")
    var body: some View {
        
        let model: Binding<RowModel> = $state.rows[0]
        
        return PaletteSetterView {
            VStack {
                Text(state.id.uuidString)
                Text(state.rows[0].id)
                    .onChange(of: state.rows[0]) {
                        _ in print("rowc")
                    }
                
                ForEach(0..<state.rows.count, id: \.self) {
                    ix in 
                    VStack { 
                        
                        EditableRow(
                            model: $state.rows[ix], 
                            tag: ix,
                            isActive: $isActive)
                    }
                    
                }
            }
        }
        // should be on 'state' 
        .onChange(of: state.expected) {
            _ in
            self.isActive = 0
        }
        .onTapGesture {
            recalculateActive()
        }
        .onAppear {
            isActive = 0
        }
    }
}

fileprivate struct InternalPreview: View 
{
    @State var state = GameState(expected: "board")
    
    var body: some View {
        VStack {
            GameBoardView(state: state)
            Button("Reset") {
                self.state = GameState(expected: "fuels")
            }
        }
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        InternalPreview()
    }
}
