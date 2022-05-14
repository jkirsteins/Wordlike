import SwiftUI

struct DarkPalette : Palette
{
    let name = "Dark (old)"
    
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

struct DarkPalette_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Dark palette (old)")
            
            _PaletteInternalTestView()
                .environment(\.palette, DarkPalette())
        }
    }
}
