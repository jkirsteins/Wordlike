import SwiftUI

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
    
    static func uppercasedAlphabet(for locale: String) -> [String] {
        if locale == "en" {
            return uppercasedEnAlphabet
        } 
        else if locale == "fr" {
            return uppercasedFrAlphabet
        } else if locale == "lv" {
            return uppercasedLvAlphabet
        }
        
        return []
    }
    
    /// Check if first comes before second, given
    /// the alphabet of a specific locale
    static func orderAsAlphabet(first: String, second: String, locale: String) -> Bool {
        
        let firstC = first.uppercased()
        let secondC = second.uppercased()
        
        let alphabet = String.uppercasedAlphabet(for: locale )
        
        guard let firstIx = alphabet.firstIndex(of: firstC), let secondIx = alphabet.firstIndex(of: secondC) else {
            // fallback
            return first < second
        }
        
        return firstIx < secondIx
    }
}

struct KeyboardHintView: View {
    let hints: KeyboardHints
    
    var orderedKeys: [String] {
        let alphabet = String.uppercasedAlphabet(for: hints.locale)
        return alphabet.sorted(by: {
            first, second in 
            
            let firstType = hints.hints[first]
            let secondType = hints.hints[second]
            
            // Sort green in the beginning
            if firstType == .rightPlace {
                if secondType == .rightPlace {
                    return String.orderAsAlphabet(first: first, second: second, locale: hints.locale)
                }
                
                return true 
            }
            
            // Sort yellow subsequently
            if firstType == .wrongPlace {
                if secondType == .rightPlace {
                    return false 
                }
                
                if secondType == .wrongPlace {
                    return String.orderAsAlphabet(first: first, second: second, locale: hints.locale) 
                }
                
                return true 
            }
            
            if secondType == .wrongPlace || 
                secondType == .rightPlace {
                return false
            }
            
            return String.orderAsAlphabet(first: first, second: second, locale: hints.locale)  
        }).filter {
            // Exclude known bad letters
            hints.hints[$0] != .wrongLetter
        }
    }
    
    var body: some View {
        if hints.hints.isEmpty {
            Text("You haven't guessed any letters yet.")
        }
        else {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(orderedKeys, id: \.self) {
                        key in 
                        
                        VStack {
                            Tile(
                                letter: key,
                                delay: 0,
                                revealState: hints.hints[key],
                                animate: false)
                        }
                    }
                }
            }
        }
    }
}

struct KeyboardHints_TestView: View {
    let state: GameState 
    
    var body: some View {
        return VStack {
            ForEach([state]) {
                st in 
                VStack {
                    Text(verbatim: st.expected.word.uppercased())
                        .font(.largeTitle)
                    
                    VStack {
                        Text("Submitted rows")
                        ForEach(st.rows.filter({ $0.isSubmitted })) {
                            rowModel in 
                            
                            Row(delayRowIx: 0, model: rowModel)
                        }
                    }
                    
                    VStack {
                        Text("Hints")
                        
                        KeyboardHintView(
                            hints: state.keyboardHints)
                    }
                }
            }
        }
    }
}

struct KeyboardHints_TestView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Test alphabet-based sorting")
            Divider()
            
            VStack {
                
                HStack {
                    Text("LV")
                    Text(String.uppercasedAlphabet(for: "lv").joined())
                }
                HStack {
                    Text("FR")
                    Text(String.uppercasedAlphabet(for: "fr").joined())
                }
            }
            
            Divider()
            
            VStack {
                Text("Test sorting")
                
                HStack {
                    Text("LV - ČĀPSTINA")
                    Text(Array("ČĀPSTINA").map { String($0) }.sorted(by: { String.orderAsAlphabet(first: $0, second: $1, locale: "lv") }).joined())
                }
                
                
            }
        }
        VStack {
            Text("Test that unsubmitted rows are ignored.")
            Divider()
            KeyboardHints_TestView(state: GameState(
                initialized: true, 
                expected: DayWord(word: "fuels", day: 1, locale: "en"), rows: [
                    RowModel(word: "pluck", expected: "fuels", isSubmitted: true),
                    RowModel(word: "pales", expected: "fuels", isSubmitted: false)
                ], isTallied: false, date: Date()))
        }
        
        VStack {
            Text("Test that green overrides yellow (same row).")
            Divider()
            KeyboardHints_TestView(state: GameState(
                initialized: true, 
                expected: DayWord(word: "holly", day: 1, locale: "en"), rows: [
                    RowModel(word: "ladle", expected: "holly", isSubmitted: true),
                ], isTallied: false, date: Date()))
        }
        
        VStack {
            Text("Test that green overrides yellow (2 rows).")
            Divider()
            KeyboardHints_TestView(state: GameState(
                initialized: true, 
                expected: DayWord(word: "fuels", day: 1, locale: "en"), rows: [
                    RowModel(word: "pales", expected: "fuels", isSubmitted: true),
                    RowModel(word: "splat", expected: "fuels", isSubmitted: true),
                ], isTallied: false, date: Date()))
        }
        
        VStack {
            Text("Test empty.")
            Divider()
            KeyboardHints_TestView(state: GameState(
                initialized: true, 
                expected: DayWord(word: "fuels", day: 1, locale: "en"), rows: [
                    RowModel(word: "crazy", expected: "fuels", isSubmitted: true)
                ], isTallied: false, date: Date()))
        }
        
        VStack {
            Text("Test LV and FR locales contain the expected letters.")
            Divider()
            ForEach(["lv", "fr"], id: \.self) {
                locale in
                VStack {
                    Text(verbatim: "Locale \(locale)")
                    KeyboardHints_TestView(state: GameState(
                        initialized: true, 
                        expected: DayWord(word: "fuels", day: 1, locale: locale), rows: [
                            RowModel(word: "abcde", expected: "fuels", isSubmitted: true)
                        ], isTallied: false, date: Date()))
                }
            }
        }
    }
}

