import SwiftUI

/// A keyboard button
struct KeyboardButton: View {
    let letter: MultiCharacterModel
    
    @Environment(\.keyboardHints) 
    var keyboardHints: KeyboardHints
    
    @Environment(\.debug) 
    var debug: Bool
    
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
    
    var bestHint: TileBackgroundType? {
        let hints = letter.values.map {
            keyboardHints.hints[$0]
        }
        
        if hints.contains(.rightPlace) {
            return .rightPlace
        }
        
        if hints.contains(.wrongPlace) {
            return .wrongPlace
        }
        
        return nil
    }
    
    var body: some View {
        Button(
            // If debug mode is on, display all
            // possible values this key might submit
            debug ? (letter.values.map { $0.value }).joined() 
            : letter.displayValue, 
            
            action: insertText)
            .disabled(game.isCompleted)
            .frame(minHeight: minHeight)
            .buttonStyle(
                KeyboardButtonStyle(type: bestHint))
            .aspectRatio(1.0, contentMode: .fit)
            .frame(maxWidth: 50, maxHeight: 50)
    }
    
    init(letter: String, locale: Locale) {
        self.letter = MultiCharacterModel(
            CharacterModel(value: letter, locale: locale)
        )
    }
    
    init(letter: MultiCharacterModel) {
        self.letter = letter
    }
}
