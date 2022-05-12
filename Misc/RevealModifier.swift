import SwiftUI

struct RevealModifier<Revealed: View>: ViewModifier {
    
    let duration: Double
    let callback: ()->()
    let revealed: Revealed
    
    @State private var currentStep: Int = 0
    @State private var degrees: CGFloat = 0.0
    
    init(
        duration: Double, 
        callback: @escaping ()->(), 
        @ViewBuilder revealed: ()->Revealed) {
            self.duration = duration 
            self.callback = callback 
            self.revealed = revealed()
        }
    
    func degreesForStep(_ step: Int) -> CGFloat {
        
        max(
            0.0, 
            89.99 + (
                90.0 * CGFloat(step-1)
            )
        )
        
    }
    
    func anim(for step: Int) -> Animation {
        switch(step) {
        case 1:
            return .easeIn(duration: duration)
        case 2:
            return .easeOut(duration: duration)
        default:
            return .linear(duration: duration)
        }
        
    }
    
    func body(content: Content) -> some View {
        Group {
            if currentStep == 0 || currentStep == 1 {
                content
            } else {
                revealed
                    .rotation3DEffect(
                        .degrees(180), 
                        axis: (1, 0, 0), 
                        perspective: 0.0
                    )
            }
        }
        .onAnimationCompleted(for: degrees, completion: {
            guard currentStep < 2 else {
                callback()
                return
            }
            currentStep += 1
            withAnimation(anim(for: currentStep)) {
                degrees = degreesForStep(currentStep)
            }
        })
        .rotation3DEffect(
            .degrees(degrees), 
            axis: (1, 0, 0), 
            perspective: 0.0
        )
        .onAppear {
            currentStep = 1
            withAnimation(anim(for: currentStep)) 
            {
                degrees = degreesForStep(currentStep)
            }
        }
    }
}

struct TileModel {
    let letter: String 
    let state: TileBackgroundType
}

struct RevealModifierTestView: View {
    let from = TileModel(
        letter: "A", 
        state: .maskedFilled) 

    @State var to: TileModel? = nil
    @State var uuid = UUID()
    
    var body: some View {
        VStack(spacing: 24) {
            FlippableTile(
                letter: from, 
                flipped: to,
                flipCallback: {
                    to = nil
                    uuid = UUID()
                },
                action: {
                    print("Clicked")
                })
                .id(uuid)
            
            Button("Flip") {
                to = TileModel(
                    letter: "B", 
                    state: .rightPlace)
//                Tile(letter: "B", delay: 5, revealState: .rightPlace, animate: false)
            }
        }
    }
}

struct RevealModifier_Previews: PreviewProvider {
    static var previews: some View {
        RevealModifierTestView()
    }
}
