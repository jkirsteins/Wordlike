import Foundation

enum BuildInfo {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }

    static var gitSHARaw: String {
        Bundle.main.infoDictionary?["GITCommitSHA"] as? String ?? "unknown"
    }

    static var dirty: Bool {
        gitSHARaw.hasSuffix("-dirty")
    }

    static var gitSHA: String {
        if dirty {
            return String(gitSHARaw.dropLast("-dirty".count))
        }
        return gitSHARaw
    }

    static var gitBranch: String {
        Bundle.main.infoDictionary?["GITBranch"] as? String ?? "unknown"
    }
}
