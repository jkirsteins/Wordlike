import SwiftUI

/// Represents a 1:1 case-insensitive mapping
/// to a character in a language.
struct CharacterModel : Equatable, Hashable, CustomDebugStringConvertible {
    let value: String
    let locale: Locale 
    
    init(value: String, locale: Locale) {
        self.value = value 
        self.locale = locale
    }
    
    init(value: Character, locale: Locale) {
        self.value = String(value) 
        self.locale = locale
    }
    
    /// Fold to a case-insensitive value for comparison. This
    /// should be sensitive to diacritics (if diacritic insensitivity is
    /// required, both options should be present in a MultiCharacterModel instead)
    var foldedValue: String {
        value.folding(options: .caseInsensitive, locale: locale)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(foldedValue)
    }
    
    var debugDescription: String {
        "\(value)[\(locale.identifier)]{\(foldedValue)}"
    }
    
    static func == (lhs: CharacterModel, rhs: CharacterModel) -> Bool {
        lhs.foldedValue == rhs.foldedValue
    }
}

struct InternalCharacterModelTests: View {
    let lvLV = Locale(identifier: "lv_LV")
    let enUS = Locale(identifier: "en_US")
    
    struct Comparison: View {
        let desc: String 
        let left: String
        let right: String
        let localeLeft: Locale
        let localeRight: Locale
        let shouldMatch: Bool
        
        var body: some View {
            let leftC = CharacterModel(value: left, locale: localeLeft)
            let rightC = CharacterModel(value: right, locale: localeRight)
            let match = leftC == rightC
            let good = (shouldMatch && match) || (!shouldMatch && !match)
            
            return VStack(alignment: .leading) {
                Text("Comparison: \(desc)")
                Text("\(leftC.debugDescription) \(match ? "==" : "!=") \(rightC.debugDescription)").foregroundColor(good ? .green : .red)
            }.border(.gray)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regular character tests").font(.largeTitle)
            
            Group {
                Comparison(desc: "Match", left: "A", right: "A", localeLeft: lvLV, localeRight: lvLV, shouldMatch: true)
                Comparison(desc: "Mismatch", left: "A", right: "b", localeLeft: lvLV, localeRight: lvLV, shouldMatch: false)
                Comparison(desc: "Case-insensitive match", left: "A", right: "a", localeLeft: lvLV, localeRight: lvLV, shouldMatch: true)
                Comparison(desc: "Diacritic-sensitive mismatch", left: "c", right: "č", localeLeft: lvLV, localeRight: lvLV, shouldMatch: false)
                Comparison(desc: "Cross-locale", left: "A", right: "a", localeLeft: lvLV, localeRight: enUS, shouldMatch: true)
            }
        }
    }
}

struct InternalCharacterModelTests_Previews: PreviewProvider {
    static var previews: some View {
        InternalCharacterModelTests()
    }
}
