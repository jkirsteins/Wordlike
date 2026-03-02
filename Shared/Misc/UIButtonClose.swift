import SwiftUI

#if os(iOS)
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
        
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }
    
    func updateUIView(_ button: UIButton, context: Context) {
        
    }
}
#elseif os(macOS)
struct UIButtonClose: View {
    let action: ()->()
    
    var body: some View {
        Button("Close") {
            action()
        }
    }
}
#endif

#if os(iOS) || os(macOS)
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
#endif
