import SwiftUI

fileprivate struct GameLocaleKey: EnvironmentKey {
    static let defaultValue: GameLocale = .unknown
}

extension EnvironmentValues {
    var gameLocale: GameLocale {
        get { self[GameLocaleKey.self] }
        set { self[GameLocaleKey.self] = newValue }
    }
}
