import Foundation

struct ExportableStats: Codable {
    let played: Int
    let won: Int
    let currentStreak: Int
    let maxStreak: Int
    let guessDistribution: [Int]
    let lastWinDate: String?
}

struct StatsExportDocument: Codable {
    let version: Int
    let exportDate: String
    let stats: [String: ExportableStats]
    let turnStates: [String: DailyState]?
    let daily18Stats: Daily18Stats?
    let daily18State: Daily18State?
}

enum StatsTransfer {
    /// Locales included in export/import. Deliberately broader than
    /// `Locale.supportedLocales` (menu-visible locales only) so that
    /// hidden EN/GB/FR Wordle stats and turn states still round-trip.
    private static let exportLocales: [Locale] = [.en_US, .en_GB, .fr_FR, .lv_LV]

    private static var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }

    static func buildExport() -> StatsExportDocument {
        var exportStats: [String: ExportableStats] = [:]

        for locale in exportLocales {
            let key = "stats.\(locale.fileBaseName)"
            guard let raw = UserDefaults.standard.string(forKey: key),
                  let stats = Stats(rawValue: raw),
                  stats.played > 0
            else { continue }

            let lastWinDate = stats.lastWinAt.map { dateFormatter.string(from: $0) }
            exportStats[locale.fileBaseName] = ExportableStats(
                played: stats.played,
                won: stats.won,
                currentStreak: stats.streak,
                maxStreak: stats.maxStreak,
                guessDistribution: stats.guessDistribution,
                lastWinDate: lastWinDate
            )
        }

        var turnStates: [String: DailyState] = [:]
        for locale in exportLocales {
            let key = "turnState.\(locale.fileBaseName)"
            if let raw = UserDefaults.standard.string(forKey: key),
               let state = DailyState(rawValue: raw),
               case .finished = state.state
            {
                turnStates[locale.fileBaseName] = state
            }
        }

        var daily18Stats: Daily18Stats?
        if let raw = UserDefaults.standard.string(forKey: Daily18Storage.statsKey),
           let parsed = Daily18Stats(rawValue: raw),
           parsed.played > 0
        {
            daily18Stats = parsed
        }

        var daily18State: Daily18State?
        if let state = Daily18Storage.storedState(), state.phase == .finished {
            daily18State = state
        }

        return StatsExportDocument(
            version: 1,
            exportDate: dateFormatter.string(from: Date()),
            stats: exportStats,
            turnStates: turnStates.isEmpty ? nil : turnStates,
            daily18Stats: daily18Stats,
            daily18State: daily18State
        )
    }

    static func performImport(from document: StatsExportDocument) throws {
        guard document.version == 1 else {
            throw ImportError.unsupportedVersion
        }

        for (localeKey, exportable) in document.stats {
            let lastWinAt: Date?
            if let dateString = exportable.lastWinDate {
                lastWinAt = dateFormatter.date(from: dateString)
            } else {
                lastWinAt = nil
            }

            let stats = Stats(
                played: exportable.played,
                won: exportable.won,
                maxStreak: exportable.maxStreak,
                streak: exportable.currentStreak,
                guessDistribution: exportable.guessDistribution,
                lastWinAt: lastWinAt
            )

            UserDefaults.standard.set(stats.rawValue, forKey: "stats.\(localeKey)")
        }

        if let turnStates = document.turnStates {
            for (localeKey, dailyState) in turnStates {
                guard Calendar.current.isDateInToday(dailyState.date) else { continue }
                UserDefaults.standard.set(dailyState.rawValue, forKey: "turnState.\(localeKey)")
            }
        }

        if let daily18Stats = document.daily18Stats {
            UserDefaults.standard.set(
                daily18Stats.rawValue,
                forKey: Daily18Storage.statsKey
            )
        }

        if let daily18State = document.daily18State,
           daily18State.day == Daily18Storage.makeTurnCounter().turnIndex(at: Date())
        {
            UserDefaults.standard.set(
                daily18State.rawValue,
                forKey: Daily18Storage.stateKey
            )
        }
    }

    enum ImportError: Error {
        case unsupportedVersion
    }
}
