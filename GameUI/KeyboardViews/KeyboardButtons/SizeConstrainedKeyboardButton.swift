import SwiftUI

/// Keyboard button that applies size constraints.
struct SizeConstrainedKeyboardButton: View {
    let maxSize: CGSize
    let letter: MultiCharacterModel
    
    var body: some View {
        KeyboardButton(
            letter: letter)
            .frame(
                minWidth: maxSize.width,
                maxWidth: maxSize.width, 
                minHeight: maxSize.height,
                maxHeight: maxSize.height)
    }
    
    init(maxSize: CGSize, letter: MultiCharacterModel) {
        self.maxSize = maxSize
        self.letter = letter
    }
    
    init(maxSize: CGSize, letter: String, locale: Locale) {
        self.maxSize = maxSize
        self.letter = .single(letter, locale: locale)
    }
}
