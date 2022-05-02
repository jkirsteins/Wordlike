import SwiftUI

fileprivate func countDiacritics(_ word: String) -> Int {
    let without = word.folding(options: .diacriticInsensitive, locale: Locale(identifier: "lv_LV"))
    let withSet = Set(word)
    let withoutSet = Set(without)
    let common = withSet.intersection(withoutSet)
    return word.count - common.count
}

class SimplifiedLatvianWordValidator : WordValidator
{
    static let specialMap: Dictionary<String, String> = [
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
    
    init() {
        super.init(locale: .lv_LV(simplified: true))
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
        mustMatchKnown: Bool,    // e.g. hard mode
        reason: inout String?) -> String? {
            guard word.count == 5 else {
                reason = "Not enough letters"
                return nil
            } 
            
            guard 
                !mustMatchKnown || 
                    super.validateRequirements(word: word, model: model, reason: &reason) else {
                return nil
            }
            
            if word.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) == expected.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) {
                return expected.uppercased()
            }
            
            let uppercaseExpected = expected.uppercased()
            let simplifiedSubmit = simplify(word.uppercased())
            
            // 
            let knownBad: [String]
            if let model = model {
                knownBad = model.flatMap { row -> [String] in
                    (0..<row.wordArray.count).map { ix->String? in
                        if let rs = row.revealState(ix), rs == .wrongLetter {
                            return row.char(guessAt: ix)
                        } else {
                            return nil
                        }
                    }.filter { $0 != nil }.map { $0! }
                }
            } else {
                knownBad = []
            }
            
            let candidates = guesses.filter {
                // Simplified match
                guard simplify($0) == simplifiedSubmit else { 
                    return false 
                }
                
                // Reject if any known-bad letters are present in the match
                for l in knownBad {
                    if $0.contains(l) {
                        return false 
                    }
                }
                
                return true 
            }.map {
                ($0, countMatching(between: $0, and: uppercaseExpected), countDiacritics($0))
            }
            
            guard let candidateResult = candidates.max(by: {
                $0.1 < $1.1 || $0.2 < $0.2 
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
            submittable = validator.canSubmit(word: word, expected: answer, model: nil, mustMatchKnown: false, reason: &reason)
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

struct Internal_LatvianWordValidator_TestView_badSubstitution: View {
    let validator = SimplifiedLatvianWordValidator()
    
    // Submitting when it's unknown that a letter is bad
    @State var submittable_ok: String? = nil
    @State var reason_ok: String? = nil
    
    // Submitting when it's known that a letter is bad
    @State var submittable_nok: String? = nil
    @State var reason_nok: String? = nil
    
    var body: some View {
        body_in.onAppear {
            submittable_ok = validator.canSubmit(
                word: "SAĻTA", 
                expected: "SAIGA", 
                model: nil,
                mustMatchKnown: false, 
                reason: &reason_ok)
            submittable_nok = validator.canSubmit(
                word: "SAĻTA", 
                expected: "SAIGA", 
                model: [
                    RowModel(word: "SALNA", expected: "SAIGA", isSubmitted: true)
                ], 
                mustMatchKnown: false, 
                reason: &reason_nok)
        }
    }
    
    @ViewBuilder
    var body_in: some View {
        // Word should be submittable when we don't know
        // that the substitution letter is bad.
        if let submittable = submittable_ok {
            Text(submittable).foregroundColor(.green)
        } else {
            Text("Can't submit: \(reason_ok ?? "unknown reason")").foregroundColor(.red)
        }
        
        // If substitution happens, the word will be 
        // submittable (bad)
        //
        // Otherwise it will be rejected as unknown (good)
        if let submittable = submittable_nok {
            Text(submittable).foregroundColor(.red)
        } else {
            Text("Can't submit: \(reason_nok ?? "unknown reason")").foregroundColor(.green)
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
            Text("ZINAS should be accepted as ZIŅAS")
            Internal_LatvianWordValidator_TestView(answer: "ZVĪŅA", word: "ZINAS", okTestResult: "ZIŅAS")
        }
        
        VStack {
            Text("We should always choose the answer word, if it matches the entered word")
            Internal_LatvianWordValidator_TestView(answer: "ZVĪŅA", word: "ZVINA", okTestResult: "ZVĪŅA")
            Internal_LatvianWordValidator_TestView(answer: "ZVĪŅĀ", word: "ZVINA", okTestResult: "ZVĪŅĀ")
        }
        
        VStack {
            Text("We should always default to a word with less diacritics when possible")
            Text(verbatim: "Diacritics in KŅADĀ: \(countDiacritics("KŅADĀ"))")
            Internal_LatvianWordValidator_TestView(answer: "KROKA", word: "TORNI", okTestResult: "TORNI")
        }
        
        VStack {
            Text("We should not allow substituting a letter we know are wrong (e.g. if a word matches against L in 2nd spot, but L is known bad)")
            Internal_LatvianWordValidator_TestView_badSubstitution()
        }
    }
}
