import SwiftUI

/// Keyboard button that reports its size, which can then
/// be used to constrain the size of buttons in other rows.
///
/// It must be placed on a row with other buttons
/// that all should have no size constraints.
struct SizeSettingKeyboardButton: View {
    @Binding var maxSize: CGSize 
    
    let letter: MultiCharacterModel 
    
    @Environment(\.keyboardHints) 
    var keyboardHints: KeyboardHints
    
    init(maxSize: Binding<CGSize>, letter: String, locale: Locale) {
        self._maxSize = maxSize
        self.letter = .single(letter, locale: locale) 
    }
    
    init(maxSize: Binding<CGSize>, letter: MultiCharacterModel) {
        self._maxSize = maxSize
        self.letter = letter 
    }
    
    var body: some View {
        KeyboardButton(letter: letter).background(GeometryReader {
            proxy in 
            
            Color.clear
                .onAppear {
                    maxSize = proxy.size
                }
                .safeOnChange(of: proxy.size) { newSize in
                    maxSize = newSize
                }
        })
    }
}
