import SwiftUI

fileprivate enum ActiveSheet {
    case settings 
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}

// This is more a "game mode" than just a locale
// E.g. lv_LV contains game mode config.
enum GameLocale 
{
    case unknown
    case ee_EE
    case en_US
    case en_GB
    case fr_FR
    case lv_LV(simplified: Bool)
    
    /// For use with @AppStorage etc.
    var turnStateKey: String {
        "turnState.\(self.fileBaseName)"
    }
    
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
    
    // For sharing summary of the progress
    @State var isSharing: Bool = false
    @State var shareItems: [Any] = []
    
    let listedLocales: [Locale] = [
        .en_US,
        .en_GB,
        .fr_FR,
        .lv_LV
    ]
    
    func gameLocale(_ loc: Locale) -> GameLocale? {
        switch(loc) {
        case .en_US: return .en_US
        case .en_GB: return .en_GB
        case .fr_FR: return .fr_FR
        case .lv_LV: return .lv_LV(simplified: false)
        case .ee_EE: return .ee_EE
        default:
            return nil
        }
    }
    
    var isSharingDisabled: Bool {
        for loc in self.listedLocales { 
            guard let gl = gameLocale(loc) else { 
                continue 
            }
            
            let ds : DailyState? = AppStorage(gl.turnStateKey, store: nil).wrappedValue
            
            if let ds = ds, ds.isFinished == true {
                return false 
            }
        }
        
        return true
    }
    
    @SceneBuilder
    var body: some Scene {
        WindowGroup { 
            NavigationView {
                PaletteSetterView {
                    List {
                        ForEach(listedLocales, id: \.identifier) { loc in
                            if case .lv_LV = loc {
                                // Process lv_LV separately due to the
                                // simplified game mode
                                LinkToGame(
                                    locale: .lv_LV(simplified: isSimplifiedLatvianKeyboard),
                                    caption: "\(isHardMode ? "Hard mode. " : "")\(isSimplifiedLatvianKeyboard ? "Simplified" : "Extended") keyboard.")
                            } else if let gl = gameLocale(loc) {
                                LinkToGame(
                                    locale: gl, 
                                    caption: isHardMode ? "Hard mode." : nil)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle(
                    Bundle.main.displayName)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: { 
                            let lines = self.listedLocales.map { 
                                (loc: Locale) -> String? in
                                guard let gl = gameLocale(loc) else { return nil }
                                
                                let ds : DailyState? = AppStorage(gl.turnStateKey, store: nil).wrappedValue
                                
                                guard 
                                    let ds = ds, 
                                        ds.isFinished == true,
                                    let lastRow = ds.rows.lastSubmitted,
                                    let rowSnippet = lastRow.shareSnippet
                                else { return nil }
                                
                                let flag = gl.flag
                                
                                let tries: String 
                                if ds.isWon {
                                    tries = "\(ds.rows.submittedCount)/6"
                                } else {
                                    tries = "X/6"
                                }
                                
                                return "\(flag) \(tries)\(self.isHardMode ? "*" : "") \(rowSnippet)"
                            }.filter { $0 != nil }.map { $0! }
                            
                            guard lines.count > 0 else {
                                return
                            }
                            
                            let day = turnCounter.turnIndex(at: Date())
                            self.shareItems = [
                                (
                                    ["Wordlike Day \(day)", ""] + lines
                                ).joined(separator: "\n")
                            ]
                            
                            self.isSharing.toggle()
                        }, label: {
                            Label(
                                "Share your progress", 
                                systemImage: "square.and.arrow.up")
                        })
                            .disabled(self.isSharingDisabled)
                            .tint(.primary)
                            .contextMenu {
                                Text(
                                    "Summarize the day in a single message."
                                ).fixedSize()
                            }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: { 
                                activeSheet = .settings
                            }, 
                            label: {
                                Label(
                                    "Settings", 
                                    systemImage: "gear")
                            }) 
                            .tint(.primary)
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
            .sheetWithDetents(
                isPresented: $isSharing,
                detents: [.medium(),.large()]) { 
                } content: {
                    ActivityViewController(activityItems: $shareItems, callback: {
                        isSharing = false
                        shareItems = []
                    })
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
