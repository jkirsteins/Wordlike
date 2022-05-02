import SwiftUI

struct LatvianKeyboard_Simplified: View {
    static let specialMap: Dictionary<String, String> = [
        "Ē": "E",
        "Ū": "U",
        "Ī": "I",
        "Ā": "A",
        "Š": "S",
        "Ģ": "G",
        "Ķ": "K",
        "Ļ": "L",
        "Ž": "Z",
        "Č": "C",
        "Ņ": "N"]
    
    @State var maxSize: CGSize = .zero
    
    @EnvironmentObject 
    var toastMessage: ToastMessageCenter
    
    @Environment(\.keyboardHints) 
    var hints: KeyboardHints
    
    @Environment(\.debug) 
    var debug: Bool
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1)
    
    let locale = Locale.lv_LV
    
    var wideSize: CGSize {
        CGSize(width: maxSize.width*1.5 + hspacing, 
               height: maxSize.height)
    }
    
    var debug_wrongHints: String {
        hints.hints.filter {
            $0.value == .wrongLetter
        }.map {
            $0.key.value
        }.joined(separator: ",")
    }
    
    /// Determines which letters a button should input (can be multiple)
    func keyboardLetter(_ letter: String) -> MultiCharacterModel {
        guard let complement = Self.specialMap.first(where: {
            $0.value == letter 
        })?.key else {
            // If there is no complement, then
            // there is no way we need to do any
            // visual changes.
            return MultiCharacterModel.single(letter, locale: locale)
        }
        
        var chars = [CharacterModel]()
        
        let regularChar = CharacterModel(
            value: letter, locale: locale)
        let complementChar = CharacterModel(
            value: complement, locale: locale)
        
        // regular char should go first, because the 
        // first letter determines the display
        if hints.hints[regularChar] != .wrongLetter {
            chars.append(regularChar)
        }
        
        if hints.hints[complementChar] != .wrongLetter {
            chars.append(complementChar)
        }
        
        return MultiCharacterModel(values: chars)
    }
    
    var body: some View {
        VStack {
            KeyboardContainer(spacing: vspacing) {
                RowContainer(spacing: hspacing) {
                    Group {
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("E"))
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("R"))
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize,
                            letter: keyboardLetter("T"))
                    }
                    
                    Group {
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("U"))
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("I"))
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("O"))
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("P"))
                    }
                }
                
                RowContainer(spacing: hspacing ) {
                    Group {
                        SizeSettingKeyboardButton(
                            maxSize: $maxSize, 
                            letter: keyboardLetter("A"))
                        KeyboardButton(
                            letter: keyboardLetter("S"))
                        KeyboardButton(
                            letter: keyboardLetter("D"))
                        KeyboardButton(
                            letter: keyboardLetter("F"))
                        KeyboardButton(
                            letter: keyboardLetter("G"))
                    }
                    Group {
                        KeyboardButton(
                            letter: keyboardLetter("H"))
                        KeyboardButton(
                            letter: keyboardLetter("J"))
                        KeyboardButton(
                            letter: keyboardLetter("K"))
                        KeyboardButton(
                            letter: keyboardLetter("L"))
                    }
                }
                
                RowContainer(spacing: hspacing) {
                    BackspaceButton(maxSize: wideSize)
                    Group {
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("Z"))
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("C"))
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("V"))
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("B"))
                    }
                    Group {
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("N"))
                            
                        SizeConstrainedKeyboardButton(
                            maxSize: maxSize, 
                            letter: keyboardLetter("M"))
                    }
                    SubmitButton<WordValidator>(maxSize: wideSize)
                }
            }
            .id(hints.hints)
            
            if (debug) {
                Text(verbatim:  "Wrong: \(debug_wrongHints)")
            }
        }
    }
}

