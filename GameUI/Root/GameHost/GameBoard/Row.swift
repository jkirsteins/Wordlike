import SwiftUI

/// See: https://www.objc.io/blog/2019/10/01/swiftui-shake-animation/
struct Shake: GeometryEffect {
    var amount: CGFloat = 4
    var shakesPerUnit = 6
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX:
                                                        amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                                                     y: 0))
    }
}

struct BlinkViewModifier: ViewModifier {
    
    let duration: Double
    @State private var blinking: Bool = false
    
    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration).repeatForever()) {
                        blinking = true
                    }
            }
    }
}

extension View {
    func blinking(duration: Double = 0.75) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
}

struct Row: View {
    
    var delayRowIx: Int
    var model: RowModel
    var showFocusHint: Bool 
    
    init(delayRowIx: Int, model: RowModel, showFocusHint: Bool) {
        self.delayRowIx = delayRowIx
        self.model = model 
        self.showFocusHint = showFocusHint
    }
    
    init(delayRowIx: Int, model: RowModel) {
        self.delayRowIx = delayRowIx
        self.model = model 
        self.showFocusHint = false
    }
    
    @Environment(\.horizontalSizeClass) 
    var horizontalSizeClass
    @Environment(\.verticalSizeClass) 
    var verticalSizeClass
    
    @Environment(\.gameLocale)
    var gameLocale: GameLocale
    
    /// If we have a small view, then spacing should be reduced
    /// (e.g. horizontal compact)i
    var hspacing: CGFloat {
        if verticalSizeClass == .compact {
            return GridPadding.compact
        } 
        
        return GridPadding.normal
    }
    
    var body: some View {
        HStack(spacing: hspacing) {
            // Poor way to get the animations
            // working when submission state triggers
            if model.isSubmitted {
                ForEach(0..<5) { ix in
                    Tile(
                        letter: model.char(
                            guessAt: ix).displayValue, 
                        delay: delayRowIx + ix,
                        revealState: model.revealState(ix),
                        animate: true)
                }
            } else {
                ForEach(0..<5) { ix in
                    Tile(
                        letter: model.char(
                            guessAt: ix).displayValue, 
                        delay: delayRowIx + ix,
                        revealState: model.revealState(ix),
                        animate: true
                    )
                        .environment(\.showFocusHint,
                                      showFocusHint && model.focusHintIx == ix)
                    
                }
            }
        }
        .contextMenu {
            if let defUrl = self.model.word.displayValue.definitionUrl(in: gameLocale) {
                Text(self.model.word.displayValue.uppercased())
                Link(destination: defUrl, label: {
                    Label("Look up", systemImage: "book")
                })
            } 
        }
        .modifier(Shake(animatableData: count))
        .onChange(of: model.attemptCount) {
            nc in 
            if nc > 0 {
                withAnimation(.linear(duration: 0.33)) {
                    self.count = CGFloat(nc)
                }
            } else {
                self.count = CGFloat(nc)
            }
        }
    }
    
    @State var count: CGFloat = 0.0
    
    //    let shakeDuration = 0.055
    let shakeDuration = 1.0
    let shakeRepeat = 1
}


fileprivate struct SubmittableRow_Preview: View
{
    @State var model = RowModel(
        word: WordModel("fuels", locale: .en_US),
        expected: WordModel("fuels", locale: .en_US),
        isSubmitted: false)
    
    var body: some View {
        VStack {
            Row(delayRowIx: 0, model: model)
            Button("Submit") {
                model = RowModel(
                    word: model.word,
                    expected: model.expected,
                    isSubmitted: true)
            }
        }
    }
}

fileprivate struct InvalidSubmittableRow_Preview: View
{
    @State var model = RowModel(
        word: WordModel("fuels", locale: .en_US),
        expected: WordModel("fuels", locale: .en_US),
        isSubmitted: false)
    
    var body: some View { 
        VStack {
            Row(delayRowIx: 0, model: model)
            
            Button("Submit Invalid (\(model.attemptCount))") {
                model = RowModel(
                    word: model.word,
                    expected: model.expected,
                    isSubmitted: false,
                    attemptCount: model.attemptCount + 1)
            }
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Test focus hint")
            PaletteSetterView {
                Row(delayRowIx: 0, model: RowModel(
                    word: WordModel("lad", locale: .en_US),
                    expected: WordModel("holly", locale: .en_US),
                    isSubmitted: false), showFocusHint: true)
            }
        }
        VStack {
            Text("Test yellow and green L")
            Row(delayRowIx: 0, model: RowModel(
                word: WordModel("ladle", locale: .en_US),
                expected: WordModel("holly", locale: .en_US),
                isSubmitted: true))
        }
        VStack {
            Row(delayRowIx: 0, model: RowModel(
                word: WordModel("fuels", locale: .en_US),
                expected: WordModel("fuels", locale: .en_US),
                isSubmitted: true))
            Row(delayRowIx: 1, model: RowModel(
                word: WordModel("fuels", locale: .en_US),
                expected: WordModel("hales", locale: .en_US),
                isSubmitted: true))
            
            VStack {
                Row(delayRowIx: 2, model: RowModel(
                    word: WordModel("aaxaa", locale: .en_US),
                    expected: WordModel("ababa", locale: .en_US),
                    isSubmitted: true))
                Text("This should show green, yellow, black, black, green.")
            }
            
            SubmittableRow_Preview()
            InvalidSubmittableRow_Preview()
        }
    }
}
