import SwiftUI

/// Aggregate 18 vardi statistics, stored under `Daily18Storage.statsKey`.
struct Daily18Stats: RawRepresentable {
    static let trophyThreshold = 8

    let played: Int
    /// Index == score (0...18).
    let scoreDistribution: [Int]
    let trophyStreak: Int
    let maxTrophyStreak: Int
    let perfectDays: Int
    let lastTrophyAt: Date?

    init(
        played: Int,
        scoreDistribution: [Int],
        trophyStreak: Int,
        maxTrophyStreak: Int,
        perfectDays: Int,
        lastTrophyAt: Date?
    ) {
        self.played = played
        self.scoreDistribution = scoreDistribution
        self.trophyStreak = trophyStreak
        self.maxTrophyStreak = maxTrophyStreak
        self.perfectDays = perfectDays
        self.lastTrophyAt = lastTrophyAt
    }

    init() {
        self.played = 0
        self.scoreDistribution = Array(repeating: 0, count: Daily18State.wordCount + 1)
        self.trophyStreak = 0
        self.maxTrophyStreak = 0
        self.perfectDays = 0
        self.lastTrophyAt = nil
    }

    func update(score: Int, finishedAt: Date, with counter: TurnCounter) -> Daily18Stats {
        let isTrophy = score >= Self.trophyThreshold

        let streakable: Bool
        if let lastTrophyAt = lastTrophyAt {
            streakable = counter.point(lastTrophyAt, isInPrecedingPeriodFrom: finishedAt)
        } else {
            streakable = false
        }

        let newStreak = isTrophy ? (streakable ? trophyStreak : 0) + 1 : 0

        var distribution = scoreDistribution
        let requiredCount = Daily18State.wordCount + 1
        if distribution.count < requiredCount {
            distribution += Array(repeating: 0, count: requiredCount - distribution.count)
        }
        if (0 ..< requiredCount).contains(score) {
            distribution[score] += 1
        }

        return Daily18Stats(
            played: played + 1,
            scoreDistribution: distribution,
            trophyStreak: newStreak,
            maxTrophyStreak: max(newStreak, maxTrophyStreak),
            perfectDays: perfectDays + (score == Daily18State.wordCount ? 1 : 0),
            lastTrophyAt: isTrophy ? finishedAt : lastTrophyAt
        )
    }

    func widthRatio(score: Int) -> CGFloat {
        let maxCount = CGFloat(scoreDistribution.max() ?? 0)
        guard maxCount > 0, scoreDistribution.indices.contains(score) else { return 0 }
        return CGFloat(scoreDistribution[score]) / maxCount
    }

    // RawRepresentable (JSON string, mirrors Stats)

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = result
    }

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
}

extension Daily18Stats: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case played
        case scoreDistribution
        case trophyStreak
        case maxTrophyStreak
        case perfectDays
        case lastTrophyAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.played = try values.decode(Int.self, forKey: .played)
        self.scoreDistribution = try values.decode([Int].self, forKey: .scoreDistribution)
        self.trophyStreak = try values.decode(Int.self, forKey: .trophyStreak)
        self.maxTrophyStreak = try values.decode(Int.self, forKey: .maxTrophyStreak)
        self.perfectDays = try values.decode(Int.self, forKey: .perfectDays)
        self.lastTrophyAt = try values.decodeIfPresent(Date.self, forKey: .lastTrophyAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(played, forKey: .played)
        try container.encode(scoreDistribution, forKey: .scoreDistribution)
        try container.encode(trophyStreak, forKey: .trophyStreak)
        try container.encode(maxTrophyStreak, forKey: .maxTrophyStreak)
        try container.encode(perfectDays, forKey: .perfectDays)
        try container.encodeIfPresent(lastTrophyAt, forKey: .lastTrophyAt)
    }
}

/// Hardcoded score-to-percentile mapping, cloned from 18words.com.
enum Daily18TrophyTier {
    static func percent(forScore score: Int) -> Int? {
        switch score {
        case 18: return 1
        case 17: return 2
        case 16: return 3
        case 15: return 5
        case 12 ... 14: return 10
        case 10 ... 11: return 20
        case 8 ... 9: return 50
        default: return nil
        }
    }

    static func emoji(forScore score: Int) -> String {
        switch score {
        case 18: return "👑"
        case 15 ... 17: return "🏆"
        case 8 ... 14: return "🏅"
        default: return "💔"
        }
    }

    /// Localized line for the results screen and share text.
    static func line(forScore score: Int) -> String {
        guard let percent = percent(forScore: score) else {
            return NSLocalizedString("No trophy earned today", comment: "")
                + " " + emoji(forScore: score)
        }
        let format = NSLocalizedString("Top %lld%% of players today", comment: "")
        return String(format: format, percent) + " " + emoji(forScore: score)
    }
}
