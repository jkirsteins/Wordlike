import SwiftUI
import ConfettiView

struct StatsHeader: View {
    let stats: Stats 
    let showConfetti: Bool
    let showHeader: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            
            ZStack {
                if showHeader {
                    Text("Statistics")
                        .font(Font.system(.title).smallCaps())
                        .fontWeight(.bold)
                }
                
                if showConfetti {
                    ConfettiView()
                    ParticleView(time: 0, scale: 0.1)
                }
                
            }
            
            HStack(alignment: .top) {
                VStack {
                    Text("\(stats.played)").font(.largeTitle)
                    Text("Played")
                        .font(.caption)
                        .frame(maxWidth: 50)
                }
                VStack {
                    if stats.played == 0 {
                        Text("-").font(.largeTitle)
                    } else {
                        Text("\(Double(stats.won) / Double(stats.played) * 100, specifier: "%.0f")").font(.largeTitle)
                    }
                    Text("Win %")
                        .font(.caption)
                        .frame(maxWidth: 50)
                }
                VStack {
                    Text("\(stats.streak)").font(.largeTitle)
                    Text("Current Streak")
                        .font(.caption)
                        .frame(maxWidth: 50)
                }
                VStack {
                    Text("\(stats.maxStreak)").font(.largeTitle)
                    Text("Max Streak")
                        .font(.caption)
                        .frame(maxWidth: 50)
                }
            }.multilineTextAlignment(.center)
        }
    }
}

struct StatsHeader_Previews: PreviewProvider {
    static var previews: some View {
        StatsHeader(stats: Stats(
            played: 63, 
            won: 61,
            maxStreak: 27,
            streak: 4,
            guessDistribution: [
                1, 
                3,
                16,
                24,
                11,
                6
            ],
            lastWinAt: nil),
                    showConfetti: false,
                    showHeader: true)
        
        StatsHeader(stats: Stats(
            played: 63, 
            won: 61,
            maxStreak: 27,
            streak: 4,
            guessDistribution: [
                1, 
                3,
                16,
                24,
                11,
                6
            ],
            lastWinAt: nil),
                    showConfetti: false,
                    showHeader: true)
            .minimumScaleFactor(0.05)
            .frame(maxWidth: 200, maxHeight: 50)
            .border(.gray)
    }
}
