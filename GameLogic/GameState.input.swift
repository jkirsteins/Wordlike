import SwiftUI

/// Shared handling of input (used by hardware keyboard
/// handler, and the virtual keyboard buttons)
extension GameState {
    /// Backspace key
    func deleteBackward() {
        guard !isCompleted else {
            return
        }

        guard let row = rows.first(where: { !$0.isSubmitted }),
              let ix = activeIx
        else {
            // no editable rows
            return
        }

        rows[ix] = RowModel(
            word: row.word.dropLast(),
            expected: row.expected,
            isSubmitted: row.isSubmitted
        )
    }

    /// Letter key
    func insertText(letter: MultiCharacterModel) {
        guard !isCompleted else {
            return
        }

        guard let row = rows.first(where: { !$0.isSubmitted }),
              let ix = activeIx
        else {
            // no editable rows
            return
        }

        rows[ix] = RowModel(
            word: row.word.tryAdd(letter),
            expected: row.expected,
            isSubmitted: row.isSubmitted
        )
    }

    /// Submit key
    func submit( // swiftlint:disable:this function_body_length
        validator: WordValidator,
        hardMode: Bool,
        toastMessageCenter: ToastMessageCenter
    ) {
        guard !isCompleted else {
            return
        }

        let first = rows.first
        let firstSubmitted = rows.first(where: { !$0.isSubmitted })

        guard let current = firstSubmitted ?? first,
              let currentIx = activeIx
        else {
            // no rows?
            return
        }

        var message: String? = nil
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
            model: rows,
            mustMatchKnown: hardMode,
            reason: &message
        )
        else {
            let updatedRow = RowModel(
                word: current.word,
                expected: current.expected,
                isSubmitted: false,
                attemptCount: current.attemptCount + 1
            )

            Analytics.shared.trackAction(
                name: "game.invalid_word",
                attributes: ["game_locale": expected.locale.fileBaseName]
            )
            rows[currentIx] = updatedRow
            return
        }

        let submitted = RowModel(
            word: submittedWord,
            expected: current.expected,
            isSubmitted: true,
            attemptCount: 0
        )
        rows[currentIx] = submitted
        Analytics.shared.trackAction(
            name: "game.row_submitted",
            attributes: [
                "game_locale": expected.locale.fileBaseName,
                "attempt_number": "\(currentIx + 1)",
            ]
        )
    }
}
