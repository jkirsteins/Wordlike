import SwiftUI

extension Optional: RawRepresentable where Wrapped == DailyState {
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
        case isTallied // deprecated
        case state
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        expected = try values.decode(WordModel.self, forKey: .expected)
        date = try values.decode(Date.self, forKey: .date)
        rows = try values.decode([RowModel].self, forKey: .rows)
        
        /*
         Try to deserialize a bool first since older
         versions didn't have the state property.
         
         If not present, try deserializing the state.
         */
        let isTallied: Bool? = (try? values.decode(Bool.self, forKey: .isTallied))
        if isTallied == true {
            state = .finished(isTallied: true, isWon: true)
        } else {
            state = (try? values.decode(DailyState.State.self, forKey: .state)) ?? .inProgress
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(expected, forKey: .expected)
        try container.encode(date, forKey: .date)
        try container.encode(rows, forKey: .rows)
        try container.encode(state, forKey: .state)
    }
} 

public struct DailyState : RawRepresentable
{
    enum State : Codable, Equatable {
        // Transient value for moving from `isTallied` to
        // `state` serialization
        case unknown
        
        case notStarted
        case inProgress
        case finished(isTallied: Bool, isWon: Bool)
        
        var isTallied: Bool {
            switch(self) {
                case .finished(let isTallied, isWon: _):
                return isTallied
                default:
                return false
            }
        }
    }
    
    /// Expected word
    let expected: WordModel
    
    /// When was this state created?
    let date: Date
    
    let state: DailyState.State

    let rows: [RowModel]
    
    init(expected: WordModel, date: Date, rows: [RowModel], state: State) {
        self.expected = expected
        self.date = date 
        self.rows = rows
        self.state = state
    }
    
    init(expected: WordModel) {
        self.date = Date()
        self.expected = expected
        self.rows = (0..<GameState.MAX_ROWS).map {
            _ in RowModel(expected: expected)
        }
        
        self.state = .notStarted
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
