import SwiftUI

struct KeyboardInput<Content: View> : View 
{
    @Binding var text: String?
    @State var isActive: Bool = false
    
    let content: Content 
        
    init(text: Binding<String?>, @ViewBuilder _ content: ()->Content) {
        self._text = text
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            KeyboardInputUIKit(text: $text, isActive: $isActive)
            
            
        }.border(self.isActive ? .red : .green)
    }
}

struct KeyboardInputUIKit: UIViewRepresentable {
    
    class InternalView: UIControl, UIKeyInput
    {
        @Binding var text: String?
        @Binding var isActive: Bool
        
        init(text: Binding<String?>, isActive: Binding<Bool>) {
            self._text = text
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
            print("Can become?")
            return true
        }
        
        @objc private func onTap(_: AnyObject) {
            _ = self.becomeFirstResponder()
        }
        
        var hasText: Bool {
            return text?.isEmpty == false
        } 
        
        func insertText(_ text: String) {
            let set = CharacterSet.letters
            for chr in text { 
                guard chr.isLetter else {
                    print("\(chr) not allowed")
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
    
    func makeUIView(context: Context) -> InternalView {
        return InternalView(
            text: self.$text,
            isActive: self.$isActive)
    }
    
    func updateUIView(_ uiView: InternalView, context: Context) {
        
    }
}

struct EditableRow : View
{
    @State var word: String? = "2"
    
    var body: some View { 
        KeyboardInput(text: self.$word) {
            VStack {  
                Row(word: self.$word)
                Text(self.word ?? "none")
            }
        }
    }
}

struct KeyboardInput_Previews: PreviewProvider {
    static var previews: some View {
        EditableRow()
    }
}
