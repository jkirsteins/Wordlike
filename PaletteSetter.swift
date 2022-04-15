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
}



struct PaletteSetterView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage(SettingsView.HIGH_CONTRAST_KEY) 
    var high: Bool = false
    
    @ViewBuilder var content: ()->Content
    
    var body: some View {
        content()
            .environment(\.palette, 
                          high ? (colorScheme == .dark ? DarkHCPalette() as Palette: LightHCPalette() as Palette) : (colorScheme == .dark ? DarkPalette() as Palette: LightPalette() as Palette))
    }
}

struct PaletteSetterView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteSetterView {
            EditableRow_ForPreview()
        }
        
        VStack {
            Text("Dark high contrast")
            Row(delayRowIx: 0, model: RowModel(word: "flbes", expected: "fuels", isSubmitted: true))
                .environment(\.palette, DarkHCPalette())
            Text("Light high contrast")
            Row(delayRowIx: 0, model: RowModel(word: "flbes", expected: "fuels", isSubmitted: true))
                .environment(\.palette,  LightHCPalette())
        }
    }
}
