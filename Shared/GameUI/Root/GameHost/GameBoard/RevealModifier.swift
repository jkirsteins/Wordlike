import SwiftUI

struct RevealConfig {
    /// Duration across all steps
    let totalDuration: Double
    let maxSteps: Int 
    let callbackStep: Int 
    let callback: (()->())
    let finalCallback: (()->())?
}

/// Modifier for flipping a view and revealing
/// a second view.
///
/// E.g. used by `FlippableTile`
struct RevealModifier<Revealed: View>: ViewModifier {
    
    let config: RevealConfig
    let revealed: Revealed
    
    @State private var currentStep: Int = 0
    @State private var alreadyAppeared = false
    @State private var degrees: CGFloat = 0.0
    
    init(config: RevealConfig, @ViewBuilder revealed: ()->Revealed) {
        self.config = config 
        self.revealed = revealed()
    }
    
    var maxSteps: Int {
        config.maxSteps
    }
    
    var duration: Double {
        guard maxSteps > 0 else {
            return config.totalDuration
        }
        
        return config.totalDuration / Double(maxSteps)
    }
    
    var callbackStep: Int {
        config.callbackStep
    }
    
    func degreesForStep(_ step: Int) -> CGFloat {
        // 2 steps => each part is 90 degrees
        // 4 steps => each part is 45 degrees
        let part = (180.0 / CGFloat(maxSteps))
        return max(
            0.0, 
            (part - 0.01) /* -0.01 to avoid identity matrix warnings */ + (
                part * CGFloat(step-1)
            )
        )
    }
    
    func anim(for step: Int) -> Animation {
        switch(step) {
        case 1:
            return .easeIn(duration: duration)
        case maxSteps:
            return .easeOut(duration: duration)
        default:
            return .easeInOut(duration: duration)
        }
    }
    
    var isFlipped: Bool {
        Double(currentStep) > (Double(maxSteps) / 2.0) 
    }
    
    func body(content: Content) -> some View {
        Group {
            if !isFlipped {
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
            let curStepAtStart = currentStep
            defer {
                if curStepAtStart == callbackStep {
                    config.callback()
                }
            }
            guard currentStep < maxSteps else {
                if currentStep == maxSteps {
                    config.finalCallback?()
                }
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
            guard !alreadyAppeared else { return }
            alreadyAppeared = true
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
    let justTyped: Bool 
    
    init() {
        self.letter = ""
        self.state = .maskedEmpty
        self.justTyped = false
    }
    
    init(letter: String, state: TileBackgroundType) {
        self.letter = letter 
        self.state = state 
        self.justTyped = false
    }
    
    init(
        letter: String, 
        state: TileBackgroundType, 
        justTyped: Bool) 
    {
        self.letter = letter 
        self.state = state 
        self.justTyped = justTyped
    }
}

struct RevealModifierTestView: View {
    let from = TileModel(
        letter: "A", 
        state: .maskedFilled) 

    @State var to: TileModel? = nil
    @State var uuid = UUID()
    @State var mid: Bool = false
    @State var duration = CGFloat(0.35)
    
    var body: some View {
        VStack(spacing: 24) {
            FlippableTile(
                letter: from, 
                flipped: to,
                tag: 0,
                jumpIx: nil,
                midCallback: {
                    mid = true
                },
                flipCallback: {
                    to = nil
                    mid = false
                    uuid = UUID()
                },
                jumpCallback: { _ in
                    
                },
                duration: duration,
                jumpDuration: 0.25)
                .id(uuid)
            
            Text("Duration: \(duration)")
            
            if mid == true {
                Text("Middle callback called").testColor(good: true)
            } 
            
            if mid != true {
                Text("Middle callback not called")
            }
            
            Button("Flip") {
                to = TileModel(
                    letter: "B", 
                    state: .rightPlace)
            }
        }
    }
}

struct RevealModifier_Previews: PreviewProvider {
    static var previews: some View {
        RevealModifierTestView()
    }
}
