import SwiftUI

extension Array where Element == RowModel {
    func isWon(expected word: WordModel) -> Bool {
        self.first(where: {
            $0.isSubmitted && $0.word == word 
        }) != nil
    }
    
    var lastSubmitted: RowModel? {
        last { $0.isSubmitted }
    }
    
    var submittedCount: Int {
        self.filter({$0.isSubmitted}).count
    }
    
    /// Either won or lost, but all rows have been submitted
    func isFinished(expected word: WordModel) -> Bool  {
        self.isWon(expected: word) || self.submittedCount == 6
    }
    
    /// Check if rows abide by hard mode rules
    /// (doesn't verify if model is finished though)
    func checkHardMode(expected: WordModel) -> Bool {
        var wrongPlaces = Set<CharacterModel>()
        var rightPlaces: [Bool] = [
            false, false, false, false, false
        ]
        
        for row in self {
            guard row.isSubmitted else {
                break
            }
            
            // check expected before this row
            for e in wrongPlaces {
                if !row.word.contains(MultiCharacterModel(e)) {
                    return false
                }
            }
            
            // add expected from this row as 2nd step
            for ix in 0..<row.word.count {
                let rs = row.revealState(ix)
                if rs == .wrongPlace {
                    wrongPlaces.insert(row.word[ix].values[0])
                }
                
                if rs == .rightPlace {
                    rightPlaces[ix] = true
                }
                
                // check if we expect a .rightPlace...
                if rightPlaces[ix], row.word[ix] != expected.word[ix] {
                    return false
                }
            }
        }
        
        return true
    }
}

struct RowModel : Equatable, Codable, Identifiable
{
    enum CodingKeys: String, CodingKey {
        case id
        case word
        case isSubmitted
        case attemptCount
        case expected
    }
    
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
    
    var shareSnippet: String? {
        var result = ""
        guard self.isSubmitted else {
            return nil
        }
        
        for ix in 0..<self.word.count {
            result += self.revealState(ix).shareSymbol 
        }
        
        return result 
    }
    
    func char(guessAt pos: Int) -> MultiCharacterModel?
    {
        guard word.count > pos else { 
            return nil
        }
        return word[pos] 
    }
    
    func char(expectAt pos: Int) -> MultiCharacterModel?
    {
        guard expected.count > pos else { 
            return nil
        }
        return expected[pos]
    }
    
    /// Class for holding cached values that we know haven't/can't change
    /// but that might be asked for repeatedly.
    class BudgetCacheHolder: Equatable {
        static func == (lhs: RowModel.BudgetCacheHolder, rhs: RowModel.BudgetCacheHolder) -> Bool {
            lhs.yellowCache == rhs.yellowCache && lhs.revealCache == rhs.revealCache
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(yellowCache)
            hasher.combine(revealCache)
        }
        
        var yellowCache = Dictionary<WordModel, Dictionary<Int, Int>>()
        var revealCache = Dictionary<Int, TileBackgroundType>()
    }
    
    let budgetCache = BudgetCacheHolder()
    
    /* Yellow budget is:
     total_occurences - known_occurences - yellow_occurences_at_lower_ix
     */
    func yellowBudget(for attempt: WordModel, at atIx: Int) -> Int {
        if let wordCache = budgetCache.yellowCache[attempt],
           let budget = wordCache[atIx] {
            return budget
        }

        let val = calcYellowBudget(for: attempt, at: atIx)
        var wordCache = budgetCache.yellowCache[attempt] ?? [:]
        wordCache[atIx] = val
        budgetCache.yellowCache[attempt] = wordCache
        return val
    }
    
    /* Do not invoke this in a view body (only u se it to set state at
     points where you know the model has changed. */
    func calcYellowBudget(for attempt: WordModel, at atIx: Int) -> Int {
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
    
    func revealState(_ ix: Int) -> TileBackgroundType
    {
        guard !isSubmitted else {
            let result = self.budgetCache.revealCache[ix] ?? calcRevealState(ix)
            self.budgetCache.revealCache[ix] = result
            return result
        }
        
        return calcRevealState(ix)
    }
    
    /// Do not call this from a view body. Only use this to update state when you know the model has changed.
    func calcRevealState(_ ix: Int) -> TileBackgroundType {
        
        guard canReveal else {
            if nil != self.char(guessAt: ix) {
                return .maskedFilled
            }
            return .maskedEmpty
        }
        
        guard word.count > ix, expected.count > ix else {
            fatalError("Invalid index")
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
                
                Row(model: model)
                
                Text("Expected: ABABA")
                
                HStack {
                    ForEach(0..<5) { ix in
                        VStack {
                            Text(verbatim: "\(model.yellowBudget(for: WordModel("AAXAA", locale: Locale.current), at: ix))")
                            
                            Text(verbatim: "\(model.revealState(ix))")
                        }
                    }
                }
                
                Text("This should show green, yellow, black, black, green.")
            }
            
        }
    }
}
