import SwiftUI

fileprivate struct DebugKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// Set to true to enable debug messages
    /// and visualizations.
    var debug: Bool {
        get { self[DebugKey.self] }
        set { self[DebugKey.self] = newValue }
    }
}


