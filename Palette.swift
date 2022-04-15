import SwiftUI

protocol Palette
{
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
    
    var toastBackground: Color { get }
    var toastForeground: Color { get }
}

struct DarkPalette : Palette
{
    let maskedFilledStroke: Color = Color(hex: 0x565758)
    let maskedEmptyStroke: Color = Color(hex: 0x3a3a3c)
    let wrongLetterStroke: Color = Color(hex: 0x3a3a3c)
    let wrongPlaceStroke: Color = Color(hex: 0xb59f3b)
    let rightPlaceStroke: Color = Color(hex: 0x538d4e)
    
    let maskedFilledFill: Color = Color(hex: 0x121213)
    let maskedEmptyFill: Color = Color(hex: 0x121213)
    let wrongLetterFill: Color = Color(hex: 0x3a3a3c)
    let wrongPlaceFill: Color = Color(hex: 0xb59f3b)
    let rightPlaceFill: Color = Color(hex: 0x538d4e)
    
    let maskedTextColor: Color = Color(hex: 0xffffff)
    let revealedTextColor: Color = Color(hex: 0xffffff)
    
    let toastBackground = Color.white
    let toastForeground = Color(hex: 0x121213)
}


