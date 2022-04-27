import SwiftUI

class LatvianWordValidator : WordValidator
{
    init() {
        super.init(name: "lv")
    }
    
    /// Validator protocol
    override func foldForHintKey(_ char: String) -> String {
        return char.folding(
            options: .diacriticInsensitive, 
            locale: Locale(identifier: "lv_LV")) 
    }
    
    override func accepts(_ word: String, as expected: String) -> Bool {
        return simplify(word) == simplify(expected)
    }
    
    override func canSubmit(word: String, expected: String, reason: inout String?) -> String? {
        guard word.count == 5 else {
            reason = "Not enough letters"
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
    let validator = LatvianWordValidator()
    
    let answer: String 
    let word: String
    let okTestResult: String
    
    @State var reason: String? = nil
    
    @State var submittable: String? = nil
    
    var body: some View {
        body_in.onAppear {
            submittable = validator.canSubmit(word: word, expected: answer, reason: &reason)
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
