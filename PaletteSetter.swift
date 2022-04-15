import SwiftUI

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
}

struct HighContrastPalette : Palette
{
    let maskedFilledStroke: Color = Color(hex: 0x878a8c)
    let maskedEmptyStroke: Color = Color(hex: 0xd3d6da)
    let wrongLetterStroke: Color = Color(hex: 0x787c7e)
    let wrongPlaceStroke: Color = Color(hex: 0x0000FF)
    let rightPlaceStroke: Color = Color(hex: 0xFF0000)
    
    let maskedFilledFill: Color = Color(hex: 0xffffff)
    let maskedEmptyFill: Color = Color(hex: 0xffffff)
    let wrongLetterFill: Color = Color(hex: 0x787c7e)
    let wrongPlaceFill: Color = Color(hex: 0x0000FF)
    let rightPlaceFill: Color = Color(hex: 0xFF0000)
    
    let maskedTextColor: Color = Color(hex: 0x000000)
    let revealedTextColor: Color = Color(hex: 0xffffff)
}

struct PaletteSetterView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage(SettingsView.HIGH_CONTRAST_KEY) 
    var high: Bool = false
    
    @ViewBuilder var content: ()->Content
    
    var body: some View {
        content()
            .environment(\.palette, 
                          high ? HighContrastPalette() as Palette : (colorScheme == .dark ? DarkPalette() as Palette: LightPalette() as Palette))
    }
}

struct PaletteSetterView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteSetterView {
            EditableRow_ForPreview()
        }
    }
}
