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

struct Row: View {
    
    var delayRowIx: Int
    var model: RowModel
    
    var body: some View {
        HStack {
            // Poor way to get the animations
            // working when submission state triggers
            if model.isSubmitted {
                ForEach(0..<5) { ix in
                    Tile(
                        letter: model.char(guessAt: ix), 
                        delay: delayRowIx + ix,
                        revealState: model.revealState(ix),
                        animate: true)
                }
            } else {
                ForEach(0..<5) { ix in
                    Tile(
                        letter: model.char(guessAt: ix), 
                        delay: delayRowIx + ix,
                        revealState: model.revealState(ix),
                        animate: true)
                }
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
        word: "fuels",
        expected: "fuels",
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
        word: "fuels",
        expected: "fuels",
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
        return VStack {
            Row(delayRowIx: 0, model: RowModel(
                word: "fuels",
                expected: "fuels",
                isSubmitted: true))
            Row(delayRowIx: 1, model: RowModel(
                word: "fuels",
                expected: "hales",
                isSubmitted: true))
            
            VStack {
                Row(delayRowIx: 2, model: RowModel(
                    word: "aaxaa",
                    expected: "ababa",
                    isSubmitted: true))
                Text("This should show green, yellow, black, black, green.")
            }
            
            SubmittableRow_Preview()
            InvalidSubmittableRow_Preview()
        }
    }
}
