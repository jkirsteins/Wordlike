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
            return text.components(separatedBy: "\n").map {
                $0.uppercased()
            }
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    let name: String
    let seed: Int 

    static let MAR_22_2022 = Date(timeIntervalSince1970: 1647966002) 
    
    func canSubmit(word: String, reason: inout String?) -> Bool {
        /* To avoid accidentally breaking input files,
         do some checks centrally (e.g. we can check length
         just here, instead of ensuring every input
         file doesn't contain an invalid short/empty line) */
        guard word.count == 5 else {
            reason = "Not enough letters"
            return false
        } 
        
        guard guesses.contains(word.uppercased()) else {
            reason = "Not in word list"
            return false
        }
        
        reason = nil
        return true
    }
    
    func answer(at todayIndex: Int) -> String {
        answers[todayIndex % answers.count]
    }
    
    init(
        name: String, 
        seed: Int = 14384982345
    )
    {
        self.name = name
        self.seed = seed
    }
}

struct TestView: View {
    var body: some View {
        Text("Test view")
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
