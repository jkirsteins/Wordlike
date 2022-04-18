import SwiftUI

struct SubmissionFailureReasonKey: PreferenceKey {
    static var defaultValue: String? = nil
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue() ?? value
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
