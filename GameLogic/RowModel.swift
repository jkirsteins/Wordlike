import SwiftUI

struct RowModel : Equatable, Codable, Identifiable
{
    let id: String
    let word: WordModel 
    let isSubmitted: Bool
    let attemptCount: Int
    let expected: WordModel
    
    init(expected: String, locale: Locale) {
        self.expected = WordModel(expected, locale: locale)
        self.word = WordModel("", locale: locale)
        self.id = "-\(expected)"
        self.isSubmitted = false
        self.attemptCount = 0
    }
    
    init(expected: WordModel) {
        self.expected = expected
        self.word = WordModel("", locale: expected.locale)
        self.id = "-\(expected)"
        self.isSubmitted = false
        self.attemptCount = 0
    }
    
    init(word: String, expected: String, isSubmitted: Bool, locale: Locale) {
        self.word = WordModel(word, locale: locale)
        self.expected = WordModel(expected, locale: locale)
        self.isSubmitted = isSubmitted
        self.attemptCount = 0
        self.id = "\(word)-\(expected)"
    }
    
    init(word: WordModel, expected: WordModel, isSubmitted: Bool) {
        self.word = word
        self.expected = expected
        self.isSubmitted = isSubmitted
        self.attemptCount = 0
        self.id = "\(word)-\(expected)"
    }
    
    init(word: String, expected: String, isSubmitted: Bool, attemptCount: Int, locale: Locale) {
        self.word = WordModel(word, locale: locale)
        self.expected = WordModel(expected, locale: locale)
        self.isSubmitted = isSubmitted
        self.attemptCount = attemptCount
        self.id = "\(word)-\(expected)"
    }
    
    init(word: WordModel, expected: WordModel, isSubmitted: Bool, attemptCount: Int) {
        self.word = word
        self.expected = expected
        self.isSubmitted = isSubmitted
        self.attemptCount = attemptCount
        self.id = "\(word)-\(expected)"
    }
    
    init(word: String, expected: WordModel, isSubmitted: Bool, attemptCount: Int) {
        self.word = WordModel(word, locale: expected.locale)
        self.expected = expected
        self.isSubmitted = isSubmitted
        self.attemptCount = attemptCount
        self.id = "\(word)-\(expected)"
    }
    
    var canReveal: Bool {
        isSubmitted
    }
    
    var focusHintIx: Int? {
        guard word.count < 5 else { return nil }
        return word.count
    }
    
    func char(guessAt pos: Int) -> MultiCharacterModel
    {
        guard word.count > pos else { 
            return .empty 
        }
        return word[pos] 
    }
    
    func char(expectAt pos: Int) -> MultiCharacterModel
    {
        guard expected.count > pos else { 
            return .empty
        }
        return expected[pos]
    }
    
    /* Yellow budget is:
     total_occurences - known_occurences - yellow_occurences_at_lower_ix
     */
    func yellowBudget(for attempt: WordModel, at atIx: Int) -> Int {
        var total: Int = 0
        var known: Int = 0
        var knownUntil: Int = 0
        
        let char = attempt[atIx] 
        
        for ix in 0..<self.expected.count { 
            if expected[ix] == char {
                total += 1
                
                if attempt[ix] == char {
                    known += 1
                }
            } else {
                if ix < atIx && attempt[ix] == char {
                    knownUntil += 1
                }
            }
        }
        
        return total - known - knownUntil
    }
    
    func revealState(_ ix: Int) -> TileBackgroundType?
    {
        guard canReveal else { return nil }
        
        guard word.count > ix, expected.count > ix else {
            return nil
        }
        
        // Green letters should always be represented
        // first. There's no non-failure scenario where
        // we want a correct letter to not appear green.
        if word[ix] == expected[ix] {
            return .rightPlace
        }
        
        // However, for yellow letters, we need to know
        // how many we can still reveal (e.g. 1 yellow
        // letters, 2 guesses ==> only 1 guess should 
        // be revealed as yellow)
        let budget = yellowBudget(for: word, at: ix)
        
        if expected.contains(word[ix]) && budget > 0 {
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
            isSubmitted: true,
            locale: Locale.current )
        
        return VStack {
            
            Text("Visual tests for the row model.").font(.title)
            Divider()
            
            VStack {
                
                Row(delayRowIx: 0, model: model)
                
                Text("Expected: ABABA")
                
                HStack {
                    ForEach(0..<5) { ix in
                        VStack {
                            Text(verbatim: "\(model.yellowBudget(for: WordModel("AAXAA", locale: Locale.current), at: ix))")
                            
                            Text(verbatim: "\(model.revealState(ix)!)")
                        }
                    }
                }
                
                Text("This should show green, yellow, black, black, green.")
            }
            
        }
    }
}
