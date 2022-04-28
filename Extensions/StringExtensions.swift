import SwiftUI

/// Alphabet extensions
/// Used to check if a letter is valid in a given language
/// (e.g. when processing hardware keyboard)
extension String {
    static var uppercasedEnAlphabet = {
        Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
    }() 
    
    static var uppercasedFrAlphabet = {
        // ÏËÜ should not be in the word list
        Array("AÁÀÂBCÇDEÉÈÊFGHIÎJKLMNOÔPQRSTUÙÛVWXYZ").map {
            String($0) 
        }
    }() 
    
    static var uppercasedLvAlphabet = {
        Array("AĀBCČDEĒFGĢHIĪJKĶLĻMNŅOPRSŠTUŪVZŽ").map {
            String($0) 
        }
    }() 
    
    static func uppercasedAlphabet(for locale: GameLocale) -> [String] {
        switch(locale) {
        case .en_US, .en_GB:
            return uppercasedEnAlphabet
        case .fr_FR:
            return uppercasedFrAlphabet
        case .lv_LV(_):
            return uppercasedLvAlphabet
        default:
            return []
        }
    }
    
    /// Check if first comes before second, given
    /// the alphabet of a specific locale
    static func orderAsAlphabet(first: String, second: String, locale: GameLocale) -> Bool {
        
        let firstC = first.uppercased()
        let secondC = second.uppercased()
        
        let alphabet = String.uppercasedAlphabet(for: locale)
        
        guard let firstIx = alphabet.firstIndex(of: firstC), let secondIx = alphabet.firstIndex(of: secondC) else {
            // fallback
            return first < second
        }
        
        return firstIx < secondIx
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
        switch(locale) {
        case .fr_FR:
            let stripped = lowself.folding(options: .diacriticInsensitive, locale: Locale(identifier: "FR"))
            
            return URL(string: "https://1mot.net/\(stripped)")
        case .lv_LV(_):
            let encoded = lowself.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            return URL(string: "https://tezaurs.lv/\(encoded!)")
        case .en_US, .en_GB:
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
            InternalDefinitionUrlTestView(word: "FUELS", locale: .en_GB)
        }
    }
}
