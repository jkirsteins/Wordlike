import SwiftUI

struct KeyboardInput<Content: View, AccessoryView: View> : View 
{
    @Binding var model: RowModel
    @Binding var isActive: Int?
    
    let tag: Int
    let content: Content 
    let accessoryView: AccessoryView
    
    init(
model: Binding<RowModel>, 
tag: Int, 
isActive: Binding<Int?>,
    @ViewBuilder _ content: ()->Content,
    @ViewBuilder _ accessoryView: ()->AccessoryView) {
        self._model = model
        self.tag = tag
        self._isActive = isActive
        self.content = content()
        self.accessoryView = accessoryView()
    }
    
    @State var contentSize: CGSize = CGSize.zero
    @State var testUuid: Date = Date()
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
            
            KeyboardInputUIKit(
                model: $model,
                tag: self.tag,
                isActive: $isActive,
                accessoryView: accessoryView)
            
            // If you set width/height, then it might prevent `content` from resizing
            // (e.g. it might not become narrow, if iPad window becomes smaller) 
                .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
                .border(self.isActive == self.tag ? .red : .green)
        }
        
    }
}

struct KeyboardInputUIKit<AccessoryView: View>: UIViewRepresentable {
    
    @EnvironmentObject var validator: WordValidator
    
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
                    if chr == "\n" && self.owner.model.word.count == 5 {
                        // If word doesn't match,
                        // don't set isSubmitted
                        guard self.owner.validator.canSubmit(word: self.owner.model.word) else {
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

struct EditableRow : View
{
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var model: RowModel
    let tag: Int
    @Binding var isActive: Int?
    
    init(
        model: Binding<RowModel>, 
        tag: Int, isActive: Binding<Int?>) {
            self._model = model
            self.tag = tag
            self._isActive = isActive
        }
    
    @State var background: Color = Color(UIColor.systemFill)
    
    var body: some View { 
        //        if !model.isSubmitted {
        KeyboardInput(
            model: $model,
            tag: self.tag,
            isActive: $isActive, {
                Row(model: model)
            }) {
                PaletteSetterView {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            Tile(
                                letter: "A", 
                                delay: 0, 
                                revealState: .rightPlace)
                            Tile(
                                letter: "B", 
                                delay: 0, 
                                revealState: .wrongPlace)
                            Tile(
                                letter: "C", 
                                delay: 0, 
                                revealState: .none)
                            
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
    
    var body: some View {
        VStack {
            EditableRow(
                model: $model1,
                tag: 0,
                isActive: $isActive)
            
            EditableRow(
                model: $model2,
                tag: 1,
                isActive: $isActive)
            
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
    @State var state = GameState(expected: "board")
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State var count = 0
    
    @EnvironmentObject var validator: WordValidator
    
    var body: some View {
        VStack {
            GameBoardView(state: state)
            Text("Count: \(count)")
            Text("Today's word: \(validator.todayAnswer)")
            Button("Reset") {
                self.state = GameState(expected: "fuels")
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
