import SwiftUI

struct Row: View {
    
    var model: RowModel
    
    var body: some View {
        HStack {
            // Poor way to get the animations
            // working when submission state triggers
            if model.isSubmitted {
                ForEach(0..<5) { ix in
                    Tile(
                        letter: model.char(guessAt: ix), 
                        delay: ix,
                        revealState: model.revealState(ix))
                }
            } else {
                ForEach(0..<5) { ix in
                    Tile(
                        letter: model.char(guessAt: ix), 
                        delay: ix,
                        revealState: model.revealState(ix))
                }
            }
        }
    }
}

fileprivate struct SubmittableRow_Preview: View
{
    @State var model = RowModel(
        word: "fuels",
        expected: "fuels",
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

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        return VStack {
            Row(model: RowModel(
                word: "fuels",
                expected: "fuels",
                isSubmitted: true))
            Row(model: RowModel(
                word: "fuels",
                expected: "hales",
                isSubmitted: true))
            
            SubmittableRow_Preview()
        }
    }
}
