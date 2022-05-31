import SwiftUI

struct Stats : RawRepresentable {
    let played: Int 
    let won: Int
    let maxStreak: Int 
    let streak: Int 
    let guessDistribution: [Int]
    let lastWinAt: Date?
    
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
    
    public init(played: Int, won: Int, maxStreak: Int, streak: Int, guessDistribution: [Int], lastWinAt: Date?) {
        self.played = played 
        self.won = won 
        self.maxStreak = maxStreak
        self.streak = streak 
        self.guessDistribution = guessDistribution
        self.lastWinAt = lastWinAt
    } 
                
    public init() {
        self.played = 0 
        self.won = 0
        self.maxStreak = 0
        self.streak = 0
        self.guessDistribution = [0,0,0,0,0,0]
        self.lastWinAt = nil
    }
    
    /// Method to use to generate an updated
    /// stats instance, given state of a turn.
    func update(from game: GameState, with ps: TurnCounter) -> Stats {
        
        // Turn can be incomplete (i.e. !isComplete, 
        // e.g. when we want to
        // break a streak when the turn times out), 
        // BUT 
        // it should not be tallied before.
        guard !game.isTallied else {
            return self 
        }
        
        let streakablePeriods: Bool 
        if let lastWinAt = self.lastWinAt {
            streakablePeriods = ps.point(lastWinAt, isInPrecedingPeriodFrom: game.date)
        } else {
            streakablePeriods = false
        }
        
        let newStreak = (streakablePeriods && game.isWon ? self.streak : 0) + (game.isWon ? 1 : 0)
        
        let newDistribution: [Int] = (0..<GameState.MAX_ROWS).map {
            ix in 
            
            var result: Int 
            
            if self.guessDistribution.count > ix {
                result = self.guessDistribution[ix]
            } else {
                result = 0
            }
            
            // Only increase tally if game was won
            if game.isWon && (ix + 1) == game.submittedRows {
                result += 1
            }
            
            return result
        }
        
        // Only count games as played if any rows submitted
        let didPlay = game.rows.filter {
            $0.isSubmitted
        }.count > 0
        
        return Stats(
            played: didPlay ? self.played + 1 : self.played, 
            won: self.won + (game.isWon ? 1 : 0), 
            maxStreak: (game.isWon ? max(newStreak, self.maxStreak) : self.maxStreak),  
            streak: newStreak, 
            guessDistribution: newDistribution,
            lastWinAt: (game.isWon ? Date() : self.lastWinAt)
        )
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
        case lastWinAt
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        played = try values.decode(Int.self, forKey: .played)
        won = try values.decode(Int.self, forKey: .won)
        maxStreak = try values.decode(Int.self, forKey: .maxStreak)
        streak = try values.decode(Int.self, forKey: .streak)
        guessDistribution = try values.decode([Int].self, forKey: .guessDistribution)
        lastWinAt = try values.decode(Optional<Date>.self, forKey: .lastWinAt)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(played, forKey: .played)
        try container.encode(won, forKey: .won)
        try container.encode(maxStreak, forKey: .maxStreak)
        try container.encode(streak, forKey: .streak)
        try container.encode(guessDistribution, forKey: .guessDistribution)
        try container.encode(lastWinAt, forKey: .lastWinAt)
    }
}

