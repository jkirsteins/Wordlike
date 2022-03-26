import SwiftUI
import GameplayKit

struct ArbitraryRandomNumberGenerator : RandomNumberGenerator {
    
    mutating func next() -> UInt64 {
        // GKRandom produces values in [INT32_MIN, INT32_MAX] range; hence we need two numbers to produce 64-bit value.
        let next1 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
        let next2 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
        return next1 ^ (next2 << 32)
    }
    
    init(seed: UInt64) {
        self.gkrandom = GKMersenneTwisterRandomSource(seed: seed)
    }
    
    private let gkrandom: GKRandom
}

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    
    init(seed: Int) {
        // Set the random seed
        srand48(seed)
    }
    
    func next() -> UInt64 {
        // drand48() returns a Double, transform to UInt64
        return withUnsafeBytes(of: drand48()) { bytes in
            bytes.load(as: UInt64.self)
        }
    }
}

class WordValidator : ObservableObject
{
    lazy var answers: [String] = {
        var random = ArbitraryRandomNumberGenerator(seed: UInt64(self.seed))
        
        return Self.load("\(name)_A").shuffled(using: &random)
    }()
    
    lazy var guesses = Self.load("\(name)_G")
    
    
    
    static func load(_ name: String) -> [String] {
        do {
            guard let fileUrl = Bundle.main.url(forResource: name, withExtension: "txt") else { 
                fatalError("Data not found: \(name)") 
            }
            
            let text = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            return text.components(separatedBy: "\n")
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    let name: String
    let seed: Int 
    let start: Date
    
    static let MAR_22_2022 = Date(timeIntervalSince1970: 1647966002) 
    
    var todayIndex: Int {
        indexBetween(start, and: Date())
    }
    
    func indexBetween(_ start: Date, and end: Date) -> Int {
        Calendar.current.dateComponents(
            [.day], 
            from: Calendar.current.startOfDay(for: start), 
            to: Calendar.current.startOfDay(for: end)).day!
    }
    
    func canSubmit(word: String) -> Bool {
        guesses.contains(word)
//        true
    }
    
    var todayAnswer: String {
        answers[todayIndex % answers.count]
    } 
    
    init(
        name: String, 
        seed: Int = 14384982345,
        start: Date = WordValidator.MAR_22_2022) 
    {
        self.name = name
        self.seed = seed
        self.start = start
    }
}

struct TestView: View {
    var body: some View {
        let x = WordValidator(name: "en", seed: 0)
        return VStack {
            Text("Index on same day: \(x.indexBetween(WordValidator.MAR_22_2022, and: WordValidator.MAR_22_2022))")
            
            Text("Index on 1 sec before midnight: \(x.indexBetween(WordValidator.MAR_22_2022, and: Date(timeIntervalSince1970: 1647990001 - 2)))")
            
            Text("Index on next day (1 sec after midnight): \(x.indexBetween(WordValidator.MAR_22_2022, and: Date(timeIntervalSince1970: 1647990001)))")
            
            Text("Index 1 day after: \(x.indexBetween(WordValidator.MAR_22_2022, and: WordValidator.MAR_22_2022 + 86400))")
            
            Text("Index on Mar 27 (from Mar 22): \(x.indexBetween(WordValidator.MAR_22_2022, and: Date(timeIntervalSince1970: 1648336091)))")
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
