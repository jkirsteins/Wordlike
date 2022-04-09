import SwiftUI

extension Optional: Codable, RawRepresentable where Wrapped == DailyState {
    public init?(rawValue: String) {
        self = DailyState(rawValue: rawValue)
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

extension DailyState : Codable, Equatable 
{
    enum CodingKeys: String, CodingKey {
        case expected
        case date
        case rows
        case isTallied
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        expected = try values.decode(String.self, forKey: .expected)
        date = try values.decode(Date.self, forKey: .date)
        rows = try values.decode([RowModel].self, forKey: .rows)
        isTallied = (try? values.decode(Bool.self, forKey: .isTallied)) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(expected, forKey: .expected)
        try container.encode(date, forKey: .date)
        try container.encode(rows, forKey: .rows)
        try container.encode(isTallied, forKey: .isTallied)
    }
} 

public struct DailyState : RawRepresentable
{
    /// Expected word
    let expected: String
    
    /// When was this state created?
    let date: Date
    
    /// If state is tallied, it has been added to
    /// the player's statistics, and should not
    /// be considered again.
    let isTallied: Bool 
    
    let rows: [RowModel]
    
    init(expected: String, date: Date, rows: [RowModel], isTallied: Bool) {
        self.expected = expected
        self.date = date 
        self.rows = rows 
        self.isTallied = isTallied
    }
    
    init(expected: String) {
        self.date = Date()
        self.expected = expected
        self.rows = (0..<GameState.MAX_ROWS).map {
            _ in RowModel(expected: expected)
        }
        self.isTallied = false
    }
    
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
