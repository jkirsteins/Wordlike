import SwiftUI

/// Alphabet extensions
/// Used to check if a letter is valid in a given language
/// (e.g. when processing hardware keyboard)
extension String {
    static var uppercasedEnGbAlphabet = {
        Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { 
            CharacterModel(value: $0, locale: .en_GB) 
        }
    }()
    
    static var uppercasedEnUsAlphabet = {
        Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { 
            CharacterModel(value: $0, locale: .en_US) 
        }
    }()
    
    static var uppercasedFrAlphabet = {
        Array("AÁÀÂBCÇDEÉÈÊFGHIÎJKLMNOÔPQRSTUÙÛVWXYZ").map {
            CharacterModel(value: $0, locale: .fr_FR) 
        }
    }() 
    
    static var uppercasedLvAlphabet = {
        Array("AĀBCČDEĒFGĢHIĪJKĶLĻMNŅOPRSŠTUŪVZŽ").map {
            CharacterModel(value: $0, locale: .lv_LV)
        }
    }()
    
    static var uppercasedEeAlphabet = {
        Array("QWERTYUIOPASDFGHJKLÖÄZXCVBNMÜÕ").sorted().map {
            CharacterModel(value: $0, locale: .lv_LV)
        }
    }()
    
    static func uppercasedAlphabet(for locale: GameLocale) -> [CharacterModel] {
        switch(locale.nativeLocale.identifier) {
        case Locale.en_US.identifier:
            return uppercasedEnUsAlphabet
        case Locale.en_GB.identifier:
            return uppercasedEnGbAlphabet
        case Locale.fr_FR.identifier:
            return uppercasedFrAlphabet
        case Locale.lv_LV.identifier:
            return uppercasedLvAlphabet
        case Locale.ee_EE.identifier:
            return uppercasedEeAlphabet
        default:
            return []
        }
    }
}

/// For generating test words
extension String
{
    init(randomLength length: Int) {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        self = String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    /// Converts an ISO-8601 string (e.g. 2016-04-14T10:44:00+0000)
    /// to a `Date` instance.
    func toIsoDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from:self)!
    }
    
    /// Generate the URL to a page that provides
    /// the definition of the given word in the given
    /// locale (i.e. to a thesaurus page)
    func definitionUrl(in locale: GameLocale) -> URL? {
        let lowself = self.lowercased()
        switch(locale.nativeLocale.identifier) {
        case Locale.fr_FR.identifier:
            let stripped = lowself.folding(options: .diacriticInsensitive, locale: Locale(identifier: "FR"))
            
            return URL(string: "https://1mot.net/\(stripped)")
        case Locale.lv_LV.identifier:
            let encoded = lowself.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            return URL(string: "https://tezaurs.lv/\(encoded!)")
        case Locale.en_GB.identifier:
            return URL(string: "https://www.collinsdictionary.com/dictionary/english/\(lowself)")
        case Locale.en_US.identifier:
            return URL(string: "https://www.dictionary.com/browse/\(lowself)")
        default:    
            return nil
        }
    }
}

struct InternalDefinitionUrlTestView: View {
    let word: String
    let locale: GameLocale 
    
    var body: some View {
        VStack(spacing: 24) {
            VStack {
                Text(String(describing: locale))
                
                if let url = word.definitionUrl(in: locale) {
                    Text("\(url)")
                    Link(destination: url, label: {
                        Text("Define")
                    })
                } else {
                    Text("Can't define")
                }
                Divider()
            }
        }
    }
}

struct InternalDefinitionUrlTestView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InternalDefinitionUrlTestView(word: "ĀLAVA", locale: .lv_LV(simplified: false))
            InternalDefinitionUrlTestView(word: "FRÈRE", locale: .fr_FR)
            InternalDefinitionUrlTestView(word: "FUELS", locale: .en_US)
            InternalDefinitionUrlTestView(word: "CHIRT", locale: .en_GB)
        }
    }
}
