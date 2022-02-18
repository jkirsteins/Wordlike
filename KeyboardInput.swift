import SwiftUI

struct KeyboardInput : View 
{
    @State var text: String = ""
    @State var isActive: Bool = false
    
    var body: some View {
        VStack {
            KeyboardInputUIKit(text: $text, isActive: $isActive)
            Text("Text: \(self.text)")
            Text("Active: \(String(describing: self.isActive))")
        }.border(self.isActive ? .red : .green)
    }
}

struct KeyboardInputUIKit: UIViewRepresentable {
    
    class InternalView: UIControl, UIKeyInput
    {
        @Binding var text: String
        @Binding var isActive: Bool
        
        init(text: Binding<String>, isActive: Binding<Bool>) {
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
            self.becomeFirstResponder()
        }
        
        var hasText: Bool {
            print("Is empty?", text.isEmpty)
            return text.isEmpty == false
        } 
        
        func insertText(_ text: String) {
            self.text += text
        }
        
        func deleteBackward() {
            _ = self.text.popLast()
        }
    }
    
    @Binding var text: String
    @Binding var isActive: Bool
    
    func makeUIView(context: Context) -> InternalView {
        return InternalView(
            text: self.$text,
            isActive: self.$isActive)
    }
    
    func updateUIView(_ uiView: InternalView, context: Context) {
        
    }
}

struct KeyboardInput_Previews: PreviewProvider {
    static var previews: some View {
        let ki = KeyboardInput()
        return VStack {
            ki
                .background(.green)
                .frame(maxWidth: 100, maxHeight: 100)
            
            TextField("Hello", text: Binding(
                get: { "Hello" },
                set: { _ in }
            ))
        }
    }
}
