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
        switch(locale.uppercased()) {
        case "FR":
            return URL(string: "https://1mot.net/\(self)")!
        case "LV":
            return URL(string: "https://tezaurs.lv/\(self)")!
        case "EN":
            return URL(string: "https://www.dictionary.com/browse/\(self)")
        default:    
            return nil
        }
    }
}
