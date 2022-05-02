import SwiftUI

struct KeyboardHints {
    /// This contains the mapping to known outcomes (
    /// known good/misplaced/unused)
    let hints: Dictionary<CharacterModel, TileBackgroundType>
    
    /// Locale is used to generate the alphabet, so 
    /// we can infer which are remaining usable chars.
    let locale: GameLocale
    
    init(hints: Dictionary<CharacterModel, TileBackgroundType>, locale: GameLocale) {
        self.hints = hints 
        self.locale = locale 
    }
    
    init() {
        self.hints = Dictionary<CharacterModel, TileBackgroundType>()
        self.locale = .en_US
    }
    
    init(hints: Dictionary<String, TileBackgroundType>, locale: GameLocale) {
        let mapped = hints.map {
            (k, v) in (CharacterModel(value: k, locale: locale.nativeLocale), v)
        }
        self.hints = Dictionary(
            uniqueKeysWithValues: mapped)
        self.locale = locale
    }
}

struct EditableRow : View
{
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var delayRowIx: Int
    @Binding var model: RowModel
    
    let tag: Int
    @Binding var isActive: Int
    
    let editable: Bool
    
    let keyboardHints: KeyboardHints
    
    init(
        editable: Bool,
        delayRowIx: Int,
        model: Binding<RowModel>, 
        tag: Int, 
        isActive: Binding<Int>,
        keyboardHints: KeyboardHints) {
            self.editable = editable
            self.delayRowIx = delayRowIx
            self._model = model
            self.tag = tag
            self._isActive = isActive
            self.keyboardHints = keyboardHints
        }
    
    init(
        delayRowIx: Int,
        model: Binding<RowModel>, 
        tag: Int, 
        isActive: Binding<Int>,
        keyboardHints: KeyboardHints) {
            self.editable = true
            self.delayRowIx = delayRowIx
            self._model = model
            self.tag = tag
            self._isActive = isActive
            self.keyboardHints = keyboardHints
        }
    
    @State var background: Color = Color(UIColor.systemFill)
    
    var body: some View {
        let showFocusHint =  editable && (isActive == self.tag) 
        
        return Row(
            delayRowIx: delayRowIx, 
            model: model, 
            showFocusHint: showFocusHint)
    }
}
