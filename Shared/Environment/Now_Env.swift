import SwiftUI

private struct NowKey: EnvironmentKey {
    static let defaultValue: () -> Date = { Date() }
}

extension EnvironmentValues {
    var now: () -> Date {
        get { self[NowKey.self] }
        set { self[NowKey.self] = newValue }
    }
}
