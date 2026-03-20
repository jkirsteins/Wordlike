import SwiftUI

struct DarkPalette: Palette {
    let name = "Dark (old)"

    var unknownWordTextColor: Color {
        .red
    }

    let maskedFilledStroke: Color = .init(hex: 0x565758)
    let maskedEmptyStroke: Color = .init(hex: 0x3A3A3C)
    let wrongLetterStroke: Color = .init(hex: 0x3A3A3C)
    let wrongPlaceStroke: Color = .init(hex: 0xB59F3B)
    let rightPlaceStroke: Color = .init(hex: 0x538D4E)

    let maskedFilledFill: Color = .init(hex: 0x121213)
    let maskedEmptyFill: Color = .init(hex: 0x121213)
    let wrongLetterFill: Color = .init(hex: 0x3A3A3C)
    let wrongPlaceFill: Color = .init(hex: 0xB59F3B)
    let rightPlaceFill: Color = .init(hex: 0x538D4E)

    let maskedTextColor: Color = .init(hex: 0xFFFFFF)
    let revealedTextColor: Color = .init(hex: 0xFFFFFF)

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
