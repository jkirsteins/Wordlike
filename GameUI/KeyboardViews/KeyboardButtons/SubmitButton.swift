import SwiftUI

fileprivate struct SubmitButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette: Palette
    
    @EnvironmentObject var game: GameState
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(
                    (game.isCompleted ? palette.normalKeyboardFill : palette.submitKeyboardFill)
                        .adjust(
                            pressed: configuration.isPressed)
                )
            
            configuration.label
                .foregroundColor(configuration.isPressed ? .white.darker : .white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4.0))
    }
}

/// Keyboard submit button.
struct SubmitButton: View {
    let maxSize: CGSize
    
    @EnvironmentObject var game: GameState
    @EnvironmentObject var validator: WordValidator
    
    @EnvironmentObject 
    var toastMessageCenter: ToastMessageCenter
    
    func submitAction() {
        guard !game.isCompleted else {
            return
        }
        
        let first = game.rows.first
        let firstSubmitted = game.rows.first(where: { !$0.isSubmitted })
        
        guard 
            let current = firstSubmitted ?? first,
            let currentIx = game.activeIx
        else {
            // no rows?
            print("No rows")
            return
        }
        
        var message: String? = nil
        defer {
            if let newMessage = message {
                toastMessageCenter.set(newMessage)
            }
        }
        
        // If word doesn't match,
        // don't set isSubmitted
        guard validator.canSubmit(
            word: current.word, 
            reason: &message) else {
                let updatedRow = RowModel(
                    word: current.word,
                    expected: current.expected,
                    isSubmitted: false,
                    attemptCount: current.attemptCount + 1)
                                
                game.rows[currentIx] = updatedRow
                return
            } 
        
        let submitted = RowModel(
            word: current.word,
            expected: current.expected,
            isSubmitted: true,
            attemptCount: 0)
        game.rows[currentIx] = submitted
    }
    
    func padding(_ gp: GeometryProxy) -> CGFloat {
        let minEdge = max(gp.size.width, gp.size.height)
        
        let div: CGFloat 
        
        if minEdge < 30 {
            return 0
        } 
        else if minEdge < 50 {
            div = 9.0
        } 
        else {
            div = 6.0
        }
        
        return gp.size.height / div
    }
    
    var body: some View {
        Button(action: submitAction, label: {
            GeometryReader { gr in 
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        Spacer()
                        Image(systemName: "return")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Spacer()
                    }
                    Spacer()
                }.padding(padding(gr))
            }
        })
            .buttonStyle(SubmitButtonStyle())
            .disabled(game.isCompleted)
            .frame(
                maxWidth: maxSize.width, 
                maxHeight: maxSize.height)
    }
} 

struct SubmitButtonInternalPreview : View {
    @State var reason: String? = nil
    @State var state = GameState(
        expected: TurnAnswer(
            word: "fuels", day: 0, locale: "en"))
    
    var body: some View {
        VStack {
            Text("Failure: \(reason ?? "<none>")")
        SubmitButton(
            maxSize: 
                    CGSize(width: 200, height: 100))
            .environmentObject(state)
            .environmentObject(WordValidator(name: "en", seed: 123))
        }
    }
}

struct SubmitButton_Previews: PreviewProvider {
    static var previews: some View {
        SubmitButtonInternalPreview()
    }
}