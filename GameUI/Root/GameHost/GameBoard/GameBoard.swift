import SwiftUI

struct GridPadding {
    static let normal = CGFloat(8.0)
    static let compact = CGFloat(2.0)
}

fileprivate class ViewModel : ObservableObject {
    @Published var revealedCount: Int = 0
    @Published var rowStartIx: Int = 0
}

struct GameBoard: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject fileprivate var vm = ViewModel()
    
    @State var isActive: Int = 0
    
    // Controls if we call the complete callback
    @State var didRespond = false
    @State var didEarlyRespond = false
    
    @ObservedObject var state: GameState
    let earlyCompleted: ((GameState)->())? 
    let completed: ((GameState)->())? 
    
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
    
    func recalculateActive() {
        for ix in 0..<state.rows.count {
            if canEdit(row: ix) {
                isActive = ix
                return
            }
        }
    }
    
    @Environment(\.horizontalSizeClass) 
    var horizontalSizeClass
    @Environment(\.verticalSizeClass) 
    var verticalSizeClass
    
    @Environment(\.debug)
    var debug: Bool
    
    /// If we have a small view, then spacing should be reduced
    /// (e.g. horizontal compact)
    var vspacing: CGFloat {
        if verticalSizeClass == .compact {
            return GridPadding.compact
        } 
        
        return GridPadding.normal
    }
    
    var body: some View {
        VStack(spacing: vspacing) {
            ForEach(0..<state.rows.count, id: \.self) {
                ix in 
                
                EditableRow(
                    editable: !state.isCompleted,
                    delayRowIx: ix,
                    model: $state.rows[ix], 
                    tag: ix,
                    isActive: $isActive,
                    keyboardHints: state.keyboardHints,
                    revealedCount: $vm.revealedCount,
                    rowStartIx: $vm.rowStartIx)
            }
        }
        .onReceive(
            self.vm.$revealedCount.debounce(
                for: 0.75, scheduler: DispatchQueue.main)) {
                    nrc in 
            
                    guard 
                        let callback = completed,
                        !didRespond, 
                            state.isCompleted,
                        nrc == self.state.submittedRows * 5
                    else {
                        return
                    }
            
                    didRespond = true
                    callback(state)
        }
        .onChange(of: state.rows) { _ in 
            guard 
                let callback = earlyCompleted,
                !didEarlyRespond,
                state.isCompleted
            else {
                return
            }
            
            didEarlyRespond = true 
            callback(state)
        }
        .onChange(of: state.id) {
            _ in
            /* State can change when we've
             e.g. stats sheet on top (in which case
             we don't want to pop up the keyboard)
             */
            recalculateActive()
        }
        .onTapGesture {
            recalculateActive()
        }
        .onAppear {
            recalculateActive()
        }
    }
}

fileprivate struct InternalPreview: View 
{
    @State var state = GameState(expected: TurnAnswer(word: "board", day: 1, locale: .en_US, validator: WordValidator(locale: .en_US)))
    
    var body: some View {
        VStack {
            GameBoard(
                state: state, 
                earlyCompleted: nil, 
                completed: nil)
            Button("Reset") {
                self.state =     GameState(expected: TurnAnswer(word: "fuels", day: 1, locale: .en_US, validator: WordValidator(locale: .en_US)))
            }
        }
    }
}

struct GameBoard_Previews: PreviewProvider {
    static var previews: some View {
        InternalPreview()
    }
}
