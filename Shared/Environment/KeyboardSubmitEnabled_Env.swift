import SwiftUI

fileprivate struct KeyboardSubmitEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    /// Set to false to prevent submitting on a keyboard.
    /// E.g. for when the word list is not ready yet
    var keyboardSubmitEnabled: Bool {
        get { self[KeyboardSubmitEnabledKey.self] }
        set { self[KeyboardSubmitEnabledKey.self] = newValue }
    }
}
