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
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        expected = try values.decode(String.self, forKey: .expected)
        date = try values.decode(Date.self, forKey: .date)
        rows = try values.decode([RowModel].self, forKey: .rows)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(expected, forKey: .expected)
        try container.encode(date, forKey: .date)
        try container.encode(rows, forKey: .rows)
    }
} 

extension Date {
    var startOfNextDay: Date {
        return Calendar.current.nextDate(after: self, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
    var secondsUntilTheNextDay: TimeInterval {
        return startOfNextDay.timeIntervalSince(self) 
    }
}

public struct DailyState : RawRepresentable
{
    let expected: String
    let date: Date
    let rows: [RowModel]
    
    var isStale: Bool {
        !isFresh
    }
    
    var age: TimeInterval {
        Date().timeIntervalSince(date)
    }
    
    // might be unknown. Convenience debugging prop
    var remainingTtl: TimeInterval? {
        Date().secondsUntilTheNextDay
//        10 - age
    }
    
    var isFresh: Bool {
//        (remainingTtl ?? -1) > 0
        Calendar.current.isDateInToday(self.date)
    }
    
    init(expected: String) {
//        let expected = String(randomLength: 5)
        
        self.date = Date()
        self.expected = expected
        self.rows = (0..<5).map {
            _ in RowModel(expected: expected)
        }
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
