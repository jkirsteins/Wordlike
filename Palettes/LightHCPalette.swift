import SwiftUI

struct LightHCPalette : Palette
{
    let name = "Light (high contrast)"
    
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

struct LightHCPalette_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Light HC palette")
            
            _PaletteInternalTestView()
                .environment(\.palette, LightHCPalette())
        }
    }
}
