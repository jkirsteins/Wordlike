import SwiftUI

/// Represents a 1-tile:n-characters mapping (e.g. if we 
/// want to allow a tile to match either S or Š etc.)
struct MultiCharacterModel : Equatable, CustomDebugStringConvertible {
    let values: Set<CharacterModel>
    
    init(values: Set<CharacterModel>) {
        self.values = values
    }
    
    init(_ value: Character, locale: Locale) {
        self.values = Set([ CharacterModel(value: value, locale: locale) ])
    }
    
    init(_ values: String, locale: Locale) {
        self.values = Set(Array(values).map {
            CharacterModel(value: $0, locale: locale)
        })
    }
    
    static func == (lhs: MultiCharacterModel, rhs: MultiCharacterModel) -> Bool {
        false == lhs.values.intersection(rhs.values).isEmpty
    }
    
    var debugDescription: String {
        let inner = self.values.map({ $0.debugDescription }).joined(separator: "|")
        return "[\(inner)]"
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
            
            let leftM = MultiCharacterModel(values: Set(leftValues))
            let rightM = MultiCharacterModel(values: Set(rightValues))
            
            let match = leftM == rightM
            let good = (shouldMatch && match) || (!shouldMatch && !match) 
            
            return VStack(alignment: .leading) {
                Text("Comparison: \(desc)")
                Text(verbatim: "\(leftM.values.intersection(rightM.values))")
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

