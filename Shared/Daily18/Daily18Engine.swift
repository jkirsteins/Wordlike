import Foundation

/// UI-independent 18 vardi game state machine. The hosting view owns
/// the 1 Hz timer and calls `tick()`; everything else is event-driven.
final class Daily18Engine: ObservableObject {
    let puzzle: Daily18Puzzle
    let isAccepted: (String) -> Bool

    @Published private(set) var state: Daily18State

    /// Indices into `currentScramble`, in placement order.
    @Published private(set) var placed: [Int] = []

    /// Increments on every rejected submission (drives the shake).
    @Published private(set) var rejectionCount = 0

    init(
        puzzle: Daily18Puzzle,
        state: Daily18State,
        isAccepted: @escaping (String) -> Bool
    ) {
        self.puzzle = puzzle
        self.state = state
        self.isAccepted = isAccepted
    }

    var wordCount: Int {
        state.marks.count
    }

    var currentScramble: [String] {
        guard state.currentIndex < puzzle.scrambles.count else { return [] }
        return puzzle.scrambles[state.currentIndex]
    }

    var currentTarget: String {
        guard state.currentIndex < puzzle.words.count else { return "" }
        return puzzle.words[state.currentIndex]
    }

    var currentGuess: String {
        placed.map { currentScramble[$0] }.joined()
    }

    func start(now: Date = Date()) {
        guard state.phase == .notStarted else { return }
        state.phase = .inProgress
        state.firstPlayedAt = now
        state.remainingSeconds = Daily18State.timePerWord
    }

    func placeLetter(circleIndex: Int) {
        guard state.phase == .inProgress,
              currentScramble.indices.contains(circleIndex),
              !placed.contains(circleIndex)
        else {
            return
        }

        placed.append(circleIndex)

        if placed.count == currentScramble.count {
            submit(now: Date())
        }
    }

    func removeLast() {
        guard state.phase == .inProgress, !placed.isEmpty else { return }
        placed.removeLast()
    }

    func tick(now: Date = Date()) {
        guard state.phase == .inProgress else { return }
        state.remainingSeconds -= 1
        if state.remainingSeconds <= 0 {
            state.marks[state.currentIndex] = .failed
            advance(now: now)
        }
    }

    func markTallied() {
        state.isTallied = true
    }

    private func submit(now: Date) {
        let guess = currentGuess
        if guess == currentTarget || isAccepted(guess) {
            state.marks[state.currentIndex] = .solved
            advance(now: now)
        } else {
            rejectionCount += 1
            placed = []
        }
    }

    private func advance(now: Date) {
        placed = []
        if state.currentIndex + 1 >= wordCount {
            state.phase = .finished
            state.finishedAt = now
        } else {
            state.currentIndex += 1
            state.remainingSeconds = Daily18State.timePerWord
        }
    }
}
