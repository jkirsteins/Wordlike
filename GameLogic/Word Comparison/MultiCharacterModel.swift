import SwiftUI

/// Represents a 1-tile:n-characters mapping (e.g. if we 
/// want to allow a tile to match either S or Š etc.)
struct MultiCharacterModel : Codable, Equatable, CustomDebugStringConvertible {
    /// There is no OrderedSet natively, so
    /// store the values in an array.
    ///
    /// Create a set on-the-fly when calculating 
    /// intersection.
    let values: Array<CharacterModel>
    
    static func single(_ letter: String, locale: Locale) -> MultiCharacterModel {
        MultiCharacterModel(CharacterModel(
            value: letter, locale: locale))
    }
    
    static func single(_ char: CharacterModel) -> MultiCharacterModel {
        MultiCharacterModel(char)
    }
    
    init(values: Array<CharacterModel>) {
        guard values.count > 0 else {
            fatalError("Character must have at least 1 value")
        }
        
        guard 
            let firstLocale = values.first?.locale,
            values.allSatisfy({ $0.locale == firstLocale })
        else {
            fatalError("All characters must have the same locale. Received: \(values.map { $0.locale.identifier }.joined(separator: ","))")
        
        }
        self.values = values
    }
    
    init(_ value: CharacterModel) {
        self.values = [ value ]
    }
    
    init(_ value: Character, locale: Locale) {
        self.values = [ CharacterModel(value: value, locale: locale) ]
    }
    
    init(_ values: String, locale: Locale) {
        self.values = Array(values).map {
            CharacterModel(value: $0, locale: locale)
        }
    }
    
    static func == (lhs: MultiCharacterModel, rhs: MultiCharacterModel) -> Bool {
        false == Set(lhs.values).intersection(Set(rhs.values)).isEmpty
    }
    
    var locale: Locale {
        guard 
            let firstLocale = self.values.first?.locale,
            self.values.allSatisfy({ $0.locale == firstLocale }) else {
                fatalError("All locales must be the same")
            } 
        
        return firstLocale
    }
    
    var debugDescription: String {
        let inner = self.values.map({ $0.debugDescription }).joined(separator: "|")
        return "[\(inner)]"
    }
    
    var displayValue: String {
        self.values.first?.displayValue ?? ""
    }
}

struct InternalMultiCharacterModelTests: View {
    let lvLV = Locale(identifier: "lv_LV")
    let enUS = Locale(identifier: "en_US")
    
    struct Comparison: View {
        let desc: String 
        let left: Set<String>
        let right: Set<String>
        let localeLeft: Locale
        let localeRight: Locale
        let shouldMatch: Bool
        
        var body: some View {
            let leftValues = left.map {CharacterModel(value: $0, locale: localeLeft)}
            let rightValues = right.map {CharacterModel(value: $0, locale: localeRight)}
            
            let leftM = MultiCharacterModel(values: leftValues)
            let rightM = MultiCharacterModel(values: rightValues)
            
            let match = leftM == rightM
            let good = (shouldMatch && match) || (!shouldMatch && !match) 
            
            return VStack(alignment: .leading) {
                Text("Comparison: \(desc)")
                Text(verbatim: "\(Set(leftM.values).intersection(Set(rightM.values)))")
                Text("\(leftM.debugDescription) \(match ? "==" : "!=") \(rightM.debugDescription )").foregroundColor(good ? .green : .red)
            }.border(.gray)
        }
    }
    
    struct TextComparison: View {
        let desc: String
        let left: String 
        let right: String
        let shouldMatch: Bool 
        
        var body: some View {
            let match = left == right
            let good = (shouldMatch && match) || (!shouldMatch && !match) 
            
            return VStack(alignment: .leading) {
                Text("Comparison: \(desc)")
                Text("\(left) \(match ? "==" : "!=") \(right.debugDescription )").foregroundColor(good ? .green : .red)
            }.border(.gray)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regular character tests").font(.largeTitle)
            
            Group {
                TextComparison(
                    desc: "Init with a String", 
                    left: MultiCharacterModel("AĀ", locale: lvLV).debugDescription, 
                    right: "[A[lv_LV]{a}|Ā[lv_LV]{ā}]", 
                    shouldMatch: true)
                
                TextComparison(
                    desc: ".displayValue should be the first", 
                    left: MultiCharacterModel("SŠ", locale: lvLV).displayValue, 
                    right: "S", 
                    shouldMatch: true)
                
                TextComparison(
                    desc: "Order should be deterministic", 
                    left: MultiCharacterModel("ABCD", locale: lvLV).debugDescription, 
                    right: "[A[lv_LV]{a}|B[lv_LV]{b}|C[lv_LV]{c}|D[lv_LV]{d}]", 
                    shouldMatch: true)
            }
            
            Group {
                Comparison(desc: "Simple match", left: ["A"], right: ["A"], localeLeft: lvLV, localeRight: lvLV, shouldMatch: true )
                Comparison(desc: "Simple mismatch", left: ["A"], right: ["B"], localeLeft: lvLV, localeRight: lvLV, shouldMatch: false)
                Comparison(desc: "Intersection mismatch", left: ["A", "B"], right: ["C", "D"], localeLeft: lvLV, localeRight: lvLV, shouldMatch: false)
                Comparison(desc: "Intersection match (case insensitive)", left: ["c", "B"], right: ["Z", "C"], localeLeft: lvLV, localeRight: lvLV, shouldMatch: true)
                Comparison(desc: "Intersection mismatch (diacritic sensitive)", left: ["c", "Z"], right: ["b", "Č"], localeLeft: lvLV, localeRight: lvLV, shouldMatch: false)
            }
        }
    }
}

struct InternalMultiCharacterModelTests_Previews: PreviewProvider {
    static var previews: some View {
        InternalMultiCharacterModelTests()
    }
}

