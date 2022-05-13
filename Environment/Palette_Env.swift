import SwiftUI

private struct PaletteKey: EnvironmentKey {
    static let defaultValue: Palette = DarkPalette()
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}
