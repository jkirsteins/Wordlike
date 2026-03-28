import SwiftUI

@main
struct Wordlike: App {
    init() {
        DatadogSetup.initialize()
    }

    @SceneBuilder var body: some Scene {
        WindowGroup {
            AppView()
        }
        .commands {
            SidebarCommands()
        }
    }
}
