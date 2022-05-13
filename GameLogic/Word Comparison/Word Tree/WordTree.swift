import SwiftUI

fileprivate class BranchNode {
    var children = Set<Node>()
}

//fileprivate enum ErrorReason {
//    case unmatchedConstraint(CharacterModel, Int)
//    case unaccountedConstraint(CharacterModel)
//    case notFound
//}

fileprivate struct ErrorReason {
    let reason: String
    let depth: Int
}

fileprivate class Node : BranchNode, Hashable {
    let char: CharacterModel
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(char)
        hasher.combine(children)
    }
    
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.char == rhs.char &&
        lhs.children == rhs.children
    }
    
    init(char: CharacterModel) {
        self.char = char
        super.init()
    }
}

fileprivate class Constraints {
    var unaccountedFor = Set<CharacterModel>()
    var exactMatchesPending = [Int : CharacterModel]()
    
    /// As we traverse the tree, there might be multiple
    /// issues with the given word (when a MultiCharModel has
    /// multiple values, we can go down multiple
    /// initially-valid patrs).
    ///
    /// This helps keep track of the depth at which we set
    /// an error reason, and only keep the deepest message.
    var deepestReason = -1
    
    init(from model: [RowModel]) {
        for row in model.filter({ $0.isSubmitted }) {
            for rowIx in 0..<row.word.count {
                let rs = row.revealState(rowIx) 
                
                guard !rs.isMasked else {
                    continue 
                }
                
                let multiChar = row.char(guessAt: rowIx)
                guard 
                    let char = multiChar.values.first,
                    multiChar.values.count == 1 
                else {
                    fatalError("Submitted rows must contain characters with exactly 1 value.")
                }
                
                switch(rs) {
                case .wrongPlace:
                    unaccountedFor.insert(char)
                case .rightPlace:
                    exactMatchesPending[rowIx] = char
                default:
                    break
                }
            }
        }
    }
    
    func canAccept(characters: [CharacterModel], reason: inout ErrorReason?) -> Bool {
        guard characters.count == 5 else {
            reason = ErrorReason(reason: "Not enough letters", depth: 4)
            return false
        }
        
        for ix in 0..<characters.count {
            let expected = exactMatchesPending[ix] 
            guard 
                let expected = expected,
                expected == characters[ix]
            else {
                guard let expected = expected else {
                    continue 
                } 
                
                reason = ErrorReason(
                    reason: "\(WordValidator.letterNumberMsg(ix)) must be \(expected.displayValue)", 
                    depth: ix)
                return false
            }
        }
        
        let accountedFor = Set(characters).intersection(unaccountedFor) 
        guard accountedFor == unaccountedFor else {
            let missing = unaccountedFor.subtracting(accountedFor)
            
            reason = ErrorReason(
                reason: "Guess must contain \(missing.map { $0.displayValue }.joined(separator: ", "))", 
                depth: 4)
            
            return false
        }
        
        return true
    }
}

class WordTree {
    fileprivate let root = BranchNode()
    let locale: Locale
    var count: Int = 0
    
    init(locale: Locale) {
        self.locale = locale 
    }
    
    init(words: [WordModel], locale: Locale) {
        self.locale = locale
        
        for word in words {
            guard word.isUnambiguous else {
                fatalError("Only unambiguous words can be added")
            }
            
            let _ = self.add(characters: word.word.map { $0.values.first! })
        }
    }
    
    func add(word: String) -> Bool {
        return self.add(characters: word.map({ 
            CharacterModel(value: $0, locale: locale) 
        }))
    }
    
    fileprivate func add(characters: [CharacterModel]) -> Bool {
        guard characters.count == 5 else { return false }
        
        defer {
            count += 1
        }
        
        var node: BranchNode = self.root
        
        for char in characters {
            if let nextNode = node.children.first(where: { $0.char == char }) {
                node = nextNode
            } else {
                let nextNode = Node(char: char)
                node.children.insert(nextNode)
                node = nextNode
            }
        }
        
        return true 
    }
    
    func contains(_ word: String) -> WordModel? {
        var reason: String? = nil
        return contains(
            word: WordModel(word, locale: locale),
            mustMatch: nil, 
            reason: &reason
        )
    }
    
    func contains(
        word: String, 
        mustMatch model: [RowModel]?,
        reason: inout String?
    ) -> WordModel?
    {
        contains(
            word: WordModel(word, locale: locale), 
            mustMatch: model, 
            reason: &reason)
    }
    
    func contains(
        word: WordModel, 
        mustMatch model: [RowModel]?,
        reason: inout String?
    ) -> WordModel? {
        let constraints: Constraints?
        if let model = model {
            constraints = Constraints(from: model)
        } else {
            constraints = nil
        }
        
        var internalReason: ErrorReason?
        guard let result = self.contains(
            word: word, 
            constraints: constraints, 
            node: self.root,
            characters: [],
            reason: &internalReason
        ) else {
            reason = internalReason?.reason ?? "Not in word list"
            return nil
        }
        
        reason = nil
        return result
    }
    
    fileprivate func contains(
        word: WordModel, 
        constraints: Constraints?,
        node: BranchNode,
        characters: [CharacterModel],
        reason: inout ErrorReason?) -> WordModel? 
    {
        let charIx = characters.count
        guard charIx < word.count else {
            guard constraints?.canAccept(
                characters: characters, 
                reason: &reason) != false 
            else {
                return nil
            }
            
            return WordModel( characters: characters)
        }
        
        guard word.word.count > charIx else { 
            return nil
        }
        
        var internalReasons = [ErrorReason]()
        
        for char in word.word[charIx].values {
            
            for nextNode in node.children.filter(
                // Only look at nodes that can be a match
                { $0.char == char }
            ) {
                var internalReason: ErrorReason? = nil
                defer {
                    if let internalReason = internalReason {
                        internalReasons.append(internalReason)
                    }
                }
                
                let nextChars = characters + [char]
                
                if let result = contains(
                    word: word, 
                    constraints: constraints, 
                    node: nextNode, 
                    characters: nextChars, 
                    reason: &internalReason) {
                    return result 
                } 
            }
        }
        
        // Bubble up the deepest reason
        reason = internalReasons.max(by: { $0.depth < $1.depth })
        return nil
    }
}

