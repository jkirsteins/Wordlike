import SwiftUI

private struct PaletteKey: EnvironmentKey {
    static let defaultValue: Palette = LightPalette2()
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}
