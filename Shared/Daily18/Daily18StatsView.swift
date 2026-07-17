import SwiftUI

/// Score histogram and headline numbers, adapted from the Wordle
/// stats sheet styling (horizontal bars).
struct Daily18StatsView: View {
    let stats: Daily18Stats
    let todayScore: Int?

    @Environment(\.palette) var palette: Palette

    var headline: some View {
        HStack(alignment: .top, spacing: 24) {
            statCell(value: stats.played, caption: "Played")
            statCell(value: stats.trophyStreak, caption: "Trophy streak")
            statCell(value: stats.maxTrophyStreak, caption: "Max streak")
            statCell(value: stats.perfectDays, caption: "Perfect days")
        }
    }

    func statCell(value: Int, caption: LocalizedStringKey) -> some View {
        VStack {
            Text(verbatim: "\(value)")
                .font(.title2)
                .fontWeight(.bold)
            Text(caption)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }

    func bar(score: Int) -> some View {
        GeometryReader { proxy in
            HStack(spacing: 4) {
                Text(verbatim: "\(score)")
                    .font(.caption.monospacedDigit())
                    .frame(width: 22, alignment: .trailing)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.clear)
                    Rectangle()
                        .fill(
                            score == todayScore
                                ? palette.rightPlaceFill
                                : Color.secondary.opacity(0.5)
                        )
                        .frame(
                            width: max(
                                14,
                                (proxy.size.width - 26) * stats.widthRatio(score: score)
                            )
                        )
                        .overlay(alignment: .trailing) {
                            Text(verbatim: "\(stats.scoreDistribution[score])")
                                .font(.caption2.monospacedDigit())
                                .foregroundColor(.white)
                                .padding(.trailing, 3)
                        }
                }
            }
        }
        .frame(height: 16)
    }

    var body: some View {
        VStack(spacing: 16) {
            headline

            VStack(spacing: 3) {
                ForEach(0 ... Daily18State.wordCount, id: \.self) { score in
                    bar(score: score)
                }
            }
        }
    }
}
