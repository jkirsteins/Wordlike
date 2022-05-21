import SwiftUI

#if os(iOS)
import UniformTypeIdentifiers
import LinkPresentation
#endif

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
    
    @State var globalTapCount = 0
    
#if os(iOS)
    @State var tapDelegate: GlobalTapDelegate? = nil
#endif
    
    // For sharing summary of the progress
    @State var isSharing: Bool = false
#if os(iOS)
    @State var shareItems: [UIActivityItemSource] = []
#else
    @State var shareItems: [Any] = []
#endif
    
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
    
    //    @State var testPresented = false
    //    var body: some View {
    //        NavigationList(shareCallback: {}, gearCallback: {}, outerDebug: .constant(false))
    //
    //    }
    //    var testbody1: some View {
    //        Button("Hello") {
    //            testPresented = true
    //        }.sheet(isPresented: $testPresented) {
    //            SheetRoot(title: "Test", isPresented: .constant(true)) {
    //                HelpView()
    //            }
    //        }
    //    }
    
    var body: some View {
        innerBody
#if os(macOS)
            .frame(maxWidth: MockDeviceConfig.inch65_iPhone12ProMax.landscape.width)
#endif
    }
    
#if os(macOS)
    func toggleSidebar() { NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
#endif
    
    var innerBody: some View {
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
                            
                            let isHardMode = ds.rows.checkHardMode(expected: WordModel(characters: ds.expected.word))
                            
                            return "\(flag) \(tries)\(isHardMode ? "*" : " ")\t\(rowSnippet)"
                        }.filter { $0 != nil }.map { $0! }
                        
                        guard lines.count > 0 else {
                            return
                        }
                        
                        let day = turnCounter.turnIndex(at: Date())
#if os(iOS)
                        self.shareItems = [
                            ShareableString(
                                (
                                    ["Wordlike Day \(day)", ""] + lines
                                ).joined(separator: "\n") + "\n"
                            )
                        ]
#else
                        self.shareItems = [
                            (
                                ["Wordlike Day \(day)", ""] + lines
                            ).joined(separator: "\n") + "\n"
                        ]
#endif
                        
                        self.isSharing.toggle()
                    },
                    gearCallback: {
                        self.activeSheet = .settings
                    },
                    outerDebug: $innerDebug
                )
                
                EmptyNavWelcomeView()
            }
        }
#if os(macOS)
        .toolbar{
            ToolbarItem(placement: .status){
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left") })
            }
            
        }
#endif
        // TODO: sharing on macOS
#if os(iOS)
        .sheetWithDetents(
            isPresented: $isSharing,
            detents: [.medium(),.large()],
            onDismiss: {
            },
            content: {
                ActivityViewController(activityItems: $shareItems, callback: {
                    isSharing = false
                    shareItems = []
                })
            })
#endif
        .onAppear {
#if os(iOS)
            self.tapDelegate = GlobalTapDelegate($globalTapCount)
            UIApplication.shared.addGestureRecognizer(
                tapDelegate!
            )
#endif
        }
        .environment(
            \.globalTapCount,
             $globalTapCount)
        .safeSheet(item: $activeSheet, onDismiss: {
            // nothing to do on dismiss
        }, { item in
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
    static let configurationsWithDupes = [
        .inch58_iPhone11Pro,
        .inch58_iPhone12Pro,
        .inch4_iPhoneSE,
        .inch4_iPhoneSE2
    ]
    + MockDeviceConfig.mandatoryScreenshotConfigs +
    [
        .inch129_iPadPro4
    ]
    
    static var configurations: [MockDeviceConfig] {
        Array(Set(configurationsWithDupes)).sorted {
            let ix1 = configurationsWithDupes.firstIndex(of: $0)!
            let ix2 = configurationsWithDupes.firstIndex(of: $1)!
            
            return ix1 < ix2
        }
    }
    
    static var previews: some View {
        ForEach(configurations) {
            MockDevice(config: $0) {
                AppView()
            }
        }
    }
}
