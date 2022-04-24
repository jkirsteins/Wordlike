import SwiftUI

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