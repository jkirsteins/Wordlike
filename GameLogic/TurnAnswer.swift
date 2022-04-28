import SwiftUI

/// Hold the turn's answer - word, current turn index, 
/// and the locale (all useful together for generating 
/// the share snippet)
struct TurnAnswer
{
    let word: String
    let day: Int
    let locale: GameLocale
    let validator: Validator
    
    init(word: String, day: Int, locale: GameLocale) {
        self.word = word 
        self.day = day 
        self.locale = locale 
        self.validator = WordValidator(locale: locale)
    }
    
    init(word: String, day: Int, locale: GameLocale, validator: Validator) {
        self.word = word 
        self.day = day 
        self.locale = locale 
        self.validator = validator
    }
}
