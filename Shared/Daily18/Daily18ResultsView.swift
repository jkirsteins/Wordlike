import SwiftUI

struct Daily18ResultsView: View {
    let state: Daily18State
    let stats: Daily18Stats
    let turnCounter: TurnCounter

    @State var isSharing = false
    @State var shareItems: [UIActivityItemSource] = []

    func countdownText(at now: Date) -> String {
        let remaining = max(0, Int(turnCounter.remainingTtl(at: now)))
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func share(_ text: String) {
        shareItems = [ShareableString(text)]
        isSharing = true
        Analytics.shared.trackAction(
            name: "game.shared",
            attributes: ["game_locale": Daily18Host.gameLocaleAttribute]
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Daily18ProgressGrid(marks: state.marks)
                    .frame(maxWidth: 280)

                Text(
                    String(
                        format: NSLocalizedString(
                            "You found %lld of 18 words!", comment: ""
                        ),
                        state.score
                    )
                )
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

                Text(verbatim: Daily18TrophyTier.line(forScore: state.score))
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Button(action: {
                        share(Daily18Share.scoreText(day: state.day, marks: state.marks))
                    }) {
                        Label("Share score", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        share(Daily18Share.challengeText(day: state.day, marks: state.marks))
                    }) {
                        Label("Challenge friend", systemImage: "person.2")
                    }
                    .buttonStyle(.bordered)
                }
                .disabled(isSharing)

                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(
                        String(
                            format: NSLocalizedString("Next puzzle in %@", comment: ""),
                            countdownText(at: context.date)
                        )
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                }

                Divider()

                Daily18StatsView(stats: stats, todayScore: state.score)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(
            EmptyView()
                .safeSharingSheet(
                    isSharing: $isSharing,
                    activityItems: $shareItems,
                    callback: {
                        isSharing = false
                        shareItems = []
                    }
                )
        )
    }
}
