import SwiftUI

fileprivate enum ActiveSheet {
    case settings 
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}

struct AppView: View {
    let turnCounter = CalendarDailyTurnCounter.current(
        start: WordValidator.MAR_22_2022)
    
    /// This is propogated through the environment
    /// and can trigger debug borders or messages.
    @State var innerDebug = false
    
    /// Outer debug can be set by e.g. MockDevice etc.
    @Environment(\.debug) 
    var outerDebug: Bool
    
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
        switch(loc.identifier) {
        case Locale.en_US.identifier: return .en_US
        case Locale.en_GB.identifier: return .en_GB
        case Locale.fr_FR.identifier: return .fr_FR
        case Locale.lv_LV.identifier: return .lv_LV(simplified: false)
        case Locale.ee_EE.identifier: return .ee_EE
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
            
            if let ds = ds, 
                ds.isFinished == true, 
                turnCounter.isFresh(ds.date, at: Date()) 
            {
                return false 
            }
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            PaletteSetterView {
                NavigationList(
                    shareCallback: { 
                        let lines = self.listedLocales.map { 
                            (loc: Locale) -> String? in
                            guard let gl = gameLocale(loc) else { return nil }
                            
                            let ds : DailyState? = AppStorage(gl.turnStateKey, store: nil).wrappedValue
                            
                            guard 
                                let ds = ds, 
                                    ds.isFinished == true,
                                let lastRow = ds.rows.lastSubmitted,
                                let rowSnippet = lastRow.shareSnippet,
                                turnCounter.isFresh(ds.date, at: Date())
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
                    },
                    gearCallback: {
                        self.activeSheet = .settings
                    },
                    debug: $innerDebug
                )
                
                EmptyNavWelcomeView()
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
            .environment(\.debug, innerDebug || outerDebug)
    }
}

struct AppView_Previews: PreviewProvider {
    static let configurations: [MockDeviceConfig] = MockDeviceConfig.mandatoryScreenshotConfigs 
    
    static var previews: some View {
        ForEach(configurations) { 
            MockDevice(config: $0) {
                AppView()
            }
        }
    }
}
