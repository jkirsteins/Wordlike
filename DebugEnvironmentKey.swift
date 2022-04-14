import SwiftUI

private struct DebugEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var debug: Bool {
        get { self[DebugEnvironmentKey.self] }
        set { self[DebugEnvironmentKey.self] = newValue }
    }
}


