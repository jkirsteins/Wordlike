import SwiftUI

struct RowModel : Equatable, Codable, Identifiable
{
    let id: String
    let word: String 
    let isSubmitted: Bool
    let expected: String
    
    init(expected: String) {
        self.expected = expected
        self.word = ""
        self.id = "-\(expected)"
        self.isSubmitted = false
    }
    
    init(word: String, expected: String, isSubmitted: Bool) {
        self.word = word
        self.expected = expected
        self.isSubmitted = isSubmitted
        self.id = "\(word)-\(expected)"
    }
    
    var expectedArray: [String.Element] {
        Array(expected.uppercased())
    }
    
    var wordArray: [String.Element] {
        Array(word.uppercased())
    }
    
    var canReveal: Bool {
        isSubmitted
    }
    
    func char(guessAt pos: Int) -> String
    {
        guard wordArray.count > pos else { return "" }
        return String(wordArray[pos])
    }
    
    func char(expectAt pos: Int) -> String
    {
        guard expectedArray.count > pos else { return "" }
        return String(expectedArray[pos])
    }
    
    func revealState(_ ix: Int) -> TileBackgroundType?
    {
        guard canReveal else { return nil }
        
        guard wordArray.count > ix, expectedArray.count > ix else {
            return nil
        }
        
        if wordArray[ix] == expectedArray[ix] {
            return .rightPlace
        }
        
        if expected.contains(wordArray[ix]) {
            return .wrongPlace
        }
        
        return .wrongLetter
    }
}

