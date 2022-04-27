import SwiftUI

protocol Validator {
    /// Check if a word should be accepted as the expected
    /// (correct) answer.
    ///
    /// This can be a simple string equality, or it can
    /// do more (e.g. drop accents before comparing)
    func accepts(_ word: String, as expected: String) -> Bool
    
    /// Returns the answer for a given turn.
    func answer(at turnIndex: Int) -> String
    
    /// Checks if word can be submitted. 
    /// If not, sets the reason message.
    /// If so, returns a sanitized version that should
    /// be stored in the row.
    ///
    /// The sanitized version can help with e.g. ignoring
    /// accents while still preserving the right letters
    /// from the expected word.
    func canSubmit(
        word: String, 
        expected: String,
        model: [RowModel]?,
        reason: inout String?) -> String?
    
    /// Collapse the hints dictionary.
    /// Normally this can be a no-op, but in some cases
    /// (e.g. simplified Latvian) you might want to
    /// collapse green/yellow letter-with-diacritics onto
    /// a letter without diacritics.
    func collapseHints(_ hints: Dictionary<String, TileBackgroundType>) -> Dictionary<String, TileBackgroundType> 
}

/// Used as a temporary invalid value.
///
/// Every method invokes `fatalError()` to prevent 
/// accidental use.
class DummyValidator: Validator, ObservableObject {
    func accepts(_ word: String, as expected: String) -> Bool
    {
        fatalError()
    }
    
    func answer(at turnIndex: Int) -> String {
        fatalError()
    }
    
    func canSubmit(
        word: String, 
        expected: String,
        model: [RowModel]?,
        reason: inout String?) -> String? {
            fatalError()
        }
    
    func collapseHints(_ hints: Dictionary<String, TileBackgroundType>) -> Dictionary<String, TileBackgroundType> {
        fatalError()
    }
}

private var ordinalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

extension Int {
    var ordinal: String? {
        return ordinalFormatter.string(from: NSNumber(value: self))
    }
}

class WordValidator : Validator, ObservableObject
{
    static func letterNumberMsg(_ ix: Int) -> String {
        guard let ordinal = (ix+1).ordinal else {
            return "Letter \(ix+1)"
        }
        
        return "\(ordinal) letter"
    }
    
    /// Will only set reason if validation fails
    func validateRequirements(
        word: String,
        model: [RowModel]?, 
        reason: inout String?) -> Bool 
    {
        guard let model = model else {
            return true
        }
        
        var required = [String]()
        guard let expectedArray = model.first?.expectedArray else {
            fatalError("Row doesn't have an expected word.")
        }
        
        let wordArray = Array(word.uppercased())
        
        for row in model {
            for ix in 0..<row.wordArray.count {
                let revealState = row.revealState(ix)
                switch(revealState) {
                    case .rightPlace:
                    if !self.safeMatches(wordArray[ix], expectedArray[ix]) {
                        reason = "\(Self.letterNumberMsg(ix)) must be \(expectedArray[ix])"
                        return false
                    }
                    case .wrongPlace:
                    required.append(row.char(guessAt: ix))
                    default:
                    continue
                }
            }
        }
        
        for requiredChar in required {
            guard self.safeContains(word, requiredChar) else {
                reason = "Guess must contain \(requiredChar)"
                return false 
            }
        } 
        
        return true
    }
    
    /// Overloadable method to compare two characters
    /// (child classes might drop diacritics)
    func safeMatches(_ charA: Character, _ charB: Character) -> Bool {
        return charA == charB
    }
    
    /// Overloadable method to test if word contains a 
    /// character.
    /// (child classes might drop diacritics)
    func safeContains(_ word: String, _ requiredChar: String) -> Bool {
        word.contains(requiredChar)
    }
    
    /// Validator protocol 
    func collapseHints(_ hints: Dictionary<String, TileBackgroundType>) -> Dictionary<String, TileBackgroundType> 
    {
        hints
    }
    
    func accepts(_ word: String, as expected: String) -> Bool {
        word.uppercased() == expected.uppercased()
    }
    
    func answer(at turnIndex: Int) -> String {
        answers[turnIndex % answers.count]
    }
    
    func canSubmit(
        word: String, 
        expected: String,
        model: [RowModel]?,
        reason: inout String?) -> String? {
            /* To avoid accidentally breaking input files,
             do some checks centrally (e.g. we can check length
             just here, instead of ensuring every input
             file doesn't contain an invalid short/empty line) */
            guard word.count == 5 else {
                reason = "Not enough letters"
                return nil
            }
            
            guard validateRequirements(
                word: word, 
                model: model, 
                reason: &reason) else {
                    return nil
                }
            
            guard guesses.contains(word.uppercased()) else {
                reason = "Not in word list"
                return nil
            }
            
            reason = nil
            return word
        }
    
    /// Other stuff
    lazy var answers: [String] = self.loadAnswers()
    
    func loadAnswers() -> [String] {
        var random = ArbitraryRandomNumberGenerator(seed: UInt64(self.seed))
        
        return Self.load("\(name)_A").shuffled(using: &random)
    }
    
    lazy var guesses: [String] = self.loadGuesses()
    
    func loadGuesses() -> [String] {
        Self.load("\(name)_G")
    }
    
    static func load(_ name: String) -> [String] {
        do {
            guard let fileUrl = Bundle.main.url(forResource: name, withExtension: "txt") else { 
                fatalError("Data not found: \(name)") 
            }
            
            let text = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            return text.components(separatedBy: "\n").map {
                $0.uppercased()
            }
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    let name: String
    let seed: Int 
    
    /// Constant used as the start date of counting 
    /// the turns.
    /// TODO: move somewhere else
    static let MAR_22_2022 = Date(timeIntervalSince1970: 1647966002) 
    
    init(
        name: String, 
        seed: Int = 14384982345
    )
    {
        self.name = name
        self.seed = seed
    }
}

struct InternalLetterNumberMessageTest: View {
    var body: some View {
        VStack {
        Text(verbatim: "0 == \(WordValidator.letterNumberMsg(0)) ==> 1st")
            Text(verbatim: "2 == \(WordValidator.letterNumberMsg(2)) ==> 3rd")
            Text(verbatim: "21 == \(WordValidator.letterNumberMsg(21)) ==> 22nd")
        }
    }
}

struct InternalLetterNumberMessageTest_Previews: PreviewProvider {
    static var previews: some View {
        InternalLetterNumberMessageTest()
    }
}

