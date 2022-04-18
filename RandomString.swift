import SwiftUI

/// For generating test words
extension String
{
    init(randomLength length: Int) {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        self = String((0..<length).map{ _ in letters.randomElement()! })
    }
}

extension String 
{
    func definitionUrl(in locale: String) -> URL? {
        let lowself = self.lowercased()
        switch(locale.uppercased()) {
        case "FR":
            let stripped = lowself.folding(options: .diacriticInsensitive, locale: Locale(identifier: "FR"))
            
            return URL(string: "https://1mot.net/\(stripped)")
        case "LV":
            let encoded = lowself.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            return URL(string: "https://tezaurs.lv/\(encoded!)")
        case "EN":
            return URL(string: "https://www.dictionary.com/browse/\(lowself)")
        default:    
            return nil
        }
    }
}

struct InternalDefinitionUrlTestView: View {
    let word: String
    let locale: String 
    
    var body: some View {
        VStack(spacing: 24) {
            VStack {
                Text(locale)
                
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
            InternalDefinitionUrlTestView(word: "ĀLAVA", locale: "lv")
            InternalDefinitionUrlTestView(word: "FRÈRE", locale: "fr")
            InternalDefinitionUrlTestView(word: "FUELS", locale: "en")
        }
    }
}
