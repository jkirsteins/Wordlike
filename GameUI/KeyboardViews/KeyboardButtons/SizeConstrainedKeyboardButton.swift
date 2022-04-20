import SwiftUI

/// Keyboard button that applies size constraints.
struct SizeConstrainedKeyboardButton: View {
    let maxSize: CGSize
    let letter: String 
    
    var body: some View {
        KeyboardButton(
            letter: letter).frame(
                minWidth: maxSize.width,
                maxWidth: maxSize.width, 
                minHeight: maxSize.height,
                maxHeight: maxSize.height)
    }
}
