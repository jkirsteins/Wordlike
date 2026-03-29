import DatadogCore
import DatadogCrashReporting
import DatadogInternal
import DatadogRUM
import Foundation

@MainActor
enum DatadogSetup {
    private(set) static var launchDate = Date()
    static var hasTrackedFirstInteraction = false

    static func initialize() {
        // Force lazy static initialization at launch time
        _ = launchDate

        let analyticsEnabled = UserDefaults.standard.object(
            forKey: SettingsView.ANALYTICS_ENABLED_KEY
        ) as? Bool ?? true

        guard let clientToken = Bundle.main.infoDictionary?["DatadogClientToken"] as? String,
              let applicationID = Bundle.main.infoDictionary?["DatadogApplicationID"] as? String,
              let site = Bundle.main.infoDictionary?["DatadogSite"] as? String,
              !clientToken.isEmpty,
              !applicationID.isEmpty
        else {
            return
        }

        #if DEBUG
        let env = "debug"
        #else
        let env = "production"
        #endif

        Datadog.initialize(
            with: Datadog.Configuration(
                clientToken: clientToken,
                env: env,
                site: datadogSite(from: site),
                service: "wordlike"
            ),
            trackingConsent: analyticsEnabled ? .granted : .notGranted
        )

        RUM.enable(
            with: RUM.Configuration(
                applicationID: applicationID
            )
        )

        CrashReporting.enable()

        let monitor = RUMMonitor.shared()
        monitor.addAttribute(forKey: "git.sha", value: BuildInfo.gitSHA)
        monitor.addAttribute(forKey: "git.branch", value: BuildInfo.gitBranch)
        monitor.addAttribute(forKey: "git.dirty", value: BuildInfo.dirty)
        monitor.addAttribute(
            forKey: "app.language",
            value: Locale.current.language.languageCode?.identifier ?? "en"
        )
    }

    private static func datadogSite(from string: String) -> DatadogSite {
        switch string {
        case "datadoghq.com": .us1
        case "us3.datadoghq.com": .us3
        case "us5.datadoghq.com": .us5
        case "ap1.datadoghq.com": .ap1
        default: .eu1
        }
    }
}
