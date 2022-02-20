import SwiftUI

struct KeyboardInput<Content: View> : View 
{
    @Binding var model: RowModel
    @Binding var isActive: Int?
    
    let tag: Int
    let content: Content 
    
    init(model: Binding<RowModel>, tag: Int, isActive: Binding<Int?>,
    @ViewBuilder _ content: ()->Content) {
        self._model = model
        self.tag = tag
        self._isActive = isActive
        self.content = content()
    }
    
    @State var contentSize: CGSize = CGSize.zero
    
    var body: some View {
        
        ZStack {
            
            content.background(GeometryReader {
                proxy in 
                
                Color.clear.onAppear {
                    contentSize = proxy.size
                }
            })
            
            KeyboardInputUIKit(
                model: $model,
                tag: self.tag,
                isActive: $isActive)
                .frame(width: contentSize.width, height: contentSize.height)
        }
        .border(self.isActive == self.tag ? .red : .green)
    }
}

struct KeyboardInputUIKit: UIViewRepresentable {
    
    class InternalView: UIControl, UIKeyInput
    {
        @Binding var model: RowModel
        let focusTag: Int
        @Binding var isActive: Int?
        
        var stale = UUID().uuidString
        
        init(model: Binding<RowModel>, tag: Int, isActive: Binding<Int?>) {
            self._model = model
            self.focusTag = tag
            self._isActive = isActive
            super.init(frame: CGRect.infinite)
            addTarget(self, 
                      action: #selector(self.onTap(_:)),
                      for: .touchUpInside)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override open func resignFirstResponder() -> Bool {
            if self.isActive == focusTag {
//                return true
//                self.isActive = nil
//                fatalError("asd")
            }
            print(self.focusTag, "resign", stale)
            return super.resignFirstResponder()
        }
        
        override open func becomeFirstResponder() -> Bool {
            if self.isActive != focusTag { 
//                self.isActive = self.focusTag
            }
            print(self.focusTag, "become", stale)
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
            return true
        }
        
        @objc private func onTap(_: AnyObject) {
            _ = self.becomeFirstResponder()
        }
        
        var hasText: Bool {
            return model.word.isEmpty == false
        } 
        
        func insertText(_ text: String) {
            for chr in text { 
                guard chr.isLetter else {
                    if chr == "\n" && self.model.word.count == 5 {
                        self.model = RowModel(
                            word: self.model.word,
                            expected: self.model.expected,
                            isSubmitted: true
                        )
                    }
                    
                    return
                }
            }
            
            self.model = RowModel(
                word:  String((self.model.word + text).prefix(5)),
                expected: self.model.expected,
                isSubmitted: self.model.isSubmitted)
        }
        
        func deleteBackward() {
            self.model = RowModel(
                word: String(self.model.word.dropLast()),
                expected: self.model.expected,
                isSubmitted: self.model.isSubmitted)
        }
    }
    
    @Binding var model: RowModel
    let tag: Int
    @Binding var isActive: Int?
    
    func makeUIView(context: Context) -> InternalView {
        let result = InternalView(
            model: _model,
            tag: self.tag,
            isActive: self._isActive)
        
        result.setContentHuggingPriority(.defaultHigh, for: .vertical)
        result.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        if isActive == tag {
            print("Becoming 1")
            _ = result.becomeFirstResponder()
        } 
//            print("Resign 1")
//            _ = result.resignFirstResponder()
//        }
        
        let v = VStack {
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
                
                Spacer()
            } 
            Spacer()
        }.background(Color(UIColor.systemFill))
        //            .padding(0)
        //            .frame(width: 100, height: 44)
        //            .background(Color(UIColor.systemFill))
        
        let accView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: result.bounds.size.width, height: 44))
        //        accView.autoresizingMask = [.flexibleWidth] // important! allows it to resize
        //        accView.backgroundColor = .red // .systemFill
        
        
        let vc = UIHostingController(rootView: v)
        //        accView.addSubview(vc.view)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        accView.addSubview(vc.view)
        vc.view.leadingAnchor.constraint(equalTo: accView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: accView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: accView.safeAreaLayoutGuide.topAnchor).isActive = true
        vc.view.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        result.inputAccessoryView = accView
        
        return result
    }
    
    class Coordinator {
        var sendUpdates = true
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ uiView: InternalView, context: Context) {
//        let wasActive = self.isActive
        
//        uiView.isActive = self.isActive
//        self.isActive = true
        
//        uiView.isActive = self.isActive
        
        print("tag", uiView.focusTag, "isa", uiView.isActive, "self", self.tag, "isas", self.isActive)
        
        if self.tag == self.isActive {
            print("Becoming 2")
            _ = uiView.becomeFirstResponder()
        }
        
        
//        if self.isActive {
//            _ = uiView.becomeFirstResponder()
//        } 
//        else {
//            _ = uiView.resignFirstResponder()
//        }
        
    }
}

struct EditableRow : View
{
    @Binding var model: RowModel
    let tag: Int
    @Binding var isActive: Int?
    
    init(model: Binding<RowModel>, tag: Int, isActive: Binding<Int?>) {
        self._model = model
        self.tag = tag
        self._isActive = isActive
    }
    
    var body: some View {
        body_internal
            .onChange(of: self.model) {
                newModel in
                
                if newModel.isSubmitted && self.isActive == tag {
//                    fatalError("mepqw")
//                    self.isActive = tag + 1
                }
            }
//                
//                if newVal && isActive != tag {
//                    print("[\(tag)] set isactive to tag")
//                    isActive = tag
//                } 
//                else if !newVal && isActive == tag { 
////                    print("[\(tag)] set isactive to nil")
////                    if model.isSubmitted, let isActive = isActive {
////                        self.isActive = isActive + 1
////                    } else {
////                        isActive = nil
////                    }
//                    if self.model.isSubmitted {
//                        isActive = tag + 1
//                    }
//                }
//            }
            .onChange(of: self.isActive) {
                newIsActive in
                
            }
    }
    
    @ViewBuilder
    var body_internal: some View { 
        if true || !model.isSubmitted {
            KeyboardInput(
                model: $model,
                tag: self.tag,
                isActive: $isActive, {
                Row(model: model)
            }).border(self.tag == isActive ? .yellow : .purple, width: 2) 
        } else {
            Row(model: model)
        }
        
        Text(verbatim: "Active: \(self.isActive)")
        Text(verbatim: "Tag: \(self.tag)")
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

struct KeyboardInput_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Above").background(.green)
            EditableRow_ForPreview()
            Text("Below").background(.red)
        }
    }
}
