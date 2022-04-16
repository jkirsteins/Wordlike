import SwiftUI

struct SubmissionFailureReasonKey: PreferenceKey {
    static var defaultValue: String? = nil
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue() ?? value
    }
}

struct KeyboardInput<Content: View, AccessoryView: View> : View 
{
    @Binding var model: RowModel
    @Binding var isActive: Int?
    
    let tag: Int
    let content: Content 
    let accessoryView: AccessoryView
    let editable: Bool
    
    @Environment(\.debug) var debugViz: Bool
    
    init(
    editable: Bool,
model: Binding<RowModel>, 
tag: Int, 
isActive: Binding<Int?>,
    @ViewBuilder _ content: ()->Content,
    @ViewBuilder _ accessoryView: ()->AccessoryView) {
        self.editable = editable
        self._model = model
        self.tag = tag
        self._isActive = isActive
        self.content = content()
        self.accessoryView = accessoryView()
    }
    
    var borderColor: Color {
        guard debugViz else { return .clear }
        return self.isActive == self.tag ? .red : .green
    }
    
    @State var contentSize: CGSize = CGSize.zero
    @State var testUuid: Date = Date()
    
    @Environment(\.failureReason) var failureReason: Binding<String?>
    
    var body: some View {
        
        ZStack {
            
            content.background(GeometryReader {
                proxy in 
                
                Color.clear
                    .onAppear {
                        contentSize = proxy.size
                    }
                    .onChange(of: proxy.size) { newSize in
                        contentSize = newSize
                    }
            })
            
            if editable {
            KeyboardInputUIKit(
                failureReason: failureReason,
                model: $model,
                tag: self.tag,
                isActive: $isActive,
                accessoryView: accessoryView)
            
            
            // If you set width/height, then it might prevent `content` from resizing
            // (e.g. it might not become narrow, if iPad window becomes smaller) 
                .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
                .border(borderColor)
            }
        }
        .preference(
            key: SubmissionFailureReasonKey.self, 
            value: failureReason.wrappedValue
        )
        
    }
}

struct KeyboardInputUIKit<AccessoryView: View>: UIViewRepresentable {
    
    @EnvironmentObject var validator: WordValidator
    
    @Binding var failureReason: String?
    
    class InternalView<AccessoryView: View>: UIControl, UIKeyInput
    {
        //        var model: RowModel
        //        let focusTag: Int
        //        var isActive: Int?
        
        //        var accessoryView: AccessoryView
        
        var owner: KeyboardInputUIKit<AccessoryView>
        
        init(owner: KeyboardInputUIKit<AccessoryView>) {
            self.owner = owner
            //            self.focusTag = tag
            //            self.isActive = isActive
            //            self.accessoryView = accessoryView
            self.vc = UIHostingController(rootView: self.owner.accessoryView)
            
            self.accView = UIView()
            
            super.init(frame: CGRect.infinite)
            addTarget(self, 
                      action: #selector(self.onTap(_:)),
                      for: .touchUpInside)
            
            self.initAccessoryView()
        }
        
        let vc: UIHostingController<AccessoryView>
        let accView: UIView
        
        func initAccessoryView()
        {
            self.accView.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: 44)
            
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            accView.addSubview(vc.view)
            vc.view.leadingAnchor.constraint(equalTo: accView.safeAreaLayoutGuide.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: accView.safeAreaLayoutGuide.trailingAnchor).isActive = true
            vc.view.topAnchor.constraint(equalTo: accView.safeAreaLayoutGuide.topAnchor).isActive = true
            vc.view.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            self.inputAccessoryView = accView
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override open func resignFirstResponder() -> Bool {
            if self.owner.isActive == owner.tag {
                //                return true
                self.owner.isActive = nil
                //                fatalError("asd")
            }
            
            return super.resignFirstResponder()
        }
        
        override open func becomeFirstResponder() -> Bool {
            guard !self.owner.model.isSubmitted else {
                return false
            }
            
            if self.owner.isActive != owner.tag {
                self.owner.isActive = self.owner.tag
            }
            
            return super.becomeFirstResponder()
        }
        
        var _inputAccessoryView: UIView?
        override var inputAccessoryView: UIView? {
            get {
                _inputAccessoryView
            }
            set {
                _inputAccessoryView = newValue
            }
        }
        
        override var canBecomeFirstResponder: Bool {
            return !self.owner.model.isSubmitted
        }
        
