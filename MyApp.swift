import SwiftUI

struct LinkToGame: View {
    let locale: String 
    
    var body: some View {
        NavigationLink(destination: {
            GameHostView(locale)
        }, label: {
            LanguageLinkLabel(locale)
        })
    }
}

struct LanguageLinkLabel: View {
    @AppStorage
    var dailyState: DailyState?
    
    @Environment(\.paceSetter) var paceSetter: PaceSetter
    @Environment(\.palette) var palette: Palette
    
    let locale: String
    
    var caption: (String, Color)? {
        guard let dailyState = dailyState, paceSetter.isFresh(dailyState.date, at: Date()) else {
            return ("Not started", .black) 
        }
        
        let countSubmitted = dailyState.rows.filter({ $0.isSubmitted }).count
        
        if nil  != dailyState.rows.first(where: {
            row in 
            row.isSubmitted && row.wordArray == Array(dailyState.expected)
        }) {
            return ("Completed", palette.rightPlaceFill)
        }
        
        if countSubmitted >= GameState.MAX_ROWS {
            return ("Unsuccessful", palette.wrongLetterFill)
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

extension String {
    var localeDisplayName: String {
        switch(self.uppercased()) {
        case "EN":
            return "English 🇺🇸"
        case "FR":
            return "Français 🇫🇷"
        case "LV":
            return "Latviski 🇱🇻"
        default:
            return self 
        }
    }
}

@main
struct MyApp: App {
    
    let paceSetter = CalendarDailyPaceSetter.current(start: WordValidator.MAR_22_2022)
    
    let debugViz = false
    
    @AppStorage("turnState.en")
    var dailyStateEn: DailyState?
    
    @AppStorage("turnState.fr")
    var dailyStateFr: DailyState?
    
    @AppStorage("turnState.lv")
    var dailyStateLv: DailyState?
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup { 
            PaletteSetterView {
                NavigationView {
                    List {
                        LinkToGame(locale: "en")
                        LinkToGame(locale: "fr")
                        LinkToGame(locale: "lv")
                    }
                    .navigationTitle(
                        Bundle.main.displayName)
                    
                    VStack {
                        Text("Welcome!")
                            .foregroundColor(Color.accentColor)
                            .font(.largeTitle )
                            .fontWeight(.bold)
                            
                            
                        Text("Please select a language in the left side menu.")
                    }
                }
                .environment(\.paceSetter, paceSetter)
                .environment(\.debug, debugViz)
            }
        }
    }
}
