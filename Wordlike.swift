import SwiftUI

fileprivate enum ActiveSheet {
    case settings 
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}

enum GameLocale
{
    case unknown
    case ee_EE
    case en_US
    case en_GB
    case fr_FR
    case lv_LV(simplified: Bool)
    
    var nativeLocale: Locale {
        switch(self) {
        case .unknown:
            return Locale.current
        case .en_GB:
            return .en_GB
        case .en_US:
            return .en_US
        case .fr_FR:
            return .fr_FR
        case .lv_LV(_):
            return .lv_LV
        case .ee_EE:
            return .ee_EE
        }
    }
    
    var flag: String {
        switch(self) {
        case .en_US:
            return "🇺🇸"
        case .en_GB:
            return "🇬🇧"
        case .fr_FR:
            return "🇫🇷"
        case .lv_LV(_):
            return "🇱🇻"
        case .ee_EE:
            return "🇪🇪"
        case .unknown:
            return ""
        }
    }
    
    var localeDisplayName: String {
        switch(self) {
        case .en_US:
            return "English \(self.flag)"
        case .en_GB:
            return "English \(self.flag)"
        case .fr_FR:
            return "Français \(self.flag)"
        case .lv_LV(_):
            return "Latviski \(self.flag)"
        case .ee_EE:
            return "Eesti \(self.flag)"
        case .unknown:
            fatalError("Do not use unknown locale") 
        }
    }
    
    var fileBaseName: String {
        switch(self) {
        case .en_GB:
            return "en-GB"
        case .en_US:
            return "en"
        case .fr_FR:
            return "fr"
        case .ee_EE:
            return "ee_EE"
        case .lv_LV(_):
            return "lv"
        case .unknown:
            fatalError("Invalid locale")
        }
    }
}

extension UIApplication {
    func addGestureRecognizer(_ d: GlobalTapDelegate) {
        let sceneWindows =
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
        
        guard let window = sceneWindows?.first else { return }
        let gesture = UITapGestureRecognizer(target: window, action: nil)
        gesture.requiresExclusiveTouchType = false
        gesture.cancelsTouchesInView = false
        gesture.delegate = d
        window.addGestureRecognizer(gesture)
    }
}

class GlobalTapDelegate: NSObject, UIGestureRecognizerDelegate {
    let requestCount: Binding<Int>
    
    init(_ requestCount: Binding<Int>) {
        self.requestCount = requestCount
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        requestCount.wrappedValue += 1
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

fileprivate struct GlobalTapCountKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var globalTapCount: Binding<Int> {
        get { self[GlobalTapCountKey.self] }
        set { self[GlobalTapCountKey.self] = newValue }
    }
}

fileprivate struct GameLocaleKey: EnvironmentKey {
    static let defaultValue: GameLocale = .unknown
}

extension EnvironmentValues {
    var gameLocale: GameLocale {
        get { self[GameLocaleKey.self] }
        set { self[GameLocaleKey.self] = newValue }
    }
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
    
    @AppStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
    var isSimplifiedLatvianKeyboard: Bool = false
    
    @AppStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    @State var globalTapCount = 0
    
    @State var tapDelegate: GlobalTapDelegate? = nil
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup { 
            NavigationView {
                PaletteSetterView {
                    List {
                        LinkToGame(
                            locale: .en_US, 
                            caption: isHardMode ? "Hard mode." : nil)
                        LinkToGame(
                            locale: .en_GB,
                            caption: isHardMode ? "Hard mode." : nil)
                        LinkToGame(
                            locale: .fr_FR,
                            caption: isHardMode ? "Hard mode." : nil)
                        
                        if !isSimplifiedLatvianKeyboard {
                            LinkToGame(
                                locale: .lv_LV(simplified: false),
                                caption: "\(isHardMode ? "Hard mode. " : "")Extended keyboard.")
                        } else {
                            LinkToGame(
                                locale: .lv_LV(simplified: true), 
                                validator: WordValidator(locale: .lv_LV(simplified: true)),
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
            }
            .onAppear {
                self.tapDelegate = GlobalTapDelegate($globalTapCount)
                UIApplication.shared.addGestureRecognizer(
                    tapDelegate!
                )
            }
            .environment(
                \.globalTapCount, 
                 $globalTapCount)
            .sheet(item: $activeSheet, onDismiss: {
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
