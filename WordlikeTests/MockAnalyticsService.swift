import Foundation
@testable import Wordlike

struct TrackedAction {
    let name: String
    let attributes: [String: any Encodable]
}

struct TrackedError {
    let message: String
    let source: String
    let attributes: [String: any Encodable]
}

final class MockAnalyticsService: AnalyticsService, @unchecked Sendable {
    private var _trackedActions: [TrackedAction] = []
    private var _trackedErrors: [TrackedError] = []

    var trackedActions: [TrackedAction] {
        _trackedActions
    }

    var trackedErrors: [TrackedError] {
        _trackedErrors
    }

    func trackAction(name: String, attributes: [String: any Encodable]) {
        _trackedActions.append(TrackedAction(name: name, attributes: attributes))
    }

    func trackError(message: String, source: String, attributes: [String: any Encodable]) {
        _trackedErrors.append(TrackedError(message: message, source: source, attributes: attributes))
    }

    func action(named name: String) -> TrackedAction? {
        trackedActions.first { $0.name == name }
    }

    func hasAction(named name: String) -> Bool {
        trackedActions.contains { $0.name == name }
    }
}
