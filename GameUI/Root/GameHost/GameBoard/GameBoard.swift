import SwiftUI

struct GridPadding {
    static let normal = CGFloat(8.0)
    static let compact = CGFloat(2.0)
}

struct GameBoard: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var isActive: Int = 0
    
    // Controls if we call the complete callback
    @State var didRespond = false
    
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
    
    func onStateChange(
        edited: @escaping ([RowModel])->(),
        
        // Turn was completed, but callback is before animations are finished. Not called if turn was already finished when the view appeared.
        earlyCompleted: @escaping (GameState)->(),
        
        // Both turn and animations have completed. This 
        // has a delay relative to earlyCompleted:
        completed: @escaping (GameState)->()) -> some View {
            return self.onChange(of: self.state.rows) {
                newRows in 
                
                DispatchQueue.main.async {
                    edited(newRows)
                }
                
                guard state.isCompleted, !didRespond else 
                { 
                    return 
                }
                didRespond = true
                
                DispatchQueue.main.async {
                    earlyCompleted(state)
                }
                
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
                        keyboardHints: state.keyboardHints )
            }
            
            if (debug) {
                Text(verbatim: "Did respond: \(didRespond)")
                Text(verbatim: "Is completed: \(state.isCompleted)")
                Text(verbatim: "Active: \(isActive)")
            }
        }
        .onChange(of: state.id) {
            _ in
            /* State can change when we've
             e.g. stats sheet on top (in which case
             we don't want to pop up the keyboard)
             */
            recalculateActive()
//            didRespond = false
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
            GameBoard(state: state)
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
