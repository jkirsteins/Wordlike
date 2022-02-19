import SwiftUI

struct KeyboardInput<Content: View> : View 
{
    @Binding var text: String
    @Binding var submitted: Bool
    
    @State var isActive: Bool = false
    
    let content: Content 
    
    init(text: Binding<String>, submitted: Binding<Bool>, @ViewBuilder _ content: ()->Content) {
        self._text = text
        self._submitted = submitted
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            KeyboardInputUIKit(
                text: $text, 
                isActive: $isActive,
                submitted: $submitted)
            
        }.border(self.isActive ? .red : .green)
    }
}

struct KeyboardInputUIKit: UIViewRepresentable {
    
    class InternalView: UIControl, UIKeyInput
    {
        @Binding var text: String
        @Binding var submitted: Bool
        @Binding var isActive: Bool
        
        init(text: Binding<String>, submitted: Binding<Bool>, isActive: Binding<Bool>) {
            self._text = text
            self._submitted = submitted
            self._isActive = isActive
            super.init(frame: CGRect.zero)
            addTarget(self, 
                      action: #selector(self.onTap(_:)),
                      for: .touchUpInside)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override open func resignFirstResponder() -> Bool {
            self.isActive = false
            return super.resignFirstResponder()
        }
        
        override open func becomeFirstResponder() -> Bool {
            self.isActive = true
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
            return text.isEmpty == false
        } 
        
        func insertText(_ text: String) {
            for chr in text { 
                guard chr.isLetter else {
                    if chr == "\n" && self.text.count == 5 {
                        self.submitted = true
                    }
                    
                    return
                }
            }
            
            self.text = self.text + text 
            self.text = String(self.text.prefix(5))
        }
        
        func deleteBackward() {
            _ = self.text.popLast()
        }
    }
    
    @Binding var text: String 
    @Binding var isActive: Bool
    @Binding var submitted: Bool
    
    func makeUIView(context: Context) -> InternalView {
        let result = InternalView(
            text: self.$text,
            submitted: self.$submitted,
            isActive: self.$isActive)
        
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
    
    func updateUIView(_ uiView: InternalView, context: Context) {
        
    }
}

struct EditableRow : View
{
    @State var word: String = ""
    @State var submitted: Bool = false
    
    let expected: String
    
    var body: some View { 
        if !submitted {
            KeyboardInput(text: self.$word, submitted: self.$submitted) {
                Row(model: RowModel(
                    word: self.word, 
                    expected: self.expected,
                    isSubmitted: self.submitted))
                
            }
        } else {
            Row(model: RowModel(
                word: self.word,
                expected: self.expected,
                isSubmitted: self.submitted))
        }
    }
}

struct KeyboardInput_Previews: PreviewProvider {
    static var previews: some View {
        EditableRow(expected: "fuels")
    }
}
