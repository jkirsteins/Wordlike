import SwiftUI

class SimplifiedLatvianWordValidator : WordValidator
{
    init() {
        super.init(name: "lv")
    }
    
    /// Override to drop diacritics
    override func safeMatches(_ charA: Character, _ charB: Character) -> Bool {
        let a = String(charA).folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "lv_LV"))
        let b = String(charB).folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "lv_LV"))
        
        return a == b
    }
    
    /// Override to drop diacritics
    override func safeContains(_ word: String, _ requiredChar: String) -> Bool {
        let simpleWord = simplify(word)
        let simpleChar = simplify(requiredChar)
        return simpleWord.contains(simpleChar)
    }
    
    /// Validator protocol
    override func collapseHints(_ hints: Dictionary<String, TileBackgroundType>) -> Dictionary<String, TileBackgroundType> 
    {
        var result = Dictionary<String, TileBackgroundType>()
        
        let specialMap: Dictionary<String, String> = [
            "Ē": "E",
            "Ū": "U",
            "Ī": "I",
            "Ā": "A",
            "Š": "S",
            "Ģ": "G",
            "Ķ": "K",
            "Ļ": "L",
            "Ž": "Z",
            "Č": "C",
            "Ņ": "N"]
        
        let fold: ((String) -> String) = { x in 
            x.folding(options: .diacriticInsensitive, locale: Locale(identifier: "lv_LV"))
        }
        
        var specialValues = Dictionary<String, [TileBackgroundType]>()
        
        let storeSpecial: (String, TileBackgroundType)->() = { key, value in
            let folded = fold(key)
            var newVals = (specialValues[folded] ?? [])
            newVals.append(value)
            specialValues[folded] = newVals
        }
        
        // Store all values under a folded key
        for (key, val) in hints {
            storeSpecial(key, val)
        }
        
        // Now aggregate the results
        for key in specialValues.keys {
            let values = (specialValues[key] ?? [])
            
            if values.contains(TileBackgroundType.rightPlace) {
                // rightPlace should always be propogated
                result[key] = .rightPlace 
            } else if
                // wrongPlace should always be propogated
                // but not ahead of rightPlace
                values.contains(TileBackgroundType.wrongPlace) {
                    result[key] = .wrongPlace 
            } else if values.count == 2 {
                // if both diacritic/diacriticless values
                // are bad, propogate
                result[key] = values[0]
            } else if !specialMap.values.contains(key) && values.count > 0 {
                // if only 1 value present, only propogate
                // if it does not have a complement
                result[key] = values[0]
            } else {
                // this means a pair has only 1 value
                // and that 1 value is invalid, but we
                // can't assume that the complement is
                // also invalid.
                //
                // so skip.
            }
        }
        
        return result
    }
    
    /// NOTE: do NOT apply any simplifications here. 
    /// The dropping of diacritics should happen when
    /// validating/submitting a row, but once it is submitted,
    /// it should become the source of truth.
    ///
    /// Otherwise you would enable this type of bug:
    ///   - expect KAITE
    ///   - submit KAITĒ in hard mode
    ///   - switch to simplified mode
    ///   - board automatically considered as won, but
    ///     the word has Ē as a non-green square still
    override func accepts(_ word: String, as expected: String) -> Bool {
        super.accepts(word, as: expected)
    }
    
    override func canSubmit(
        word: String, 
        expected: String,
        model: [RowModel]?,
        reason: inout String?) -> String? {
        guard word.count == 5 else {
            reason = "Not enough letters"
            return nil
        } 
            
            guard super.validateRequirements(word: word, model: model, reason: &reason) else {
                return nil
            }
        
        if word.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) == expected.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) {
            return expected.uppercased()
        }
        
        let uppercaseExpected = expected.uppercased()
        let simplifiedSubmit = simplify(word.uppercased())
        
        let candidates = guesses.filter {
            simplify($0) == simplifiedSubmit
        }.map {
            ($0, countMatching(between: $0, and: uppercaseExpected))
        }
        
        guard let candidateResult = candidates.max(by: {
            $0.0 < $1.0
        }).map({ $0.0 }) else {
            reason = "Not in word list"
            return nil
        } 
        
        reason = nil
        return candidateResult
    }
    
    func countMatching(between word: String, and expected: String) -> Int {
        return word.reduce(0, {
            (res, char) in 
            
            if expected.contains(char) {
                return res + 1
            }
            
            return res
        })
    }
    
    func simplify(_ word: String) -> String {
        word.uppercased()
            .replacingOccurrences(of: "Ē", with: "E")
            .replacingOccurrences(of: "Ū", with: "U")
            .replacingOccurrences(of: "Ī", with: "I")
            .replacingOccurrences(of: "Ā", with: "A")
            .replacingOccurrences(of: "Š", with: "S")
            .replacingOccurrences(of: "Ģ", with: "G")
            .replacingOccurrences(of: "Ķ", with: "K")
            .replacingOccurrences(of: "Ļ", with: "L")
            .replacingOccurrences(of: "Ž", with: "Z")
            .replacingOccurrences(of: "Č", with: "C")
            .replacingOccurrences(of: "Ņ", with: "N")
    }
}

struct Internal_LatvianWordValidator_TestView: View {
    let validator = SimplifiedLatvianWordValidator()
    
    let answer: String 
    let word: String
    let okTestResult: String
    
    @State var reason: String? = nil
    
    @State var submittable: String? = nil
    
    var body: some View {
        body_in.onAppear {
            submittable = validator.canSubmit(word: word, expected: answer, model: nil, reason: &reason)
        }
    }
    
    @ViewBuilder
    var body_in: some View {
        if let submittable = submittable {
            Text(submittable).foregroundColor(submittable == okTestResult ? .green : .red)
        } else {
            Text("Can't submit: \(reason ?? "unknown reason")").foregroundColor(.red)
        }
    }
}

struct Internal_LatvianWordValidator_TestPreviews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            Text("SKILA should be submitted as ŠĶĪLA not ŠĶILA because expected word contains Ī")
            Internal_LatvianWordValidator_TestView(answer: "ZVĪŅA", word: "SKILA", okTestResult: "ŠĶĪLA")
        }
        
        VStack {
            Text("ZINAS should be accepted")
            Internal_LatvianWordValidator_TestView(answer: "ZVĪŅA", word: "ZINAS", okTestResult: "ZIŅĀS")
        }
        
        VStack {
            Text("We should always choose the answer word, if it matches the entered word")
            Internal_LatvianWordValidator_TestView(answer: "ZVĪŅA", word: "ZVINA", okTestResult: "ZVĪŅA")
            Internal_LatvianWordValidator_TestView(answer: "ZVĪŅĀ", word: "ZVINA", okTestResult: "ZVĪŅĀ")
        }
    }
}
