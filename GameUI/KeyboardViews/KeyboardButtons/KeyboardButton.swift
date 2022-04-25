import SwiftUI

/// A keyboard button
struct KeyboardButton: View {
    let letter: String 
    
    @Environment(\.keyboardHints) 
    var keyboardHints: KeyboardHints
    
    @EnvironmentObject var game: GameState
    
    func insertText() {
        self.game.insertText(letter: letter)
    }
    
    @Environment(\.horizontalSizeClass) 
    var horizontalSizeClass
    @Environment(\.verticalSizeClass) 
    var verticalSizeClass
    
    /// If we're in compact height (e.g. phone landscape),
    /// allow a smaller keyboard.
    var minHeight: CGFloat {
        if verticalSizeClass == .compact {
            return 20
        }
        
        return 45
    }
    
    var body: some View {
        Button(letter, action: insertText)
            .disabled(game.isCompleted)
            .frame(minHeight: minHeight)
            .buttonStyle(
                KeyboardButtonStyle(type: keyboardHints.hints[letter]))
            .aspectRatio(1.0, contentMode: .fit)
            .frame(maxWidth: 50, maxHeight: 50)
    }
}
