import SwiftUI

extension GameState {
    func calculateKeyboardHints(from newRows: [RowModel]) -> KeyboardHints {
        var result: Dictionary<CharacterModel, TileBackgroundType> = [:]
        
        let submittedRows = newRows.filter({ $0.isSubmitted })
        
        for srow in submittedRows {
            for ix in 0..<srow.word.count {
                let state = srow.revealState(ix)
                
                guard 
                    let chars = srow.char(guessAt: ix)
                else {
                    continue 
                }
                
                guard let char = chars.values.first, chars.values.count == 1 else {
                    fatalError("Submitted rows can't keep multiple character options")
                }
                
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
                        .rightPlace, .wrongPlace,
                        .wrongLetter
                    ].contains(state) else {
                        continue
                    }
                
                result[char] = state
            }
        }
        // Do not collapse hints here, because the
        // keyboard might need the source-of-truth
        return KeyboardHints(
            hints: result, 
            locale: expected.locale)  
    }
}

struct KeyboardHintsTestInternalView: View {
    let word: String 
    let guess: String 
    let validator = WordValidator(locale: .en_US)
    
    var body: some View {
        let state = GameState(
            initialized: true, 
            expected: TurnAnswer(
                word: WordModel(word, locale: Locale.lv_LV), 
                day: 1, 
                locale: .en_US, 
                validator: validator), 
            rows: [
                RowModel(
                    word: WordModel(guess, locale: Locale.lv_LV), 
                    expected: WordModel(word, locale: Locale.lv_LV), 
                    isSubmitted: true, 
                    attemptCount: 0)
            ], 
            isTallied: true, 
            date: Date())
        
        return GeometryReader { gr in
            VStack {
                Text(verbatim: "\(state.keyboardHints)")
                Row(model: state.rows[0])
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
    static let expected = WordModel("zvīņa", locale: Locale.lv_LV)
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: WordValidator(locale: .lv_LV(simplified: true))),
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
                    Row(model: $0)
                }
                LatvianKeyboard_Simplified()
                    .environmentObject(state)
                    .environment(\.keyboardHints, state.keyboardHints)
                    .environment(\.rootGeometry, gr)
            }
        }.padding()
    }
}

struct Internal_LatvianSimplifiedTest_validateUncertainPair: View
{
    static let expected = WordModel("kaite", locale: .lv_LV)
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, 
            day: 1, 
            locale: .lv_LV(simplified: true), 
            validator: WordValidator(locale: .lv_LV(simplified: true))),
        rows: [
            RowModel(
                word: WordModel("kaitē", locale: .lv_LV), 
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
                    Text("If we switch between hard/easy during a round, we can end up in a situation where a letter pairing is uncertain (e.g. Ē has been tried and is invalid, but E hasn't and is valid).\n\nWe should not mark these letters as 'known' in this case.\n\nE should be 'unknown' and neither green nor dark.")
                    Spacer()
                }
                Divider()
                HStack {
                    Text("On keyboard expect green: K, A, I, T")
                    Spacer()
                }
                HStack {
                    Text("On keyboard expect unknown: E")
                    Spacer()
                }
                
                ForEach(state.rows) {
                    Row(model: $0)
                }
                LatvianKeyboard_Simplified()
                    .environmentObject(state)
                    .environment(\.keyboardHints, state.keyboardHints)
                    .environment(\.rootGeometry, gr)
            }
        }
        .padding()
    }
}

struct KeyboardHintsTestInternalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            KeyboardHintsTestInternalView(word: "fuels", guess: "clues")
            
            VStack {
                Text("Regression test: A should be yellow in the keyboard").font(.title)
                KeyboardHintsTestInternalView(word: "buzza", guess: "maman")
            }.padding()
            
            Internal_LatvianSimplifiedTest()
            Internal_LatvianSimplifiedTest_validateUncertainPair( )
        }
        .environmentObject(BoardRevealModel())
    }
}
