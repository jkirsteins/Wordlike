import SwiftUI

fileprivate struct HasHardwareKeyboardKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var hasHardwareKeyboard: Bool {
        get { self[HasHardwareKeyboardKey.self] }
        set { self[HasHardwareKeyboardKey.self] = newValue }
    }
}
