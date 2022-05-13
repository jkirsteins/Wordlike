import SwiftUI

fileprivate class ViewModel : ObservableObject
{
    @Published var localRevealedCount: Int = 0
    @Published var localFlipStartIx: Int = 0
    @Published var jumpIx: Int? = nil
}

struct Row: View 
{
    let delayRowIx: Int
    let model: RowModel
    let showFocusHint: Bool
    
    // Duration for reveal
    let duration = CGFloat(0.25)
    
    @StateObject fileprivate var vm = ViewModel()
    
    @EnvironmentObject 
    var boardReveal: BoardRevealModel
    
    init(model: RowModel) {
        self.delayRowIx = 0
        self.model = model 
        self.showFocusHint = false
    }
    
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
    
    func maskedModel(at ix: Int) -> TileModel? {
        guard 
            let model = self.model.char(guessAt: ix)
        else {
            return nil
        }
        
        return TileModel(
            letter: model.displayValue, 
            state: .maskedFilled)
    }
    
    var adjustedRevealThreshold: Int {
        delayRowIx * 5   
    }
    
    func canFlip(at ix: Int) -> Bool {
        guard ix > 0 else {
            return delayRowIx <= boardReveal.rowStartIx 
        } 
        
        return ix <= vm.localFlipStartIx  
    }
    
    func flippedModel(at ix: Int) -> TileModel? {
        guard 
            canFlip(at: ix)
        else { 
            return nil 
        }
        
        let rs = self.model.revealState(ix)
        guard 
            !rs.isMasked,
            let fm = model.char(guessAt: ix)
        else { 
            return nil 
        } 
        
        return TileModel(
            letter: fm.displayValue,
            state: rs
        )
    }
    
    var body: some View {
        HStack(spacing: hspacing) {
            ForEach(0..<5, id: \.self) { ix in
                FlippableTile(
                    letter: maskedModel(at: ix), 
                    flipped: flippedModel(at: ix),
                    tag: ix,
                    jumpIx: vm.jumpIx,
                    midCallback: {
                        vm.localFlipStartIx += 1
                        if (ix == 0) {
                            boardReveal.rowStartIx += 1
                        }
                    },
                    flipCallback: {
                        boardReveal.revealedCount += 1
                        vm.localRevealedCount += 1
                    },
                    jumpCallback: { ji in
                        guard  ji < 4 else {
                            boardReveal.didFinish = true
                            vm.jumpIx = nil
                            return
                        }
                        
                        vm.jumpIx = ji + 1
                    },
                    duration: duration)
                    
                    .environment(
                        \.showFocusHint,
                         showFocusHint && model.focusHintIx == ix)
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
        .onReceive(
            self.vm.$localRevealedCount.debounce(for: 0.1, scheduler: DispatchQueue.main)
        ) {
            nrc in 
            
            guard 
                nrc == 5
                    else {
                        return
                    }
            
            // All tiles are revealed
            self.boardReveal.didEarlyFinish = true 
            
            guard 
                self.model.expected == self.model.word 
            else {
                // If word is not right, it's also
                // the full finish.
                self.boardReveal.didFinish = true
                return
            }
            
            self.vm.jumpIx = 0
        }
    }
    
    @State var count: CGFloat = 0.0
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
    static let st = BoardRevealModel()
    static var previews: some View {
        VStack {
            Text("Test focus hint")
            PaletteSetterView {
                Row(model: RowModel(
                    word: WordModel("lad", locale: .en_US),
                    expected: WordModel("holly", locale: .en_US),
                    isSubmitted: false))
            }
        }.environmentObject(st)
        VStack {
            Text("Test yellow and green L")
            Row(model: RowModel(
                word: WordModel("ladle", locale: .en_US),
                expected: WordModel("holly", locale: .en_US),
                isSubmitted: true))
        }.environmentObject(st)
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
        }.environmentObject(st)
    }
}
