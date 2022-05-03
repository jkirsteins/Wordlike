import SwiftUI

struct WordModel : Codable, Equatable, CustomDebugStringConvertible {
    static func == (lhs: WordModel, rhs: WordModel) -> Bool {
        lhs.word == rhs.word
    }
    
    enum CodingKeys: String, CodingKey {
        case word 
    }
    
    let word: [MultiCharacterModel]
    
    init(_ word: String, locale: Locale) {
        self.word = word.map {
            MultiCharacterModel($0, locale: locale)
        }
    }
    
    init() {
        self.word = []
    }
    
    init(from decoder: Decoder) throws {
        
        do {
            // compatibility fallback for encoded Strings
            // assumes current locale
            let decodedString = try decoder.singleValueContainer().decode(String.self)
            let locale = Locale.current
            self.word = decodedString.map {
                MultiCharacterModel($0, locale: locale)
            }
        } catch {
            // properly encoded path
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.word = try values.decode([MultiCharacterModel].self.self, forKey: .word)
        }
        
        
    }
    
    init(characters: [MultiCharacterModel]) {
        self.word = characters
    }
    
    init(characters: [CharacterModel]) {
        self.word = characters.map { .single($0) }
    }
    
    var displayValue: String {
        self.word.map {
            $0.values.first?.value ?? ""
        }.joined()
    }
    
    var locale: Locale {
        // if word is empty, don't crash
        guard self.word.count > 0 else {
            return .current
        }
        
        guard let firstLocale = self.word.first?.locale,
              self.word.allSatisfy({ $0.locale == firstLocale }) else {
                  fatalError("All characters in a word must have the same locale.")
              }
        
        return firstLocale
    }
    
    var debugDescription: String {
        self.word.map({ $0.debugDescription }).joined(separator: "")
    }
    
    var isUnambiguous: Bool {
        self.word.allSatisfy { $0.values.count == 1 }
    }
    
    var count: Int {
        self.word.count
    }
    
    subscript(_ ix: Int) -> MultiCharacterModel {
        self.word[ix]
    }
    
    func dropLast() -> WordModel {
        WordModel(
            characters: word.dropLast())
    }
    
    func tryAdd(_ char: MultiCharacterModel) -> WordModel {
        WordModel(
            characters: Array((word + [char]).prefix(5)))
    }
    
    func contains(_ element: MultiCharacterModel) -> Bool {
        self.word.contains(element)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.word, forKey: .word)
    }
}

struct InternalWordModelTests: View {
    let lvLV = Locale(identifier: "lv_LV")
    let enUS = Locale(identifier: "en_US")
    
    struct Comparison: View {
        let desc: String 
        let left: WordModel?
        let right: WordModel?
        let shouldMatch: Bool
        
        var body: some View {
            let match = left == right
            let good = (shouldMatch && match) || (!shouldMatch && !match)
            
            return VStack(alignment: .leading) {
                Text("Comparison: \(desc)")
                Text(verbatim: "\(left?.debugDescription) \(match ? "==" : "!=") \(right?.debugDescription)").foregroundColor(good ? .green : .red)
            }.border(.gray)
        }
    }
    
    var body: some View {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let codeTest = WordModel("coder", locale: lvLV)
        
        let encoded = try! encoder.encode(codeTest)
        let decoded = try? decoder.decode(WordModel.self, from: encoded)
        
        let encodedString = try! encoder.encode("coder")
        let decodedFromString = try? decoder.decode(WordModel.self, from: encodedString)
        
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Regular character tests").font(.largeTitle)
            
            Group {
                Comparison(
                    desc: "Codable (from/to WordModel)", 
                    left: codeTest, 
                    right: decoded, 
                    shouldMatch: true)
                Comparison(
                    desc: "Codable (from String)", 
                    left: codeTest, 
                    right: decodedFromString, 
                    shouldMatch: true)
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
