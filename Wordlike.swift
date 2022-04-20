import SwiftUI

fileprivate enum ActiveSheet {
    case settings 
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}

@main
struct Wordlike: App {
    
    let turnCounter = CalendarDailyTurnCounter.current(
        start: WordValidator.MAR_22_2022)
    
    /// This is propogated through the environment
    /// and can trigger debug borders or messages.
    let debug = false
    
    @AppStorage("turnState.en")
    var dailyStateEn: DailyState?
    
    @AppStorage("turnState.fr")
    var dailyStateFr: DailyState?
    
    @AppStorage("turnState.lv")
    var dailyStateLv: DailyState?
    
    @State 
    fileprivate var activeSheet: ActiveSheet? = nil
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup { 
            NavigationView {
                PaletteSetterView {
                    List {
                        LinkToGame(locale: "en")
                        LinkToGame(locale: "fr")
                        LinkToGame(locale: "lv")
                    }
                }
                .listStyle(.insetGrouped)
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle(
                    Bundle.main.displayName)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: { 
                                activeSheet = .settings
                            }, 
                            label: {
                                Label(
                                    "Help", 
                                    systemImage: "gear")
                                    .foregroundColor(
                                        Color(
                                            UIColor.label))
                            })  
                    }
                }
                
                VStack {
                    Text("Welcome!")
                        .foregroundColor(Color.accentColor)
                        .font(.largeTitle )
                        .fontWeight(.bold)
                    
                    
                    Text("Please select a language in the left side menu.")
                }
            }.sheet(item: $activeSheet, onDismiss: {
                // nothing to do on dismiss
            }, content: { item in
                switch(item) {
                case .settings: 
                    SettingsView()
                }
            })
                .environment(\.turnCounter, turnCounter)
                .environment(\.debug, debug)
        }
    }
}
