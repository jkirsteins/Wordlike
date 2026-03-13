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
}

enum StatsTransfer {
    private static var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }

    static func buildExport() -> StatsExportDocument {
        var exportStats: [String: ExportableStats] = [:]

        for locale in Locale.supportedLocales {
            let key = "stats.\(locale.fileBaseName)"
            guard
                let raw = UserDefaults.standard.string(forKey: key),
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
        for locale in Locale.supportedLocales {
            let key = "turnState.\(locale.fileBaseName)"
            if let raw = UserDefaults.standard.string(forKey: key),
               let state = DailyState(rawValue: raw),
               case .finished = state.state {
                turnStates[locale.fileBaseName] = state
            }
        }

        return StatsExportDocument(
            version: 1,
            exportDate: dateFormatter.string(from: Date()),
            stats: exportStats,
            turnStates: turnStates.isEmpty ? nil : turnStates
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
    }

    enum ImportError: Error {
        case unsupportedVersion
    }
}
