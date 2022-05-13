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
    
    var normalKeyboardFill: Color { get }
    var submitKeyboardFill: Color { get }
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
    
    var normalKeyboardFill = Color(hex: 0x828385)
    var submitKeyboardFill = Color.blue
}

struct LightPalette : Palette
{
    let maskedFilledStroke: Color = Color(hex: 0x878a8c)
    let maskedEmptyStroke: Color = Color(hex: 0xd3d6da)
    let wrongLetterStroke: Color = Color(hex: 0x787c7e)
    let wrongPlaceStroke: Color = Color(hex: 0xc9b458)
    let rightPlaceStroke: Color = Color(hex: 0x6aaa64)
    
    let maskedFilledFill: Color = Color(hex: 0xffffff)
    let maskedEmptyFill: Color = Color(hex: 0xffffff)
    let wrongLetterFill: Color = Color(hex: 0x787c7e)
    let wrongPlaceFill: Color = Color(hex: 0xc9b458)
    let rightPlaceFill: Color = Color(hex: 0x6aaa64)
    
    let maskedTextColor: Color = Color(hex: 0x000000)
    let revealedTextColor: Color = Color(hex: 0xffffff)
    
    let toastBackground = Color(hex: 0x121213)
    let toastForeground = Color.white
    
    var normalKeyboardFill = Color(hex: 0xd4d5d9)
    var submitKeyboardFill = Color.blue
}

struct DarkHCPalette : Palette
{
    let maskedFilledStroke: Color = Color(hex: 0x565758)
    let maskedEmptyStroke: Color = Color(hex: 0x3a3a3c)
    let wrongLetterStroke: Color = Color(hex: 0x3a3a3c)
    let wrongPlaceStroke: Color = Color(hex: 0x85C0f9)
    let rightPlaceStroke: Color = Color(hex: 0xF5793A)
    
    let maskedFilledFill: Color = Color(hex: 0x121213)
    let maskedEmptyFill: Color = Color(hex: 0x121213)
    let wrongLetterFill: Color = Color(hex: 0x3a3a3c)
    let wrongPlaceFill: Color = Color(hex: 0x85C0f9)
    let rightPlaceFill: Color = Color(hex: 0xF5793A)
    
    let maskedTextColor: Color = Color(hex: 0xffffff)
    let revealedTextColor: Color = Color(hex: 0xffffff)
    
    let toastBackground = Color.white
    let toastForeground = Color(hex: 0x121213)
    
    var normalKeyboardFill = Color(hex: 0x828385)
    var submitKeyboardFill = Color.blue
}

struct LightHCPalette : Palette
{
    let maskedFilledStroke: Color = Color(hex: 0x878a8c)
    let maskedEmptyStroke: Color = Color(hex: 0xd3d6da)
    let wrongLetterStroke: Color = Color(hex: 0x787c7e)
    let wrongPlaceStroke: Color = Color(hex: 0x85C0f9)
    let rightPlaceStroke: Color = Color(hex: 0xF5793A)
    
    let maskedFilledFill: Color = Color(hex: 0xffffff)
    let maskedEmptyFill: Color = Color(hex: 0xffffff)
    let wrongLetterFill: Color = Color(hex: 0x787c7e)
    let wrongPlaceFill: Color = Color(hex: 0x85C0f9)
    let rightPlaceFill: Color = Color(hex: 0xF5793A)
    
    let maskedTextColor: Color = Color(hex: 0x000000)
    let revealedTextColor: Color = Color(hex: 0xffffff)
    
    let toastBackground = Color(hex: 0x121213)
    let toastForeground = Color.white
    
    var normalKeyboardFill = Color(hex: 0xd4d5d9)
    var submitKeyboardFill = Color.blue
}

struct PaletteInternalTestView: View {
    var body: some View {
        VStack {
            Row(model: RowModel(word: "CRAZY", expected: "FUELS", isSubmitted: true, locale: .en_US))
            Row(model: RowModel(word: "SLEDS", expected: "FUELS", isSubmitted: true, locale: .en_US))
            Row(model: RowModel(word: "FLINT", expected: "FUELS", isSubmitted: true, locale: .en_US))
            Row(model: RowModel(word: "FIL", expected: "FUELS", isSubmitted: false, locale: .en_US))
            Row(model: RowModel(expected: "FUELS", locale: .en_US))
        }
    }
}

struct PaletteInternalTestView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Light palette")
        
        PaletteInternalTestView()
            .environment(\.palette, LightPalette())
        }
    }
}
