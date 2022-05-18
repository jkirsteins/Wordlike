import SwiftUI

struct UIButtonClose: UIViewRepresentable {
    let action: ()->() 
    
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(
            type: .close, 
            primaryAction: UIAction(
                title: "Close", 
                handler: { 
                    _ in action()
                }))
        
        return button
    }
    
    func updateUIView(_ button: UIButton, context: Context) {
        
    }
}

struct UIButtonClose_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UIButtonClose(action: {
                print("Test")
            })
                .frame(maxWidth: 32, maxHeight: 32)
        }
        .preferredColorScheme(.dark)
        
        VStack {
            UIButtonClose(action: {
                print("Test")
            })
                .frame(maxWidth: 32, maxHeight: 32)
            
        }.preferredColorScheme(.light)
    }
}
