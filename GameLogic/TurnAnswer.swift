import SwiftUI

/// Hold the turn's answer - word, current turn index, 
/// and the locale (all useful together for generating 
/// the share snippet)
struct TurnAnswer
{
    let word: String
    let day: Int
    let locale: String
    let validator: Validator
    
    init(word: String, day: Int, locale: String) {
        self.word = word 
        self.day = day 
        self.locale = locale 
        self.validator = WordValidator(name: locale)
    }
    
    init(word: String, day: Int, locale: String, validator: Validator) {
        self.word = word 
        self.day = day 
        self.locale = locale 
        self.validator = validator
    }
}