        @objc private func onTap(_: AnyObject) {
            //            fatalError("onTap")
            //            UIView.performWithoutAnimation { 
            //                _ = self.becomeFirstResponder()
            //            }
        }
        
        var hasText: Bool {
            return owner.model.word.isEmpty == false
        } 
        
        func insertText(_ text: String) {
            for chr in text { 
                guard chr.isLetter else {
                    if chr == "\n" {
                        // If word doesn't match,
                        // don't set isSubmitted
                        guard  self.owner.validator.canSubmit(word: self.owner.model.word, reason: &self.owner.failureReason) else {
                            self.owner.model = RowModel(
                                word: self.owner.model.word,
                                expected: self.owner.model.expected,
                                isSubmitted: false,
                                attemptCount: self.owner.model.attemptCount + 1
                            )
                            
                            return
                        } 
                        
                        // After the last editable row, isActive will
                        // point to something that doesn't exist. This is fine,
                        // as it simply ensures that the keyboard goes away.
                        self.owner.isActive = owner.tag + 1
                        
                        self.owner.model = RowModel(
                            word: self.owner.model.word,
                            expected: self.owner.model.expected,
                            isSubmitted: true,
                            attemptCount: 0
                        )
                    }
                    
                    return
                }
            }
            
            self.owner.model = RowModel(
                word:  String((self.owner.model.word + text).prefix(5)),
                expected: self.owner.model.expected,
                isSubmitted: self.owner.model.isSubmitted)
        }
        
        func deleteBackward() {
            self.owner.model = RowModel(
                word: String(self.owner.model.word.dropLast()),
                expected: self.owner.model.expected,
                isSubmitted: self.owner.model.isSubmitted)
        }
    }
    
    @Binding var model: RowModel
    let tag: Int
    @Binding var isActive: Int?
    let accessoryView: AccessoryView
    
    func makeUIView(context: Context) -> InternalView<AccessoryView> {
        let result = InternalView(owner: self)
        
//        result.setContentHuggingPriority(.defaultLow, for: .vertical)
//        result.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        if isActive == tag {
            UIView.performWithoutAnimation { 
                _ = result.becomeFirstResponder()
            }
        } 
        
        return result
    }
    
    class Coordinator {
        var sendUpdates = true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ uiView: InternalView<AccessoryView>, context: Context) {
        
        uiView.owner = self
        
        // The SwiftUI view has been added as a
        // subview to accessoryView. Resetting the rootview
        // will update it using SwiftUI as source-of-truth
        //
        // If we do anything else here, we'll need to 
        // make sure that the layout is still correct.
        uiView.vc.rootView = self.accessoryView

        // Without overriding the userInterfaceStyle,
        // the input accessory view will lag behind (
        // be light after switching to dark, and be dark
        // after switching to light, etc.)
        uiView.vc.overrideUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        
        // The following are not called on main asynchronously,
        // there's an attribute cycle. See:
        // https://stackoverflow.com/questions/59707784/
        if self.tag == self.isActive {
            if !uiView.isFirstResponder {
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation { 
                        _ = uiView.becomeFirstResponder()
                    }
                }
            }
        } else {
            if uiView.isFirstResponder {
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation { 
                        _ = uiView.resignFirstResponder()
                    }
                }
            }
        }
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
    @Binding var isActive: Int?
    
    let editable: Bool
    
    let keyboardHints: KeyboardHints
    
    init(
        editable: Bool,
        delayRowIx: Int,
        model: Binding<RowModel>, 
        tag: Int, 
        isActive: Binding<Int?>,
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
        isActive: Binding<Int?>,
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
        
        return KeyboardInput(
            editable: editable,
            model: $model,
            tag: self.tag,
            isActive: $isActive, {
                VStack {
                    Row(delayRowIx: delayRowIx, model: model, showFocusHint: showFocusHint)
                }
            }) {
                PaletteSetterView {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            KeyboardHintView(
                                hints: keyboardHints)
                            
                            Spacer()
                        } 
                        Spacer()
                    }
                    .background(Color(UIColor.systemFill))
                    }
                
            }
        
    }
}

struct EditableRow_ForPreview : View {
    @State var isActive: Int? = nil
    
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
                if isActive == nil {
                    isActive = 1
                    return
                }
                if isActive == 1 {
                    isActive = 0
                    return
                }
                if isActive == 0 {
                    isActive = nil
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
