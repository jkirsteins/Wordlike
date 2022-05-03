import SwiftUI

fileprivate struct SubmitButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette: Palette
    
    @EnvironmentObject var game: GameState
    
    @Environment(\.isEnabled)
    var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(
                    isEnabled ? 
                    ((game.isCompleted ? palette.normalKeyboardFill : palette.submitKeyboardFill)
                        .adjust(
                            pressed: configuration.isPressed))
                    :
                        palette.normalKeyboardFill
                )
            
            configuration.label
                .foregroundColor(configuration.isPressed ? .white.darker : .white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4.0))
    }
}

/// Keyboard submit button.
struct SubmitButton<ValidatorImpl: Validator & ObservableObject>: View {
    let maxSize: CGSize
    
    @EnvironmentObject var game: GameState
    @EnvironmentObject var validator: ValidatorImpl
    
    @EnvironmentObject 
    var toastMessageCenter: ToastMessageCenter
    
    @Environment(\.keyboardSubmitEnabled)
    var enabled: Bool
    
    @AppStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    func submitAction() {
        self.game.submit(
            validator: validator,
            hardMode: self.isHardMode,
            toastMessageCenter: toastMessageCenter)
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
            .disabled(!enabled || (enabled && game.isCompleted))
            .buttonStyle(SubmitButtonStyle())
            .frame(
                maxWidth: maxSize.width, 
                maxHeight: maxSize.height)
    }
} 

struct SubmitButtonInternalPreview : View {
    @StateObject var tmc = ToastMessageCenter()
    @State var state = GameState(
        expected: TurnAnswer(
            word: "fuels", day: 0, locale: .en_US, validator: WordValidator(locale: .en_US)))
    
    var body: some View {
        VStack {
            Text(verbatim: "Failure: \(tmc.message?.message ?? "none")")
            
        SubmitButton<WordValidator>(
            maxSize: 
                    CGSize(width: 200, height: 100))
            .environmentObject(state)
            .environmentObject(WordValidator(locale: .en_US, seed: 123))
            .environmentObject(tmc)
        }
    }
}

struct SubmitButton_Previews: PreviewProvider {
    static var previews: some View {
        SubmitButtonInternalPreview()
    }
}
