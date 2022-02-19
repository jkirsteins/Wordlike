import SwiftUI

struct KeyboardInput<Content: View> : View 
{
    @Binding var text: String?
    @Binding var submitted: Bool
    
    @State var isActive: Bool = false
    
    let content: Content 
        
    init(text: Binding<String?>, submitted: Binding<Bool>, @ViewBuilder _ content: ()->Content) {
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
        @Binding var text: String?
        @Binding var submitted: Bool
        @Binding var isActive: Bool
        
        init(text: Binding<String?>, submitted: Binding<Bool>, isActive: Binding<Bool>) {
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
        
        override var canBecomeFirstResponder: Bool {
            return true
        }
        
        @objc private func onTap(_: AnyObject) {
            _ = self.becomeFirstResponder()
        }
        
        var hasText: Bool {
            return text?.isEmpty == false
        } 
        
        func insertText(_ text: String) {
            for chr in text { 
                guard chr.isLetter else {
                    if chr == "\n" && self.text?.count == 5 {
                        self.submitted = true
                    }
                    
                    return
                }
            }
            
            self.text = (self.text ?? "") + text 
            self.text = String(self.text!.prefix(5))
        }
        
        func deleteBackward() {
            _ = self.text?.popLast()
        }
    }
    
    @Binding var text: String? 
    @Binding var isActive: Bool
    @Binding var submitted: Bool
    
    func makeUIView(context: Context) -> InternalView {
        return InternalView(
            text: self.$text,
            submitted: self.$submitted,
            isActive: self.$isActive)
    }
    
    func updateUIView(_ uiView: InternalView, context: Context) {
        
    }
}

struct EditableRow : View
{
    @State var word: String? = nil
    @State var submitted: Bool = false
    
    var body: some View { 
        if !submitted {
            KeyboardInput(text: self.$word, submitted: self.$submitted) {
                Row(word: self.$word)
            }
        } else {
            Row(word: self.$word)
        }
    }
}

struct KeyboardInput_Previews: PreviewProvider {
    static var previews: some View {
        EditableRow()
    }
}
