import SwiftUI

/// Label used in the root listview
struct LanguageLinkLabel: View {
    @AppStorage
    var dailyState: DailyState?
    
    @Environment(\.turnCounter) 
    var turnCounter: TurnCounter
    
    @Environment(\.palette) var palette: Palette
    
    let locale: String
    
    var caption: (String, Color)? {
        guard let dailyState = dailyState, turnCounter.isFresh(dailyState.date, at: Date()) else {
            return ("Not started", Color.primary) 
        }
        
        let countSubmitted = dailyState.rows.filter({ $0.isSubmitted }).count
        
        if nil  != dailyState.rows.first(where: {
            row in 
            row.isSubmitted && row.wordArray == Array(dailyState.expected)
        }) {
            return ("Completed", palette.rightPlaceFill)
        }
        
        if countSubmitted >= GameState.MAX_ROWS {
            return ("Unsuccessful", Color.secondary)
        }
        
        return ("In progress", palette.wrongPlaceFill)
    }
    
    init(_ locale: String) {
        self.locale = locale 
        self._dailyState = AppStorage("turnState.\(locale)", store: nil)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(locale.localeDisplayName)
            
            if let caption = self.caption {
                Text(caption.0)
                    .font(.caption)
                    .foregroundColor(caption.1)
            }
        }
    }
}
