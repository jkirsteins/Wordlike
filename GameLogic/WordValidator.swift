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
    func canSubmit(word: String, expected: String, reason: inout String?) -> String?
    
    /// Perform folding for a letter, which is used
    /// as the key for keyboard hints.
    ///
    /// E.g. normally you can return the same char. However
    /// a simplified language could return the same char
    /// with diacritics removed.
    func foldForHintKey(_ char: String) -> String 
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
    
    func canSubmit(word: String, expected: String, reason: inout String?) -> String? {
        fatalError()
    }
    
    func foldForHintKey(_ char: String) -> String {
        fatalError()
    }
}

class WordValidator : Validator, ObservableObject
{
    /// Validator protocol 
    func foldForHintKey(_ char: String) -> String
    {
        char
    }
    
    func accepts(_ word: String, as expected: String) -> Bool {
        word.uppercased() == expected.uppercased()
    }
    
    func answer(at turnIndex: Int) -> String {
        answers[turnIndex % answers.count]
    }
    
    func canSubmit(word: String, expected: String, reason: inout String?) -> String? {
        /* To avoid accidentally breaking input files,
         do some checks centrally (e.g. we can check length
         just here, instead of ensuring every input
         file doesn't contain an invalid short/empty line) */
        guard word.count == 5 else {
            reason = "Not enough letters"
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


