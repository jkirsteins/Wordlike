import SwiftUI

/// View that can be put in a ZStack, where it will
/// expand and invisibly capture hardware keyboard.
///
/// It will prevent on-screen iOS keyboard from being
/// shown (by providing a blank UIView() as the inputView).
struct HardwareKeyboardInput: UIViewRepresentable 
{
    @EnvironmentObject var game: GameState
    @EnvironmentObject var validator: WordValidator
    
    @EnvironmentObject 
    var toastMessageCenter: ToastMessageCenter
    
    @AppStateStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    /// Using an externally-controlled focus request
    /// variable lets us become first responder without
    /// having to be overlaid other views.
    ///
    /// This means other views are free to support 
    /// interaction (e.g. context menus).
    @Binding var focusRequests: Int
    
    @Environment(\.debug) var debug: Bool
    
    /// Using a custom empty keyboard view,
    /// in case we need to override something.
    class HiddenKeyboard : UIView {
    }
    
    /// Internal control that gets instantiated 
    /// and handles the key presses.
    class InternalView: UIControl, UIKeyInput
    {
        var owner: HardwareKeyboardInput
        
        /// if this changes from SwiftUI views focus
        /// request count, then we should become first
        /// responder (and set this value to match)
        var handledFocusRequests: Int = 0
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let _ = self.becomeFirstResponder( )
        }
        
        init(owner: HardwareKeyboardInput) {
            self.owner = owner
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var canResignFirstResponder: Bool {
            true
        }
        
        /// If we return a blank `UIView()` from
        /// `ìnputView`, the software keyboard should be 
        /// hidden.
        ///
        /// We could set the frame to non-zero and
        /// make the view transparent, if we wanted to
        /// check when we lose focus (i.e. when the custom
        /// view is removed). But this feels
        /// too much like a hack for no good reason, so 
        /// not doing this.
        let keyboard = HiddenKeyboard(
            frame: .zero) 
        
        override var inputView: UIView? {
            keyboard
        }
        
        override var canBecomeFirstResponder: Bool {
            return true
        }
        
        /// Not implemented cause we don't really care.
        /// Simply returns `true` 
        var hasText: Bool {
            true
        } 
        
        override func didMoveToSuperview() {
            self.becomeFirstResponder()
        }
        
        func insertText(_ text: String) {
            if text == "\n" {
                self.owner.game.submit(
                    validator: self.owner.validator,
                    hardMode: self.owner.isHardMode,
                    toastMessageCenter: self.owner.toastMessageCenter)
                return
            }
            
            let locale = self.owner.game.expected.locale
            let alphabet = String.uppercasedAlphabet(for: locale)
            
            let character: CharacterModel
            switch(locale) {
                case .fr_FR:
                // French guess list doesn't include
                // diacritics, so remove them from
                // keyboard input
                character = CharacterModel(
                    value: text.folding(
                        options: .diacriticInsensitive,
                        locale: .fr_FR),
                    locale: locale.nativeLocale)
                default:
                character = CharacterModel(
                    value: text, 
                    locale: locale.nativeLocale)
            }
            
            guard alphabet.contains(character) else {
                // Unrecognized char, ignore
                //
                // If we get this wrong, the soft keyboard
                // is a backup.
                return 
            }
            
            self.owner.game.insertText(
                letter: MultiCharacterModel(character))
        }
        
        func deleteBackward() {
            self.owner.game.deleteBackward()
        }
    }
    
    func makeUIView(context: Context) -> InternalView {
        let result = InternalView(owner: self)
        
        return result
    }
    
    class Coordinator {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ uiView: InternalView, context: Context) {
        
        if (uiView.handledFocusRequests != self.focusRequests) {
            uiView.handledFocusRequests = self.focusRequests
            if !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            }
        }
        
        uiView.owner = self
    }
}

struct Internal_InputCaptureView_Preview : View {
    static let validator = WordValidator(locale: .lv_LV(simplified: false))
    
    @StateObject var game = GameState(
        expected: TurnAnswer(
            word: WordModel("ČAULA", locale: .lv_LV), 
            day: 1, 
            locale: .lv_LV(simplified: false), 
            validator: Self.validator))
    @StateObject var validator = Self.validator
    @StateObject var tmc = ToastMessageCenter()
    
    @State var focusRequests: Int = 0
    
    var body: some View {
        VStack {
            HardwareKeyboardInput(focusRequests: $focusRequests)
                .border(.red)
            GameBoard(
                state: game, 
                earlyCompleted: nil, 
                completed: nil)
            Text(verbatim: "Focus requests: \(focusRequests)")
            Button("Focus") {
                focusRequests += 1
            }
        }
        .environmentObject(game)
        .environmentObject(validator)
        .environmentObject(tmc)
    }
}

struct KeyboardInput_Previews: PreviewProvider {
    static var previews: some View {
        Internal_InputCaptureView_Preview()
    }
}
