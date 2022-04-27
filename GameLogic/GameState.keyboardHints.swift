import SwiftUI

extension GameState {
    var keyboardHints: KeyboardHints {
        var result: Dictionary<String, TileBackgroundType> = [:]
        
        let submittedRows = rows.filter({$0.isSubmitted})
        
        for srow in submittedRows {
            for ix in 0..<srow.word.count {
                let state = srow.revealState(ix)
                let char = srow.char(guessAt: ix)
                
                // don't allow overriding rightPlace
                guard result[char] != .rightPlace else {
                    continue 
                }
                
                /* don't allow overriding wrongPlace
                 unless it's rightPlace */
                guard !(result[char] == .wrongPlace && state != .rightPlace) else {
                    continue
                } 
                
                guard result[char] != state else { 
                    continue
                }
                
                guard 
                    [
                        .rightPlace, 
                            .wrongPlace,
                        .wrongLetter
                    ].contains(state) else {
                        continue
                    }
                
                result[
                    self.expected.validator.foldForHintKey(char)
                ] = state
            }
        }
        
        return KeyboardHints(
            hints: result, 
            locale: expected.locale)  
    }
}

struct KeyboardHintsTestInternalView: View {
    let word: String 
    let guess: String 
    let validator = WordValidator(name: "en")
    
    var body: some View {
        let state = GameState(initialized: true, expected: TurnAnswer(word: word, day: 1, locale: "en", validator: validator), 
                              rows: [
                                RowModel(word: guess, expected: word, isSubmitted: true, attemptCount: 0)
                              ], isTallied: true, date: Date())
        
        return GeometryReader { gr in
            VStack {
                Text(verbatim: "\(state.keyboardHints)")
                Row(delayRowIx: 0, model: state.rows[0])
                EnglishKeyboard()
                    .environmentObject(state)
                    .environment(\.keyboardHints, state.keyboardHints)
                    .environment(\.rootGeometry, gr)
            }
        }
    }
}

struct Internal_LatvianSimplifiedTest: View
{
    static let expected = "zvīņa"
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: "lv", validator: LatvianWordValidator()),
        rows: [
            RowModel(
                word: "zvņīa", 
                expected: Self.expected, 
                isSubmitted: true, 
                attemptCount: 0),
        ], isTallied: true, date: Date())
    
    var body: some View {
        GeometryReader { gr in
        VStack {
            Text("Simplified Latvian test").font(.title)
            Divider()
            
            HStack {
            Text("Hints should higlight simplified as yellow when answer contains non-simplified in a different position.")
                Spacer()
            }
            
            HStack {
                Text("On keyboard expect green: Z, V, A")
                Spacer()
            }
            HStack {
                Text("On keyboard expect yellow: I, N")
                Spacer()
            }
            
            ForEach(state.rows) {
                Row(delayRowIx: 0, model: $0)
            }
            LatvianKeyboard_Simplified()
                        .environmentObject(state)
                        .environment(\.keyboardHints, state.keyboardHints)
                        .environment(\.rootGeometry, gr)
        }
    }.padding()
    }
}

struct KeyboardHintsTestInternalView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardHintsTestInternalView(word: "fuels", guess: "clues")
        
        VStack {
            Text("Regression test: A should be yellow in the keyboard").font(.title)
            KeyboardHintsTestInternalView(word: "buzza", guess: "maman")
        }.padding()
        
        Internal_LatvianSimplifiedTest()
    }
}

