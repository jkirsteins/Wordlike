import SwiftUI

struct RowModel : Equatable
{
    let word: String 
    let isSubmitted: Bool
    let expected: String
    
    init(expected: String) {
        self.expected = expected
        self.word = ""
        self.isSubmitted = false
    }
    
    init(word: String, expected: String, isSubmitted: Bool) {
        self.word = word
        self.expected = expected
        self.isSubmitted = isSubmitted
    }
    
    var expectedArray: [String.Element] {
        Array(expected.uppercased())
    }
    
    var wordArray: [String.Element] {
        Array(word.uppercased())
    }
    
    var canReveal: Bool {
        isSubmitted
    }
    
    func char(guessAt pos: Int) -> String
    {
        guard wordArray.count > pos else { return "" }
        return String(wordArray[pos])
    }
    
    func char(expectAt pos: Int) -> String
    {
        guard expectedArray.count > pos else { return "" }
        return String(expectedArray[pos])
    }
    
    func revealState(_ ix: Int) -> TileBackgroundType?
    {
        guard canReveal else { return nil }
        
        let wordArray = Array(word)
        let expectedArray = Array(expected)
        
        guard wordArray.count > ix, expectedArray.count > ix else {
            return nil
        }
        
        if wordArray[ix] == expectedArray[ix] {
            return .rightPlace
        }
        
        if expected.contains(wordArray[ix]) {
            return .wrongPlace
        }
        
        return .wrongLetter
    }
}

struct Row: View {
    
    var model: RowModel
    
    var body: some View {
        HStack {
            ForEach(0..<5) { ix in
                Tile(
                    letter: model.char(guessAt: ix), 
                    delay: ix,
                    revealState: model.revealState(ix))
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
            Row(model: RowModel(
                word: "fuels",
                expected: "fuels",
                isSubmitted: false))
        }
    }
}
