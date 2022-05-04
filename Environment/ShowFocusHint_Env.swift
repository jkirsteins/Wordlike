import SwiftUI

extension EnvironmentValues {
    /// Whether the currently editable tile
    /// should display a blinking cursor or not.
    var showFocusHint: Bool {
        get { self[ShowFocusHintKey.self] }
        set { self[ShowFocusHintKey.self] = newValue }
    }
}

fileprivate struct ShowFocusHintKey: EnvironmentKey {
    static let defaultValue: Bool = false 
}
