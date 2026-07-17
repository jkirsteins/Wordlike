import DatadogRUM
import SwiftUI

/// Loads word lists off the main thread, then owns the engine.
final class Daily18Loader: ObservableObject {
    @Published var engine: Daily18Engine?

    func load(day: Int, resuming stored: Daily18State?) {
        guard engine == nil else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            let lists = Daily18PuzzleProvider.loadAnswerLists()
            let puzzle = Daily18PuzzleProvider.puzzle(forDay: day, lists: lists)
            let dictionary = Daily18Dictionary.load()

            let state: Daily18State
            if let stored = stored, stored.day == day {
                state = stored
            } else {
                state = Daily18State(day: day)
            }

            DispatchQueue.main.async {
                self.engine = Daily18Engine(
                    puzzle: puzzle,
                    state: state,
                    isAccepted: { dictionary.contains($0) }
                )
            }
        }
    }
}

/// Entry point for the 18 vardi mode (menu row destination).
struct Daily18Host: View {
    static let gameLocaleAttribute = "lv18"

    @AppStateStorage(Daily18Storage.stateKey) var storedState: Daily18State = .init(day: -1)

    @AppStateStorage(Daily18Storage.statsKey) var stats: Daily18Stats = .init()

    @StateObject var loader = Daily18Loader()

    let turnCounter = Daily18Storage.makeTurnCounter()

    var body: some View {
        Group {
            if let engine = loader.engine {
                Daily18FlowView(
                    engine: engine,
                    turnCounter: turnCounter,
                    storedState: $storedState,
                    stats: $stats
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            let today = turnCounter.turnIndex(at: Date())
            loader.load(
                day: today,
                resuming: storedState.day == today ? storedState : nil
            )
        }
        .trackRUMView(name: "Game18")
    }
}

/// Switches between pre-game, gameplay, and results, and persists
/// every engine state change.
struct Daily18FlowView: View {
    @ObservedObject var engine: Daily18Engine
    let turnCounter: TurnCounter

    @Binding var storedState: Daily18State
    @Binding var stats: Daily18Stats

    var body: some View {
        Group {
            switch engine.state.phase {
            case .notStarted:
                Daily18PreGameView(
                    day: engine.state.day,
                    startAction: {
                        engine.start()
                        Analytics.shared.trackAction(
                            name: "game.started",
                            attributes: [
                                "game_locale": Daily18Host.gameLocaleAttribute,
                            ]
                        )
                    }
                )
            case .inProgress:
                Daily18GameView(engine: engine)
            case .finished:
                Daily18ResultsView(
                    state: engine.state,
                    stats: stats,
                    turnCounter: turnCounter
                )
            }
        }
        .onReceive(engine.$state) { newState in
            storedState = newState

            if newState.phase == .finished, !newState.isTallied {
                let score = newState.score
                stats = stats.update(
                    score: score,
                    finishedAt: newState.finishedAt ?? Date(),
                    with: turnCounter
                )
                engine.markTallied()
                Analytics.shared.trackAction(
                    name: score >= Daily18Stats.trophyThreshold ? "game.won" : "game.lost",
                    attributes: [
                        "game_locale": Daily18Host.gameLocaleAttribute,
                        "score": score,
                    ]
                )
            }
        }
    }
}

/// Mirrors the 18words.com landing screen.
struct Daily18PreGameView: View {
    let day: Int
    let startAction: () -> Void

    @Environment(\.palette) var palette: Palette

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Daily18ProgressGrid(marks: Array(repeating: .pending, count: Daily18State.wordCount))
                .frame(maxWidth: 280)

            Text(verbatim: "18 vārdi")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(verbatim: "#\(day + 1) | " + DateFormatter.localizedString(
                from: Date(), dateStyle: .medium, timeStyle: .none
            ))
            .font(.body)
            .foregroundColor(.secondary)

            Button(action: startAction) {
                Text("Play")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
}
