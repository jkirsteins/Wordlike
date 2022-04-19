import SwiftUI

/// We wrap a String message in a struct that is
/// always brand new (to trigger the on-change even
/// for the same message).
struct ToastMessage : Equatable {
    let id = UUID() 
    let message: String 
}

class ToastMessageCenter : ObservableObject {
    /// Actual message that will be displayed
    @Published var message: ToastMessage? = nil
    
    /// Requested message might be overridden
    /// with an easter-egg message
    var requestedMessage: String? = nil
    
    let jokeMessages = [
        "Seriously?",
        "Sure, keep doing the same thing...",
        "I promise the outcome won't change",
        "Persistance won't pay off this time",
        "Consider doing something else",
        "What do you seek?",
        "I'll be sick from all the shaking...",
        "I promise you that is not a valid word",
        "You can do better than that",
        "There is no prize for the most clicks",
    ].shuffled()
    
    /// We want to stop showing the jokes after a timeout
    /// (i.e. only on vigorous same-message-button-mashing)
    var expireJokeAt: Date? = nil
    
    /// We want to keep a joke message around for a while, to give
    /// the user the time to read it.
    var currentJoke: String? = nil
    
    /// This triggers rollover for joke index
    var countSame: Int = 0
    
    /// This keeps incrementing to fetch the next joke (we don't grab
    /// a random joke to ensure every joke gets equal screentime)
    var jokeIndex: Int = 0
    
    func set(_ message: String) {
        defer {
            requestedMessage = message
        }
        
        let shouldExpireJoke: Bool
        if let expireJokeAt = self.expireJokeAt, expireJokeAt <= Date() {
            shouldExpireJoke = true
        } else {
            shouldExpireJoke = false
        }
        
        if !shouldExpireJoke, message == requestedMessage {
            countSame += 1
            
            expireJokeAt = Date() + 2.0
            
            if countSame % 5 == 0 {
                jokeIndex += 1
                let joke = jokeMessages[jokeIndex % jokeMessages.count] 
                currentJoke = joke
            }
        } else {
            // Reset joke state completely
            self.currentJoke = nil
            self.expireJokeAt = nil
            self.countSame = 0
        }
        
        self.message = ToastMessage(message: currentJoke ?? message)
    }
}

struct KeyboardHints {
    /// This contains the mapping to known outcomes (
    /// known good/misplaced/unused)
    let hints: Dictionary<String, TileBackgroundType>
    
    /// Locale is used to generate the alphabet, so 
    /// we can infer which are remaining usable chars.
    let locale: String
}

struct EditableRow : View
{
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var delayRowIx: Int
    @Binding var model: RowModel
    
    let tag: Int
    @Binding var isActive: Int
    
    let editable: Bool
    
    let keyboardHints: KeyboardHints
    
    init(
        editable: Bool,
        delayRowIx: Int,
        model: Binding<RowModel>, 
        tag: Int, 
        isActive: Binding<Int>,
        keyboardHints: KeyboardHints) {
            self.editable = editable
            self.delayRowIx = delayRowIx
            self._model = model
            self.tag = tag
            self._isActive = isActive
            self.keyboardHints = keyboardHints
        }
    
    init(
        delayRowIx: Int,
        model: Binding<RowModel>, 
        tag: Int, 
        isActive: Binding<Int>,
        keyboardHints: KeyboardHints) {
            self.editable = true
            self.delayRowIx = delayRowIx
            self._model = model
            self.tag = tag
            self._isActive = isActive
            self.keyboardHints = keyboardHints
        }
    
    @State var background: Color = Color(UIColor.systemFill)
    
    var body: some View {
        let showFocusHint =  editable && (isActive == self.tag) 
        
        return VStack {
            Row(delayRowIx: delayRowIx, model: model, showFocusHint: showFocusHint)
        }
    }
}

struct EditableRow_ForPreview : View {
    @State var isActive: Int = 0
    
    @State var model1 = RowModel(expected: "fuels")
    @State var model2 = RowModel(expected: "fuels")
    
    let kh: KeyboardHints = KeyboardHints(hints: [
        "A": .rightPlace
    ], locale: "en")
    
    var body: some View {
        VStack {
            EditableRow(
                delayRowIx: 0,
                model: $model1,
                tag: 0,
                isActive: $isActive,
                keyboardHints: kh)
            
            EditableRow(
                delayRowIx: 1,
                model: $model2,
                tag: 1,
                isActive: $isActive,
                keyboardHints: kh)
            
            Text(verbatim: "\(model1.attemptCount) x \(model2.attemptCount)")
            
            Button("Toggle") {
                // only works if
                // it is going nil->any
                //
                // any->any resigns both
                print("=== toggling ===")
                if isActive == 0 {
                    isActive = 1
                    return
                }
                if isActive == 1 {
                    isActive = 2
                    return
                }
                if isActive == 2 {
                    isActive = 0
                    return
                }
            }
        }
    }
}

fileprivate struct InternalPreview: View 
{
    @State var state = GameState(expected: DayWord(word: "board", day: 1, locale: "en"))
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State var count = 0
    
    @EnvironmentObject var validator: WordValidator
    
    var body: some View {
        let tc = BucketPaceSetter(
            start: WordValidator.MAR_22_2022, 
            bucket: 30)
        return VStack {
            GameBoardView(state: state, canBeAutoActivated: false)
            Text("Count: \(count)")
            Text("Today's word: \(validator.answer(at: tc.turnIndex(at: Date())))")
            Button("Reset") {
                self.state = GameState(expected: DayWord(word: "fuels", day: 1, locale: "en"))
            }.onReceive(timer) {
                _ in 
                self.count += 1
            }
        }
    }
}

struct KeyboardInput_Previews: PreviewProvider {
    static var previews: some View {
        InternalPreview()
            .environmentObject(WordValidator(name: "en"))
        
        VStack {
            Text("Above").background(.green)
            EditableRow_ForPreview()
            Text("Below").background(.red)
        }
        .environmentObject(WordValidator(name: "en"))
    }
}
