import SwiftUI

@main
struct MyApp: App {
    
    let paceSetter = BucketPaceSetter(
        start: WordValidator.MAR_22_2022, 
        bucket: 180)
    
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
                }
                .navigationTitle("Welcome!")
                
                EmptyView()
            }
            .environment(\.paceSetter, paceSetter)
        }
    }
}
