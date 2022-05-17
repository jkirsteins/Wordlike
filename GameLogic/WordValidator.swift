import SwiftUI

class WordValidator : ObservableObject
{
    static func letterNumberMsg(_ ix: Int) -> String {
        guard let ordinal = (ix+1).ordinal else {
            return "Letter \(ix+1)"
        }
        
        return "\(ordinal) letter"
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
        reason: inout String?) -> WordModel? {
            
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
        var random = ArbitraryRandomNumberGenerator(seed: UInt64(seed))
        
        return Self.load("\(locale.fileBaseName)_A").shuffled(using: &random)
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
        
        var reason: String? = nil
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
            Text("Reason: \(reason ?? "none")").testColor(good: reason == nil)
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

