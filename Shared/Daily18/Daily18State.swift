import Foundation

enum Daily18Phase: String, Codable, Equatable {
    case notStarted
    case inProgress
    case finished
}

enum Daily18Mark: String, Codable, Equatable {
    case pending
    case solved
    case failed
}

/// Persistent state of one day's 18 vardi run.
/// Stored under `Daily18Storage.stateKey`.
struct Daily18State: RawRepresentable {
    static let wordCount = 18
    static let timePerWord = 30

    var day: Int
    var marks: [Daily18Mark]
    var currentIndex: Int
    var remainingSeconds: Int
    var phase: Daily18Phase
    var isTallied: Bool
    var firstPlayedAt: Date?
    var finishedAt: Date?

    init(day: Int) {
        self.day = day
        self.marks = Array(repeating: .pending, count: Self.wordCount)
        self.currentIndex = 0
        self.remainingSeconds = Self.timePerWord
        self.phase = .notStarted
        self.isTallied = false
        self.firstPlayedAt = nil
        self.finishedAt = nil
    }

    var score: Int {
        marks.filter { $0 == .solved }.count
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
        // `.sortedKeys` makes the JSON deterministic across separate encode
        // calls. Without it, `Daily18State`'s `Equatable` conformance
        // resolves to the stdlib's `RawRepresentable`-default `==` (which
        // compares `rawValue` strings), and unordered JSON keys would make
        // that comparison flaky for logically-equal values.
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(self),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
}

extension Daily18State: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case day
        case marks
        case currentIndex
        case remainingSeconds
        case phase
        case isTallied
        case firstPlayedAt
        case finishedAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.day = try values.decode(Int.self, forKey: .day)
        self.marks = try values.decode([Daily18Mark].self, forKey: .marks)
        self.currentIndex = try values.decode(Int.self, forKey: .currentIndex)
        self.remainingSeconds = try values.decode(Int.self, forKey: .remainingSeconds)
        self.phase = try values.decode(Daily18Phase.self, forKey: .phase)
        self.isTallied = try values.decode(Bool.self, forKey: .isTallied)
        self.firstPlayedAt = try values.decodeIfPresent(Date.self, forKey: .firstPlayedAt)
        self.finishedAt = try values.decodeIfPresent(Date.self, forKey: .finishedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(day, forKey: .day)
        try container.encode(marks, forKey: .marks)
        try container.encode(currentIndex, forKey: .currentIndex)
        try container.encode(remainingSeconds, forKey: .remainingSeconds)
        try container.encode(phase, forKey: .phase)
        try container.encode(isTallied, forKey: .isTallied)
        try container.encodeIfPresent(firstPlayedAt, forKey: .firstPlayedAt)
        try container.encodeIfPresent(finishedAt, forKey: .finishedAt)
    }
}
