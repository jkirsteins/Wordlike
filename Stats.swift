import SwiftUI

struct Stats : RawRepresentable {
    let played: Int 
    let won: Int
    let maxStreak: Int 
    let streak: Int 
    let guessDistribution: [Int]
    
    func widthRatio(row: Int) -> CGFloat {
        let maxInt: Int = guessDistribution.max() ?? 0
        let max = CGFloat(maxInt) 
        guard max > 0 else { return 1.0 }
        
        return CGFloat(guessDistribution[row]) / max
    }
    
    var maxRow: Int {
        let maxVal = guessDistribution.max()
        for ix in 0..<guessDistribution.count {
            if guessDistribution[ix] == maxVal {
                return ix
            }
        }
        
        return 0
    }
    
    public init(played: Int, won: Int, maxStreak: Int, streak: Int, guessDistribution: [Int]) {
        self.played = played 
        self.won = won 
        self.maxStreak = maxStreak
        self.streak = streak 
        self.guessDistribution = guessDistribution
    } 
                
    public init() {
        self.played = 0 
        self.won = 0
        self.maxStreak = 0
        self.streak = 0
        self.guessDistribution = [0,0,0,0,0,0]
    }
    
    // RawRepresentable
    
    public init?(rawValue: String)
    {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        
        self = result
    }
    
    public var rawValue: String {
        
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return string
    }
}

extension Stats: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case played 
        case won 
        case maxStreak 
        case streak 
        case guessDistribution
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        played = try values.decode(Int.self, forKey: .played)
        won = try values.decode(Int.self, forKey: .won)
        maxStreak = try values.decode(Int.self, forKey: .maxStreak)
        streak = try values.decode(Int.self, forKey: .streak)
        guessDistribution = try values.decode([Int].self, forKey: .guessDistribution)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(played, forKey: .played)
        try container.encode(won, forKey: .won)
        try container.encode(maxStreak, forKey: .maxStreak)
        try container.encode(streak, forKey: .streak)
        try container.encode(guessDistribution, forKey: .guessDistribution)
    }
}

