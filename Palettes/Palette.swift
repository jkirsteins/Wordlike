import SwiftUI

protocol Palette
{
    var name: String { get }
    
    var maskedFilledStroke: Color { get }
    var maskedEmptyStroke: Color { get }
    var wrongLetterStroke: Color { get }
    var wrongPlaceStroke: Color { get }
    var rightPlaceStroke: Color { get }
    
    var maskedFilledFill: Color { get }
    var maskedEmptyFill: Color { get }
    var wrongLetterFill: Color { get }
    var wrongPlaceFill: Color { get }
    var rightPlaceFill: Color { get }
    
    var maskedTextColor: Color { get }
    var revealedTextColor: Color { get }
    var revealedWrongLetterColor: Color { get }
    
    var toastBackground: Color { get }
    var toastForeground: Color { get }
    
    var normalKeyboardFill: Color { get }
    var submitKeyboardFill: Color { get }
    
    func keyboardFill(for type: TileBackgroundType?) -> Color
    func keyboardText(for type: TileBackgroundType?) -> Color
}

extension Palette {
    var revealedWrongLetterColor: Color {
        revealedTextColor
    }
    
    func keyboardFill(for type: TileBackgroundType?) -> Color {
        Color.keyboardFill(for: type, from: self)
    }
    
    func keyboardText(for type: TileBackgroundType?) -> Color {
        guard let type = type else {
            return .white
        }
            
        guard type != .wrongLetter else {
            return .white
        }
        
        return .white
    }
}

