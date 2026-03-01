import SwiftUI
import Foundation

class WordValidator : ObservableObject
{
    static func letterNumberMsg(_ ix: Int) -> String {
        guard let ordinal = (ix+1).ordinal else {
            return "Letter \(ix+1)"
        }
        
        let result = "\(ordinal) letter"
        return NSLocalizedString(result, comment: "")
    }
    
    static func testing(_ words: [String]) -> WordValidator {
        let v = WordValidator(locale: .en_US)
        let wt = WordTree(locale: .en_US)
        words.forEach { let _ = wt.add(word: $0) }
        v.initialize(answers: words, guessTree: wt)
        return v
    }
    
    /// Validator protocol 
    func initialize(answers: [String], guessTree: WordTree) {
        self.answers = answers
        self.guessTree = guessTree
        ready = true
    }
    
    @Published var ready: Bool = false
    
    func answer(at turnIndex: Int) -> WordModel? {
        guard let answers = answers else { return nil }
        
        return WordModel(
            answers[turnIndex % answers.count],
            locale: locale.nativeLocale)
    }
    
    func canSubmit(
        word: WordModel, 
        expected: WordModel,
        model: [RowModel]?,
        mustMatchKnown: Bool,    // e.g. hard mode
        reason: inout LocalizedStringKey?) -> WordModel? {
            
            if word == expected {
                reason = nil
                return expected
            }
            
            guard let guessTree = self.guessTree else {
                reason = "Wait a sec, loading words..."
                return nil
            } 
            
            /* To avoid accidentally breaking input files,
             do some checks centrally (e.g. we can check length
             just here, instead of ensuring every input
             file doesn't contain an invalid short/empty line) */
            guard word.count == 5 else {
                reason = "Not enough letters"
                return nil
            }
            
            return guessTree.contains(
                word: word, 
                mustMatch: mustMatchKnown ? model : nil,
                reason: &reason)
        }
    
    /// Other stuff
    var answers: [String]? = nil
    var guessTree: WordTree? = nil
        
    static func loadAnswers(seed: Int, locale: GameLocale) -> [String] {
        let baseName = "\(locale.fileBaseName)_A"

        // Gen 0: use loadRaw to preserve original array layout (including
        // empties) so that shuffling produces the same index mapping as
        // before the empty-string fix.
        var rng0 = ArbitraryRandomNumberGenerator(seed: UInt64(seed))
        var gen0Shuffled = Self.loadRaw(baseName).shuffled(using: &rng0)

        // Replace empty entries with valid words
        let validWords = gen0Shuffled.filter { !$0.isEmpty }
        if !validWords.isEmpty {
            for i in gen0Shuffled.indices where gen0Shuffled[i].isEmpty {
                gen0Shuffled[i] = validWords[i % validWords.count]
            }
        }

        var result = gen0Shuffled

        // Append additional generations (gen 1, 2, ...) if files exist.
        // Each generation uses a different seed offset so its shuffle is
        // independent of gen 0.
        var gen = 1
        while Bundle.main.url(forResource: "\(baseName)_\(gen)", withExtension: "txt") != nil {
            var rng = ArbitraryRandomNumberGenerator(seed: UInt64(seed) &+ UInt64(gen))
            result.append(contentsOf: Self.load("\(baseName)_\(gen)").shuffled(using: &rng))
            gen += 1
        }

        return result
    }
    
    static func loadGuessTree(locale: GameLocale) -> WordTree {
        return WordTree(
            words: Self.loadGuesses(locale: locale),
            locale: locale.nativeLocale
        )
    }
    
    static func loadGuesses(locale: GameLocale) -> [WordModel] {
        Self.load("\(locale.fileBaseName)_G").map {
            WordModel($0, locale: locale.nativeLocale)
        }
    }
    
    /// Load words from a file, filtering empty lines.
    static func load(_ name: String) -> [String] {
        guard let fileUrl = Bundle.main.url(forResource: name, withExtension: "txt") else {
            fatalError("Data not found: \(name)")
        }
        do {
            let text = try String(contentsOf: fileUrl, encoding: .utf8)
            return text.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty && !$0.hasPrefix("#") }
                .map { $0.uppercased() }
        } catch {
            fatalError(String(describing: error))
        }
    }

    /// Load words preserving the original array layout (including empties)
    /// so that shuffling produces the same index mapping as before the fix.
    static func loadRaw(_ name: String) -> [String] {
        guard let fileUrl = Bundle.main.url(forResource: name, withExtension: "txt") else {
            fatalError("Data not found: \(name)")
        }
        do {
            let text = try String(contentsOf: fileUrl, encoding: .utf8)
            return text.components(separatedBy: "\n").map {
                $0.uppercased()
            }
        } catch {
            fatalError(String(describing: error))
        }
    }
    
    let locale: GameLocale
    let seed: Int 
    
    /// Constant used as the start date of counting 
    /// the turns.
    /// TODO: move somewhere else
    static let MAR_22_2022 = Date(timeIntervalSince1970: 1647966002) 
    
    init(
        locale: GameLocale, 
        seed: Int? = nil 
    )
    {
        self.locale = locale
        self.seed = seed ?? 14384982345
    }
}

struct InternalLetterNumberMessageTest: View {
    let validator: WordValidator = {
        let r = WordValidator(
            locale: .lv_LV(simplified: true))
        let a = WordValidator.loadAnswers(
            seed: r.seed, 
            locale: r.locale)
        let gt = WordValidator.loadGuessTree(
            locale: r.locale)
        
        r.initialize(answers: a, guessTree: gt)
        return r
    }()
    
    var testAmbiguousSubmit: AnyView {
        let word = WordModel(characters: [
            MultiCharacterModel("p", locale: .lv_LV),
            MultiCharacterModel("l", locale: .lv_LV),
            MultiCharacterModel("uū", locale: .lv_LV),
            MultiCharacterModel("k", locale: .lv_LV),
            MultiCharacterModel("a", locale: .lv_LV),
        ])
        let expected = WordModel("plūka", locale: .lv_LV)
        
        var reason: LocalizedStringKey? = nil
        let result = validator.canSubmit(
            word: word, 
            expected: expected, 
            model: nil, 
            mustMatchKnown: false, 
            reason: &reason)
        
        return AnyView(VStack {
            Text("Can submit ambiguous and have it match the expected")
            Text("Expected: \(expected.displayValue)")
            Text("Got: \(result?.displayValue ?? "none")").testColor(good: result?.displayValue == "plūka")
            Text("Reason: \(String(describing: reason))").testColor(good: reason == nil)
        })
    }
    
    var body: some View {
        VStack {
        Text(verbatim: "0 == \(WordValidator.letterNumberMsg(0)) ==> 1st")
            Text(verbatim: "2 == \(WordValidator.letterNumberMsg(2)) ==> 3rd")
            Text(verbatim: "21 == \(WordValidator.letterNumberMsg(21)) ==> 22nd")
        }
        
        testAmbiguousSubmit
    }
}

struct InternalLetterNumberMessageTest_Previews: PreviewProvider {
    static var previews: some View {
        InternalLetterNumberMessageTest()
    }
}

