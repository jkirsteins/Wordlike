import SwiftUI

struct JumpModifier: ViewModifier {
    
    @Binding var jumping: Bool
    let maxDistance: CGFloat
    let duration: Double
    
    @State var distance: CGFloat = 0.0
    
    /// Half of duration for each direction
    var halfDuration: TimeInterval {
        duration / 2.0
    }
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State var stopAt: Date? = nil
    
    func body(content: Content) -> some View {
        content
            .offset(x: 0, y: distance)
            .safeOnChange(of: jumping) { np in
                withAnimation(
                    .easeOut(duration: halfDuration)) {
                        distance = (np ? -maxDistance : 0.0)
                        
                        if np {
                            stopAt = Date().addingTimeInterval(
                                duration/12.0)
                        }
                    }
            }
            .onAnimationCompleted(for: distance) { 
                jumping = false
            }
            .onReceive(timer) { t in
                guard let stopAt = stopAt, t > stopAt else {
                    return
                }
                jumping = false
            }
    }
}

extension View {
    func jumping(
        jumping: Binding<Bool>,
        maxDistance: CGFloat = 16.0,
        duration: Double = 0.15) -> some View {
            self.modifier(
                JumpModifier(
                    jumping: jumping,
                    maxDistance: maxDistance,
                    duration: duration
                )
            )
        }
}

struct JumpModifierTestView: View {
    @State var jumping: Bool = false
    
    var body: some View {
        VStack(spacing: 48) {
            Text("Jumping box")
                .frame(minWidth: 150, minHeight: 150)
                .border(Color.gray, width: 2)
                .jumping(
                    jumping: $jumping, 
                    maxDistance: 150.0,
                    duration: 5)
            
            Button("Jump") {
                jumping.toggle()
            }
            .disabled(jumping)
            .padding()
            .border(jumping ? .red : .gray)
        }
    }
}

struct JumpModifierTestView_Previews: PreviewProvider {
    static var previews: some View {
        JumpModifierTestView()
        
        Row(model: RowModel(word: WordModel("plain", locale: .en_US), expected: WordModel("plain", locale: .en_US), isSubmitted: true))
            .environmentObject(BoardRevealModel())
    }
}
