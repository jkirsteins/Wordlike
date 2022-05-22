import SwiftUI

struct PulseModifier: ViewModifier {
    
    @Binding var pulsing: Bool
    let maxScale: CGFloat
    let duration: Double
    
    @State var scale: CGFloat = 1.0
    
    /// Half of duration for each direction
    var halfDuration: TimeInterval {
        duration / 2.0
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .safeOnChange(of: pulsing) { np in
                
                withAnimation(
                    .easeInOut(duration: halfDuration)) {
                        scale = (np ? maxScale : 1.0) 
                    }
            }
            .onAnimationCompleted(for: scale) { 
                pulsing = false
            }
    }
}

extension View {
    func pulsing(
        pulsing: Binding<Bool>,
        maxScale: CGFloat = 1.1,
        duration: Double = 0.15) -> some View {
        self.modifier(
            PulseModifier(
                pulsing: pulsing,
                maxScale: maxScale,
                duration: duration
            )
        )
    }
}

struct PulseModifierTestView: View {
    @State var pulsing: Bool = false
    
    var body: some View {
        VStack(spacing: 48) {
        Text("Pulsing box")
            .frame(minWidth: 150, minHeight: 150)
            .border(Color.gray, width: 2)
            .pulsing(
                pulsing: $pulsing, 
                maxScale: 1.1,
                duration: 0.5)
            
            Text("Defaults")
                .frame(minWidth: 150, minHeight: 150)
                .border(Color.gray, width: 2)
                .pulsing(pulsing: $pulsing)
            
            Button("Pulse") {
                pulsing.toggle()
            }.disabled(pulsing)
        }
    }
}

struct PulseModifierTestView_Previews: PreviewProvider {
    static var previews: some View {
        PulseModifierTestView()
    }
}
