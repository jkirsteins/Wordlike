import SwiftUI

struct LatvianKeyboard_Simplified: View {
    @State var maxSize: CGSize = .zero
    
    @EnvironmentObject 
    var toastMessage: ToastMessageCenter
    
    @Environment(\.keyboardHints) 
    var hints: KeyboardHints
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1)
    
    var wideSize: CGSize {
        CGSize(width: maxSize.width*1.5 + hspacing, 
               height: maxSize.height)
    }
    
    /// We want to propogate collapsed hints to 
    /// the underlying buttons (e.g. if either Š or S is
    /// green, collapse it to S and display in one button)
    ///
    /// It can lead to odd situations where you have
    /// e.g. Š and S both in a word (but only S is displayed)
    /// but should be ok in practice.
    ///
    /// See `collapseHints`
    ///
    /// NOTE: this is not needed if keyboard
    /// adapts the displayed letter.
    var collapsedHints: KeyboardHints {
        KeyboardHints(
            hints: collapseHints(hints.hints),
            locale: hints.locale)
    }
    
    /// Collapses the hints received from environment,
    /// so we can propogate them forward 
    /// (see `collapsedHints`) 
    func collapseHints(_ hints: Dictionary<String, TileBackgroundType>) -> Dictionary<String, TileBackgroundType> 
    {
        var result = Dictionary<String, TileBackgroundType>()
        
        let fold: ((String) -> String) = { x in 
            x.folding(options: .diacriticInsensitive, locale: Locale(identifier: "lv_LV"))
        }
        
        var specialValues = Dictionary<String, [TileBackgroundType]>()
        
        let storeSpecial: (String, TileBackgroundType)->() = { key, value in
            let folded = fold(key)
            var newVals = (specialValues[folded] ?? [])
            newVals.append(value)
            specialValues[folded] = newVals
        }
        
        // Store all values under a folded key
        for (key, val) in hints {
            storeSpecial(key, val)
        }
        
        // Now aggregate the results
        for key in specialValues.keys {
            let values = (specialValues[key] ?? [])
            
            if values.contains(TileBackgroundType.rightPlace) {
                // rightPlace should always be propogated
                result[key] = .rightPlace 
            } else if
                // wrongPlace should always be propogated
                // but not ahead of rightPlace
                values.contains(TileBackgroundType.wrongPlace) {
                result[key] = .wrongPlace 
            } else if values.count == 2 {
                // if both diacritic/diacriticless values
                // are bad, propogate
                result[key] = values[0]
            } else if !SimplifiedLatvianWordValidator.specialMap.values.contains(key) && values.count > 0 {
                // if only 1 value present, only propogate
                // if it does not have a complement
                result[key] = values[0]
            } else {
                // this means a pair has only 1 value
                // and that 1 value is invalid, but we
                // can't assume that the complement is
                // also invalid.
                //
                // so skip.
            }
        }
        
        return result
    }
    
    /// Determines which letter to display on a button.
    ///
    /// E.g. if it normally shows S but S is known to
    /// be wrong, we want to show Š.
    ///
    /// Or if Š is known to be good, we also want to show
    /// Š not S.
    ///
    /// It can be a bit inconsistent if both complements
    /// of a pair are present in a word (e.g. we need both
    /// Š and S).
    func keyboardLetter(_ letter: String) -> String {
        guard let complement = SimplifiedLatvianWordValidator.specialMap.first(where: {
            $0.value == letter 
        })?.key else {
            // If there is no complement, then
            // there is no way we need to do any
            // visual changes.
            return letter
        }
        
        if hints.hints[letter] == .rightPlace {
            return letter
        }
        
        if hints.hints[complement] == .rightPlace {
            return complement
        }
        
        if hints.hints[letter] == .wrongPlace {
            return letter
        }
        
        if hints.hints[complement] == .wrongPlace {
            return complement
        }
        
        // return the 'unknown' complement if the
        // other is known bad
        if hints.hints[letter] == .wrongLetter && hints.hints[complement] == nil {
            return complement
        }
        
        // This can happen if we use the hardware keyboard
        if hints.hints[complement] == .wrongLetter && hints.hints[letter] == nil {
            return letter
        }
        
        return letter
    }
    
    var body: some View {
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
                SubmitButton<SimplifiedLatvianWordValidator>(maxSize: wideSize)
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
    static let expected = "kaite"
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: SimplifiedLatvianWordValidator()),
        rows: [
            RowModel(
                word: "marts", 
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
    static let expected = "marši"
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: false), validator: SimplifiedLatvianWordValidator()),
        rows: [
            RowModel(
                word: "kurši", 
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
    static let expected = "maršs"
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: SimplifiedLatvianWordValidator()),
        rows: [
            RowModel(
                word: "saišu", 
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
    static let expected = "knašs"
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: SimplifiedLatvianWordValidator()),
        rows: [
            RowModel(
                word: "knašs", 
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
    static let expected = "gārgs"
    
    let state = GameState(
        initialized: true, 
        expected: TurnAnswer(
            word: Self.expected, day: 1, locale: .lv_LV(simplified: true), validator: SimplifiedLatvianWordValidator()),
        rows: [
            RowModel(
                word: "trūka", 
                expected: Self.expected, 
                isSubmitted: true, 
                attemptCount: 0),
            RowModel(
                word: "vērās", 
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
