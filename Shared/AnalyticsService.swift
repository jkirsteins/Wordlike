import DatadogRUM
import Foundation

protocol AnalyticsService: Sendable {
    func trackAction(name: String, attributes: [String: any Encodable])
    func trackError(message: String, source: String, attributes: [String: any Encodable])
}

struct NoOpAnalyticsService: AnalyticsService {
    func trackAction(name: String, attributes: [String: any Encodable]) {}
    func trackError(message: String, source: String, attributes: [String: any Encodable]) {}
}

struct DatadogAnalyticsService: AnalyticsService {
    func trackAction(name: String, attributes: [String: any Encodable]) {
        RUMMonitor.shared().addAction(
            type: .custom,
            name: name,
            attributes: attributes
        )
    }

    func trackError(message: String, source: String, attributes: [String: any Encodable]) {
        var attrs = attributes
        attrs["error.source"] = source
        RUMMonitor.shared().addError(
            message: message,
            source: .custom,
            attributes: attrs
        )
    }
}

enum Analytics {
    static let shared: AnalyticsService = {
        if Bundle.main.infoDictionary?["DatadogClientToken"] is String {
            return DatadogAnalyticsService()
        }
        return NoOpAnalyticsService()
    }()
}
