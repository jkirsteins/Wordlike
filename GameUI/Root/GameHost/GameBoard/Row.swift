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

struct Row: View 
{
    let delayRowIx: Int
    let model: RowModel
    let showFocusHint: Bool
    
    let duration = CGFloat(0.25)
    
    /// Fully revealed
    @Binding var revealedCount: Int
    
    /// Can start next flip or next row
    @Binding var rowStartIx: Int
    @State var localFlipStartIx: Int = 0
    
    init(model: RowModel) {
        self.delayRowIx = 0
        self.model = model 
        self.showFocusHint = false
        self._revealedCount = .constant(0)
        self._rowStartIx = .constant(0)
    }
    
    init(delayRowIx: Int, model: RowModel, showFocusHint: Bool, revealedCount: Binding<Int>, rowStartIx: Binding<Int>) {
        self.delayRowIx = delayRowIx
        self.model = model 
        self.showFocusHint = showFocusHint
        self._revealedCount = revealedCount
        self._rowStartIx = rowStartIx
    }
    
    init(delayRowIx: Int, model: RowModel, revealedCount: Binding<Int>, rowStartIx: Binding<Int>) {
        self.delayRowIx = delayRowIx
        self.model = model 
        self.showFocusHint = false
        self._revealedCount = revealedCount
        self._rowStartIx = rowStartIx
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
    
    func maskedModel(at ix: Int) -> TileModel {
        let isEmpty = self.model.char(guessAt: ix) == .empty
        
        return TileModel(
            letter: model.char(guessAt: ix).displayValue,
            state: isEmpty ? .maskedEmpty : .maskedFilled
        )
    }
    
    var adjustedRevealThreshold: Int {
        delayRowIx * 5   
    }
    
    func canFlip(at ix: Int) -> Bool {
        guard ix > 0 else {
            return delayRowIx <= rowStartIx 
        } 
        
        return ix <= localFlipStartIx  
    }
    
    func flippedModel(at ix: Int) -> TileModel? {
        guard 
            canFlip(at: ix)
        else { 
            return nil 
        }
        
        let rs = self.model.revealState(ix)
        guard !rs.isMasked else { return nil } 
        
        return TileModel(
            letter: model.char(guessAt: ix).displayValue,
            state: rs
        )
    }
    
    var body: some View {
        HStack(spacing: hspacing) {
            ForEach(0..<5, id: \.self) { ix in
                FlippableTile(
                    letter: maskedModel(at: ix), 
                    flipped: flippedModel(at: ix),
                    midCallback: {
                        localFlipStartIx += 1
                        if (ix == 0) {
                            rowStartIx += 1
                        }
                    },
                    flipCallback: {
                        revealedCount += 1
                    },
                    duration: 0.35)
                    .environment(
                        \.showFocusHint,
                         showFocusHint && model.focusHintIx == ix)
//                    .id("\(ix)-\(canFlip(at: ix)))-tile")
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
                withAnimation(.linear(duration: 0.25)) {
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
            Row(model: model)
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
            Row(model: model)
            
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
                Row(model: RowModel(
                    word: WordModel("lad", locale: .en_US),
                    expected: WordModel("holly", locale: .en_US),
                    isSubmitted: false))
            }
        }
        VStack {
            Text("Test yellow and green L")
            Row(model: RowModel(
                word: WordModel("ladle", locale: .en_US),
                expected: WordModel("holly", locale: .en_US),
                isSubmitted: true))
        }
        VStack {
            Row(model: RowModel(
                word: WordModel("fuels", locale: .en_US),
                expected: WordModel("fuels", locale: .en_US),
                isSubmitted: true))
            Row(model: RowModel(
                word: WordModel("fuels", locale: .en_US),
                expected: WordModel("hales", locale: .en_US),
                isSubmitted: true))
            
            VStack {
                Row(model: RowModel(
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
