import SwiftUI

@main
struct MyApp: App {
    
//    let paceSetter = BucketPaceSetter(
//        start: WordValidator.MAR_22_2022, 
//        bucket: 180)
    
    let paceSetter = CalendarDailyPaceSetter.current(start: WordValidator.MAR_22_2022)
    
    let debugViz = false
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup { 
            NavigationView {
                List {
                    NavigationLink("English 🇺🇸") {
                        GameHostView("en")
                    }
                    NavigationLink("Français 🇫🇷") {
                        GameHostView("fr")
                    }
                    NavigationLink("Latviski 🇱🇻") {
                        GameHostView("lv")
                    }
                }
                .navigationTitle("Welcome!")
                
                EmptyView()
            }
            .environment(\.paceSetter, paceSetter)
            .environment(\.debug, debugViz)
        }
    }
}
