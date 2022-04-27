import SwiftUI

struct RowModel : Equatable, Codable, Identifiable
{
    let id: String
    let word: String 
    let isSubmitted: Bool
    let attemptCount: Int
    let expected: String
    
    init(expected: String) {
        self.expected = expected
        self.word = ""
        self.id = "-\(expected)"
        self.isSubmitted = false
        self.attemptCount = 0
    }
    
    init(word: String, expected: String, isSubmitted: Bool) {
        self.word = word
        self.expected = expected
        self.isSubmitted = isSubmitted
        self.attemptCount = 0
        self.id = "\(word)-\(expected)"
    }
    
    init(word: String, expected: String, isSubmitted: Bool, attemptCount: Int) {
        self.word = word
        self.expected = expected
        self.isSubmitted = isSubmitted
        self.attemptCount = attemptCount
        self.id = "\(word)-\(expected)"
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
    
    var focusHintIx: Int? {
        guard wordArray.count < 5 else { return nil }
        return wordArray.count
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
    
    /* Yellow budget is:
     total_occurences - known_occurences - yellow_occurences_at_lower_ix
     */
    func yellowBudget(for attemptArray: [Character], at atIx: Int) -> Int {
        var total: Int = 0
        var known: Int = 0
        var knownUntil: Int = 0
        
        let char = attemptArray[atIx] 
        
        for ix in 0..<self.expectedArray.count {
            if expectedArray[ix] == char {
                total += 1
                
                if attemptArray[ix] == char {
                    known += 1
                }
            } else {
                if ix < atIx && attemptArray[ix] == char {
                    knownUntil += 1
                }
            }
        }
        
        return total - known - knownUntil
    }
    
    func revealState(_ ix: Int) -> TileBackgroundType?
    {
        guard canReveal else { return nil }
        
        guard wordArray.count > ix, expectedArray.count > ix else {
            return nil
        }
        
        // Green letters should always be represented
        // first. There's no non-failure scenario where
        // we want a correct letter to not appear green.
        if wordArray[ix] == expectedArray[ix] {
            return .rightPlace
        }
        
        // However, for yellow letters, we need to know
        // how many we can still reveal (e.g. 1 yellow
        // letters, 2 guesses ==> only 1 guess should 
        // be revealed as yellow)
        let budget = yellowBudget(for: wordArray, at: ix)
        
        if expectedArray.contains(wordArray[ix]) && budget > 0 {
            return .wrongPlace
        }
        
        return .wrongLetter
    }
}

struct RowModel_Previews: PreviewProvider {
    static var previews: some View {
        let model = RowModel(
            word: "aaxaa",
            expected: "ababa",
            isSubmitted: true)
        
        return VStack {
            
            Text("Visual tests for the row model.").font(.title)
            Divider()
            
            VStack {
                
                Row(delayRowIx: 0, model: model)
                
                Text("Expected: ABABA")
                
                HStack {
                    ForEach(0..<5) { ix in
                        VStack {
                            Text(verbatim: "\(model.yellowBudget(for: Array("AAXAA"), at: ix))")
                            
                            Text(verbatim: "\(model.revealState(ix)!)")
                        }
                    }
                }
                
                Text("This should show green, yellow, black, black, green.")
            }
            
        }
    }
}
