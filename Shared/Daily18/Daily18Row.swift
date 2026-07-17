import SwiftUI

/// Caption under the 18 vardi menu row title: today's status.
struct Daily18ProgressCaption: View {
    @AppStateStorage(Daily18Storage.stateKey) var storedState: Daily18State = .init(day: -1)

    @Environment(\.palette) var palette: Palette

    var caption: (Text, Color) {
        let today = Daily18Storage.makeTurnCounter().turnIndex(at: Date())

        guard storedState.day == today, storedState.phase != .notStarted else {
            return (Text("Not started"), Color.primary)
        }

        if storedState.phase == .finished {
            return (
                Text(verbatim: "\(storedState.score)/18"),
                palette.completedUiLabel
            )
        }

        return (Text("In progress"), palette.inProgressUiLabel)
    }

    var body: some View {
        caption.0
            .font(.caption)
            .foregroundColor(caption.1)
    }
}

/// Compact trophy-streak widget for the menu row.
struct Daily18StatWidget: View {
    @AppStateStorage(Daily18Storage.statsKey) var stats: Daily18Stats = .init()

    var body: some View {
        HStack {
            if stats.played > 0 {
                HStack {
                    Divider()

                    VStack {
                        Text(verbatim: "\(stats.trophyStreak) / \(stats.maxTrophyStreak)")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                        Text("Trophy streak")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .minimumScaleFactor(0.02)
    }
}

/// Menu row for the 18 vardi mode; mirrors LanguageRow's anatomy.
struct Daily18Row: View {
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                TileFlag()
                    .frame(
                        minWidth: 50,
                        maxWidth: 50,
                        minHeight: 32
                    )
                VStack(alignment: .leading) {
                    Text(verbatim: "18 vārdi")
                        .fontWeight(.bold)
                        .fixedSize()

                    Daily18ProgressCaption().fixedSize()
                }
            }

            Spacer()

            Daily18StatWidget()
                .fixedSize()

            Image(systemName: "chevron.forward")
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}
