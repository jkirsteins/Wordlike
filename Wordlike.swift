import SwiftUI

@main
struct Wordlike: App {
    init() {
        DatadogSetup.initialize()
        DailyReminder.installForegroundPresentation()
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
