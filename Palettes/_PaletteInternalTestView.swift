import SwiftUI

struct _PaletteInternalTestView: View {
    @Environment(\.palette)
    var palette: Palette 
    
    var body: some View {
        GeometryReader { gr in 
            VStack {
                ToastBanner(message: "Message in \(palette.name) palette")
                
                Row(model: RowModel(word: "CRAZY", expected: "FUELS", isSubmitted: true, locale: .en_US))
                Row(model: RowModel(word: "SLEDS", expected: "FUELS", isSubmitted: true, locale: .en_US))
                Row(model: RowModel(word: "FLINT", expected: "FUELS", isSubmitted: true, locale: .en_US))
                Row(model: RowModel(word: "FIL", expected: "FUELS", isSubmitted: false, locale: .en_US))
                Row(model: RowModel(expected: "FUELS", locale: .en_US))
                
                EnglishKeyboard()
            }
            .environment(\.rootGeometry, gr)
            .environmentObject(BoardRevealModel())
            .environmentObject(GameState())
            .environment(
                \.keyboardHints, 
                 KeyboardHints(
                    hints: [
                        "Q": .wrongPlace,
                        "J": .rightPlace,
                        "W": .wrongLetter,
                        "A": .wrongLetter,
                        "S": .wrongLetter,
                        "D": .wrongLetter,
                    ], 
                    locale: .en_US)
            )
        }
    }
}

struct PaletteInternalTestView_Previews: PreviewProvider {
    static let palettes: [Palette] = [
        LightPalette2(),
        LightPalette(), 
        LightHCPalette(), 
        DarkPalette(), 
        DarkHCPalette()
    ]
    
    static var previews: some View {
        ForEach(
            palettes.map({ ($0, UUID()) }), 
            id: \.self.1) 
        {
            t in 
            VStack {
                Text(t.0.name)
                _PaletteInternalTestView()
                    .environment(\.palette, t.0)
            }.padding()
        }
    }
}
