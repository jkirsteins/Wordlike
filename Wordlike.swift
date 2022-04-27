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
    @State var debug = false
    
    @State 
    fileprivate var activeSheet: ActiveSheet? = nil
    
    @AppStorage(SettingsView.HARD_MODE_LATVIAN_KEY)
    var isHardMode_Latvian: Bool = false
    
    @AppStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup { 
            NavigationView {
                PaletteSetterView {
                    List {
                        LinkToGame(
                            locale: "en", 
                            caption: isHardMode ? "Hard mode." : nil)
                        LinkToGame(
                            locale: "en-GB",
                            caption: isHardMode ? "Hard mode." : nil)
                        LinkToGame(
                            locale: "fr",
                            caption: isHardMode ? "Hard mode." : nil)
                        
                        if isHardMode_Latvian {
                            LinkToGame(
                                locale: "lv",
                                caption: "\(isHardMode ? "Hard mode. " : "")Extended keyboard.")
                        } else {
                            LinkToGame(
                                locale: "lv", 
                                validator: SimplifiedLatvianWordValidator(),
                                caption: "\(isHardMode ? "Hard mode. " : "")Simplified keyboard.")
                        }
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
                            .contextMenu {
                                Button {
                                    self.debug.toggle()
                                } label: {
                                    Label("Toggle debug mode", systemImage: "hammer")
                                }
                            }
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