/// Test that we adapt the symbols shown on-screen,
/// according to the keyboard hints.
///
/// E.g. if S is eliminated but Š is unknown, we should
/// display Š on the same button (and not have it marked
/// as wrong)
struct LatvianKeyboard_SimplifiedTest_adaptLetterWhenComplementUnknown: View
{
    static let expected = WordModel("kaite", locale: .lv_LV)
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: WordValidator(locale: .lv_LV(simplified: true))),
        rows: [
            RowModel(
                word: WordModel("marts", locale: .lv_LV), 
                expected: Self.expected, 
                isSubmitted: true, 
                attemptCount: 0),
        ], isTallied: true, date: Date())
    
    var body: some View {
        GeometryReader { gr in
            VStack(alignment: .leading) {
                Text("Test collapsing keyboard hints for entire pairs in simplified Latvian").font(.title)
                Divider()
                
                HStack {
                    Text("S key should display Š.")
                    Spacer()
                }
                Divider()
                HStack {
                    Text("It is a regression if the button displays S or is marked in an 'unknown' color.")
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

/// If the complement (Š) is known good, then we should
/// display that as the display letter (instead of S).
struct LatvianKeyboard_SimplifiedTest_adaptLetterWhenComplementGood: View
{
    static let expected = WordModel("marši", locale: .lv_LV)
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: false), validator: WordValidator(locale: .lv_LV(simplified: true))),
        rows: [
            RowModel(
                word: WordModel("kurši", locale: .lv_LV), 
                expected: Self.expected, 
                isSubmitted: true, 
                attemptCount: 0),
        ], isTallied: true, date: Date())
    
    var body: some View  {
        GeometryReader { gr in
            VStack(alignment: .leading) {
                Text("Test adapting keyboard for known good complements").font(.title)
                Divider()
                
                HStack {
                    Text("S key should display Š.")
                    Spacer()
                }
                Divider()
                HStack {
                    Text("It is a regression if the button displays S.")
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

/// Test behaviour if two complements of a pair are present
/// in a word (e.g. Š and S) - green should take precedence
/// (both color and letter)
struct LatvianKeyboard_SimplifiedTest_bothComplementsPresent_different: View
{
    static let expected = WordModel("maršs", locale: .lv_LV)
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: WordValidator(locale: .lv_LV(simplified: true))),
        rows: [
            RowModel(
                word: WordModel("saišu", locale: .lv_LV), 
                expected: Self.expected, 
                isSubmitted: true, 
                attemptCount: 0),
        ], isTallied: true, date: Date())
    
    var body: some View  {
        GeometryReader { gr in
            VStack(alignment: .leading) {
                Text("Test adapting keyboard when both complements present in a word").font(.title)
                Divider()
                
                HStack {
                    Text("S key should display Š.")
                    Spacer()
                }
                Divider()
                HStack {
                    Text("It is a regression if the button displays S.")
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


/// Test behaviour if two complements of a pair are present
/// in a word (e.g. Š and S) and both are valid - 
/// the letter without diacritics should take precedence.
struct LatvianKeyboard_SimplifiedTest_bothComplementsPresent_valid: View
{
    static let expected = WordModel("knašs", locale: .lv_LV)
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: WordValidator(locale: .lv_LV(simplified: true))),
        rows: [
            RowModel(
                word: WordModel("knašs", locale: .lv_LV), 
                expected: Self.expected, 
                isSubmitted: true, 
                attemptCount: 0),
        ], isTallied: true, date: Date())
    
    var body: some View  {
        GeometryReader { gr in
            VStack(alignment: .leading) {
                Text("Test that non-diacritics letter takes precedence when valid").font(.title)
                Divider()
                
                HStack {
                    Text("S key should display S.")
                    Spacer()
                }
                Divider()
                HStack {
                    Text("It is a regression if the button displays Š.")
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

struct LatvianKeyboard_SimplifiedTest_testCollapsing_onlyComplementKnown: View
{
    static let expected = WordModel("gārgs", locale: .lv_LV)
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: WordValidator(locale: .lv_LV(simplified: true))),
        rows: [
            RowModel(
                word: WordModel("trūka", locale: .lv_LV), 
                expected: Self.expected, 
                isSubmitted: true, 
                attemptCount: 0),
            RowModel(
                word: WordModel("vērās", locale: .lv_LV), 
                expected: Self.expected, 
                isSubmitted: true, 
                attemptCount: 0),
        ], isTallied: true, date: Date())
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                Text("Regression test").font(.title)
                Divider()
                
                Text("A should be yellow.")
                Text("A should display letter Ā.")
                Divider()
                
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

struct LatvianKeyboard_SimplifiedTest_Previews: PreviewProvider {
    static var previews: some View {
        LatvianKeyboard_SimplifiedTest_adaptLetterWhenComplementUnknown()
        LatvianKeyboard_SimplifiedTest_adaptLetterWhenComplementGood()
        LatvianKeyboard_SimplifiedTest_bothComplementsPresent_different()
        LatvianKeyboard_SimplifiedTest_bothComplementsPresent_valid()
        LatvianKeyboard_SimplifiedTest_testCollapsing_onlyComplementKnown()
    }
}
