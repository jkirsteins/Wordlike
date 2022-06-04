import SwiftUI
import Datadog

@main
struct Wordlike: App {
    
    init() {
        guard
            let appID = Bundle.main.object(forInfoDictionaryKey: "APP_ID") as? String,
            let clientToken = Bundle.main.object(forInfoDictionaryKey: "CLIENT_TOKEN") as? String,
            !appID.isEmpty,
            !clientToken.isEmpty
        else {
            return
        }

        #if DEBUG
        let environment = "dev"
        #else
        let environment = "prod"
        #endif

        Datadog.initialize(
            appContext: .init(),
            trackingConsent: .granted,
            configuration: Datadog.Configuration
                .builderUsing(
                    rumApplicationID: appID,
                    clientToken: clientToken,
                    environment: environment
                )
                .set(endpoint: .eu1)
                .trackUIKitRUMViews()
                .trackUIKitRUMActions()
                .trackRUMLongTasks()
                .build()
        )
            
        Global.rum = RUMMonitor.initialize()
    }
    
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
