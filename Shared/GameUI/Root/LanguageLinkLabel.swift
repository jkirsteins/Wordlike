import SwiftUI

/// Label used in the root listview
struct LanguageLinkLabel: View {
    @AppStateStorage
    var dailyState: DailyState?
    
    @Environment(\.turnCounter) 
    var turnCounter: TurnCounter
    
    @Environment(\.palette) var palette: Palette
    
    @AppStateStorage
    var stats: Stats
    
    let locale: GameLocale
    let extraCaption: String?
    
    var caption: (String, Color)? {
        guard 
            let dailyState = dailyState,
            turnCounter.isFresh(dailyState.date, at: Date()),
            dailyState.state != .notStarted
        else {
            return ("Not started", Color.primary) 
        }
        
        if case .finished(_, isWon: true) = dailyState.state
        {
            return ("Completed", palette.completedUiLabel)
        }
        
        if case .finished(_, isWon: false) = dailyState.state {
            return ("Unsuccessful", Color.secondary)
        }
        
        if case .inProgress = dailyState.state {
            return ("In progress", palette.inProgressUiLabel)
        }
        
        return nil
    }
    
    init(_ locale: GameLocale, extraCaption: String?) {
        self.locale = locale
        self.extraCaption = extraCaption
        
        self._dailyState = AppStateStorage("turnState.\(locale.fileBaseName)", store: nil)
        self._stats = AppStateStorage(
            wrappedValue: Stats(), 
            "stats.\(locale.fileBaseName)")
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(locale.localeDisplayName)
                
                if let caption = self.extraCaption {
                    Text(caption)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                if let caption = self.caption {
                    Text(caption.0)
                        .font(.caption)
                        .foregroundColor(caption.1)
                }
            }
            
            if stats.played > 0 {
                HStack {
                    Spacer()
                    Divider()
                    VStack {
                        Text("\(stats.streak) / \(stats.maxStreak)")
                            .font(.body)
                            .multilineTextAlignment(.center)
                        Text("Streak")
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }
                    VStack {
                        Text("\(Double(stats.won) / Double(stats.played) * 100, specifier: "%.0f")")
                            .font(.body)
                        Text("Win %")
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }.frame(minWidth: 30)
                }
                .minimumScaleFactor(0.02)
                .frame(maxHeight: 30)
            }
        }
    }
}
