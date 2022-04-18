import SwiftUI

struct GameBoardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var isActive: Int = 0
    @ObservedObject var state: GameState
    
    let canBeAutoActivated: Bool 
    
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
    
    func onStateChange(edited: @escaping ([RowModel])->(), completed: @escaping (GameState)->()) -> some View {
        var didRespond = false
        return self.onChange(of: self.state.rows) {
            newRows in 
            
            DispatchQueue.main.async {
                edited(newRows)
            }
            
            guard state.isCompleted, !didRespond else { 
                return }
            didRespond = true
            
            Task {
                // allow time to finish animating a single
                // row
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                DispatchQueue.main.async {
                    completed(state)    
                }  
            }
        }.task {
            if state.isCompleted {
                // allow time to finish animating
                // all rows that just appeared
                try? await Task.sleep(nanoseconds: UInt64(state.submittedRows) * 500_000_000) 
                completed(state)
            }
        }
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
                ForEach(0..<state.rows.count, id: \.self) {
                    ix in 
                    VStack { 
                        
                        EditableRow(
                            editable: !state.isCompleted,
                            delayRowIx: ix,
                            model: $state.rows[ix], 
                            tag: ix,
                            isActive: $isActive,
                            keyboardHints: state.keyboardHints )
                    }
                }
            }
        }
        .onChange(of: state.id) {
            _ in
            /* State can change when we've
             e.g. stats sheet on top (in which case
             we don't want to pop up the keyboard)
             */
            if canBeAutoActivated {
                recalculateActive()
            }
        }
        .onTapGesture {
            recalculateActive()
        }
        .onAppear {
            if canBeAutoActivated {
                recalculateActive()
            }
        }
    }
}

fileprivate struct InternalPreview: View 
{
    @State var state = GameState(expected: DayWord(word: "board", day: 1, locale: "en"))
    
    var body: some View {
        VStack {
            GameBoardView(state: state, canBeAutoActivated: false)
            Button("Reset") {
                self.state = GameState(expected: DayWord(word: "fuels", day: 1, locale: "en"))
            }
        }
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        InternalPreview()
    }
}
