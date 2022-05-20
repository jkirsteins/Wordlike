import SwiftUI

@main
struct Wordlike: App {
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup {
            AppView()
        }
        .commands {
            SidebarCommands()
        }
    }
    
}
