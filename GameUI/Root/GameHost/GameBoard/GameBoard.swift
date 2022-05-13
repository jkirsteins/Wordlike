import SwiftUI

struct GridPadding {
    static let normal = CGFloat(8.0)
    static let compact = CGFloat(2.0)
}

/// Track various params about the reveal state of
/// the board.
///
/// So we can synchronize the flips across rows,
/// and the jumps, and the messages after flips/before jumps
/// etc. etc. etc.
class BoardRevealModel : ObservableObject {
    
    /// How many letters have been revealed
    @Published var revealedCount: Int = 0
    
    /// A finish is one of:
    ///   - when lost turn and all tiles revealed
    ///   - when turn won, tiles revealed, AND wave finished
    @Published var didFinish: Bool = false
    
    /// Early finish is when all tiles are revealed
    @Published var didEarlyFinish: Bool = false
    
    /// Which row can start revealing its letters
    @Published var rowStartIx: Int = 0
}

struct GameBoard: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var vm = BoardRevealModel()
    
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
                    keyboardHints: state.keyboardHints)
            }
        }
        .environmentObject(vm)
        .onReceive(
            self.vm.$didEarlyFinish
        ) { def in
            guard 
                def,
                let earlyCallback = earlyCompleted,
                !didEarlyRespond, 
                    state.isCompleted
            else {
                return
            }
            
            didEarlyRespond = true
            earlyCallback(state)
        }
        .onReceive(
            // We debounce to add a bit of delay
            // after all the animations finish
            self.vm.$didFinish.debounce(
                for: 1.0, scheduler: DispatchQueue.main)
        ) { df in
            
            /* If we lose, do callback
             without waiting */
            guard 
                df,
                let callback = completed,
                !didRespond, 
                    state.isCompleted
            else {
                return
            }
            
            didRespond = true
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
