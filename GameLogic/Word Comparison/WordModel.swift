import SwiftUI

struct WordModel : Equatable, CustomDebugStringConvertible {
    let word: [MultiCharacterModel]
    
    init(_ word: String, locale: Locale) {
        self.word = word.map {
            MultiCharacterModel($0, locale: locale)
        }
    }
    
    init(characters: [MultiCharacterModel]) {
        self.word = characters
    }
    
    var debugDescription: String {
        self.word.map({ $0.debugDescription }).joined(separator: "")
    }
    
    static func == (lhs: WordModel, rhs: WordModel) -> Bool {
        lhs.word == rhs.word
    }
}

struct InternalWordModelTests: View {
    let lvLV = Locale(identifier: "lv_LV")
    let enUS = Locale(identifier: "en_US")
    
    struct Comparison: View {
        let desc: String 
        let left: WordModel
        let right: WordModel
        let shouldMatch: Bool
        
        var body: some View {
            let match = left == right
            let good = (shouldMatch && match) || (!shouldMatch && !match)
            
            return VStack(alignment: .leading) {
                Text("Comparison: \(desc)")
                Text("\(left.debugDescription) \(match ? "==" : "!=") \(right.debugDescription)").foregroundColor(good ? .green : .red)
            }.border(.gray)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regular character tests").font(.largeTitle)
            
            Group {
                Comparison(
                    desc: "Case-insensitive match", 
                    left: WordModel("acorn", locale: enUS), 
                    right: WordModel("ACORN", locale: enUS), 
                    shouldMatch: true)
                Comparison(
                    desc: "Mismatch", 
                    left: WordModel("acorn", locale: enUS), 
                    right: WordModel("blues", locale: enUS), 
                    shouldMatch: false)
                Comparison(
                    desc: "Diacritic insensitive match", 
                    left: WordModel(characters: [
                        MultiCharacterModel("šs", locale: lvLV),
                        MultiCharacterModel("a", locale: lvLV),
                        MultiCharacterModel("u", locale: lvLV),
                        MultiCharacterModel("r", locale: lvLV),
                        MultiCharacterModel("s", locale: lvLV),
                    ]), 
                    right: WordModel("saurs", locale: lvLV), 
                    shouldMatch: true)
                Comparison(
                    desc: "Diacritic sensitive mismatch", 
                    left: WordModel("šaurs", locale: enUS), 
                    right: WordModel("saurs", locale: enUS), 
                    shouldMatch: false)
            }
        }
    }
}

struct InternalWordModelTests_Previews: PreviewProvider {
    static var previews: some View {
        InternalWordModelTests()
    }
}
