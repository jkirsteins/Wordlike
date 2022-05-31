import SwiftUI

/// Shared handling of input (used by hardware keyboard
/// handler, and the virtual keyboard buttons)
extension GameState {
    /// Backspace key
    func deleteBackward() {
        guard !self.isCompleted else {
            return
        }
        
        guard 
            let row = self.rows.first(where: { !$0.isSubmitted }),
            let ix = self.activeIx else {
                // no editable rows
                return 
            }
        
        self.rows[ix] = RowModel(
            word: row.word.dropLast(),
            expected: row.expected,
            isSubmitted: row.isSubmitted)
    }
    
    /// Letter key
    func insertText(letter: MultiCharacterModel) {
        guard !self.isCompleted else {
            return
        }
        
        guard 
            let row = self.rows.first(where: { !$0.isSubmitted }),
            let ix = self.activeIx
        else {
            // no editable rows
            return 
        }
        
        self.rows[ix] = RowModel(
            word:  row.word.tryAdd(letter),
            expected: row.expected,
            isSubmitted: row.isSubmitted)
    }
    
    /// Submit key
    func submit(
        validator: WordValidator, 
        hardMode: Bool,
        toastMessageCenter: ToastMessageCenter
    ) {
        guard !self.isCompleted else {
            return
        }
        
        let first = self.rows.first
        let firstSubmitted = self.rows.first(where: { !$0.isSubmitted })
        
        guard 
            let current = firstSubmitted ?? first,
            let currentIx = self.activeIx
        else {
            // no rows?
            return
        }
        
        var message: LocalizedStringKey? = nil
        defer {
            if let newMessage = message {
                toastMessageCenter.set(newMessage)
            }
        }
        
        // If word doesn't match,
        // don't set isSubmitted
        guard let submittedWord = validator.canSubmit(
            word: current.word,
            expected: current.expected,
            model: self.rows,
            mustMatchKnown: hardMode,
            reason: &message) else {
                let updatedRow = RowModel(
                    word: current.word,
                    expected: current.expected,
                    isSubmitted: false,
                    attemptCount: current.attemptCount + 1)
                
                self.rows[currentIx] = updatedRow
                return
            } 
        
        let submitted = RowModel(
            word: submittedWord,
            expected: current.expected,
            isSubmitted: true,
            attemptCount: 0)
        self.rows[currentIx] = submitted
    }
}
