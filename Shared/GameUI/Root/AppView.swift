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
//    let turnCounter = BucketTurnCounter(start: Date(), bucket: 10)
    
    /// This is propogated through the environment
    /// and can trigger debug borders or messages.
    @State var innerDebug = false
    
    /// Outer debug can be set by e.g. MockDevice etc.
    @Environment(\.debug)
    var outerDebug: Bool
    
    @State
    fileprivate var activeSheet: ActiveSheet? = nil
    
    @AppStateStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
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
    
    @Environment(\.scenePhase) var scenePhase
    
    var testbody: some View {
        FlippableTile(
            letter: TileModel(letter: "A", state: .wrongLetter),
            flipped: TileModel(letter: "B", state: .rightPlace),
            tag: 0,
            jumpIx: nil,
            midCallback: {},
            flipCallback: {},
            jumpCallback: { _ in },
            duration: 3,
            jumpDuration: 3)
    }
    
    var body: some View {
        innerBody
            .onChange(of: scenePhase) { _ in
                
                // Experimental
                // CloudStorageSync.shared.synchronize()
            }
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
                            
                            let ds : DailyState? = AppStateStorage(wrappedValue: nil, gl.turnStateKey, store: nil).wrappedValue
                            
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
                        let title = Bundle.main.displayName
#if os(iOS)
                        self.shareItems = [
                            ShareableString(
                                (
                                    ["\(title) \(day)", ""] + lines
                                ).joined(separator: "\n") + "\n"
                            )
                        ]
#else
                        self.shareItems = [
                            (
                                ["\(title) \(day)", ""] + lines
                            ).joined(separator: "\n") + "\n"
                        ]
#endif
                        
                        self.isSharing.toggle()
                    },
                    gearCallback: {
                        self.activeSheet = .settings
                    },
                    outerDebug: $innerDebug,
                    isSharing: $isSharing
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
        /* NOTE: wrapping in background() because otherwise multiple .sheet() modifiers will not work (and safeSharingSheet and safeSheet
         will both evaluate to .sheet() under the hood on iOS14 */
        .background(
            EmptyView()
                .safeSharingSheet(isSharing: $isSharing, activityItems: $shareItems, callback: {
                    isSharing = false
                    shareItems = []
                }))
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
        /* NOTE: wrapping in background() because otherwise multiple .sheet() modifiers will not work (and safeSharingSheet and safeSheet
         */
        .background(
            EmptyView().safeSheet(
                item: $activeSheet, onDismiss: {
                    // nothing to do on dismiss
                }, { item in
                    switch(item) {
                    case .settings:
                        SettingsView()
                    }
                }))
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
        if #available(iOS 15.0, *) {
            ForEach(configurations) {
                MockDevice(config: $0) {
                    AppView()
                }
            }
        }
    }
}
