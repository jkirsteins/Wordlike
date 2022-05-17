import SwiftUI

struct TileConfig {
    let colorOverride: Color? 
    let showCursor: Bool 
    
    init(colorOverride: Color? = nil, showCursor: Bool = false) {
        self.colorOverride = colorOverride 
        self.showCursor = false 
    }
}

extension EnvironmentValues {
    /// Whether the current tile
    /// should have a config override.
    var tileConfig: TileConfig {
        get { self[TileConfigKey.self] }
        set { self[TileConfigKey.self] = newValue }
    }
}

fileprivate struct TileConfigKey: EnvironmentKey {
    static let defaultValue: TileConfig = TileConfig() 
}
