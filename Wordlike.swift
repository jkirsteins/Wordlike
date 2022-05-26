import SwiftUI

@main
struct Wordlike {
    static func main() {
        if #available(iOS 14.0, *) {
            _Wordlike.main()
        } else {
            UIApplicationMain(
                CommandLine.argc,
                CommandLine.unsafeArgv,
                nil,
                NSStringFromClass(AppDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct _Wordlike: App {
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

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let contentView = AppView()

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
