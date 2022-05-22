import SwiftUI

// TODO: https://stackoverflow.com/questions/62935053/use-main-in-xcode-12

@available(iOS 14.0, *)
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
