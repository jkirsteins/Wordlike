import SwiftUI

private struct GlobalTapCountKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var globalTapCount: Binding<Int> {
        get { self[GlobalTapCountKey.self] }
        set { self[GlobalTapCountKey.self] = newValue }
    }
}
