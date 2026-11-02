import SwiftUI

private struct DebugKey: EnvironmentKey {
    static let defaultValue = false
}

private struct ToggleDebugKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    /// Flips debug mode on/off (set by the root view).
    var toggleDebug: () -> Void {
        get { self[ToggleDebugKey.self] }
        set { self[ToggleDebugKey.self] = newValue }
    }

    /// Set to true to enable debug messages
    /// and visualizations.
    var debug: Bool {
        get { self[DebugKey.self] }
        set { self[DebugKey.self] = newValue }
    }
}
