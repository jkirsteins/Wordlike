import SwiftUI

struct LightPalette: Palette {
    let name = "Light (old)"

    var unknownWordTextColor: Color {
        .red.darker
    }

    let maskedFilledStroke: Color = .init(hex: 0x878A8C)
    let maskedEmptyStroke: Color = .init(hex: 0xD3D6DA)
    let wrongLetterStroke: Color = .init(hex: 0x787C7E)
    let wrongPlaceStroke: Color = .init(hex: 0xC9B458)
    let rightPlaceStroke: Color = .init(hex: 0x6AAA64)

    let maskedFilledFill: Color = .init(hex: 0xFFFFFF)
    let maskedEmptyFill: Color = .init(hex: 0xFFFFFF)
    let wrongLetterFill: Color = .init(hex: 0x787C7E)
    let wrongPlaceFill: Color = .init(hex: 0xC9B458)
    let rightPlaceFill: Color = .init(hex: 0x6AAA64)

    let maskedTextColor: Color = .init(hex: 0x000000)
    let revealedTextColor: Color = .init(hex: 0xFFFFFF)

    let toastBackground = Color(hex: 0x121213)
    let toastForeground = Color.white

    var normalKeyboardFill = Color(hex: 0xD4D5D9)
    var submitKeyboardFill = Color.blue
}

struct LightPalette_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Light palette (old)")

            _PaletteInternalTestView()
                .environment(\.palette, LightPalette())
        }
    }
}
