import SwiftUI

fileprivate enum ActiveSheet {
    case settings
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}

struct FlagAssets {
    
    static func flagFromName(_ name: String) -> NativeImage? {
#if os(iOS)
        // TODO: figure out why UIImage(named:) is pixelated
        return flagFromName_old(name)
#else
        return NativeImage(named: name)
#endif
    }
    
#if os(iOS)
    static func flagFromName_old(_ name: String) -> NativeImage? {
        
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "pdf")
        else {
            return nil
        }
        
        guard let pro = CGDataProvider(url: url as CFURL) else {
            return nil
        }
        
        guard let document = CGPDFDocument(pro) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: pageRect.width*10, height: pageRect.height*10))
        
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height*10)
            ctx.cgContext.scaleBy(x: 10.0, y: -10.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img.resized(to: CGSize(width: 500, height: 500))
    }
#endif
    
    static func reqFlagFromName(_ name: String) -> NativeImage {
        guard let result = flagFromName(name) else {
            fatalError("Flag \(name) not found")
        }
        
        return result
    }
    
    static let gbFlag = reqFlagFromName("GB")
    static let usFlag = reqFlagFromName("US")
    static let lvFlag = reqFlagFromName("LV")
    static let frFlag = reqFlagFromName("FR")
}

struct Flag : View {
    @Environment(\.gameLocale)
    var gameLocale: GameLocale
    
    var locale: Locale {
        gameLocale.nativeLocale
    }
    
    static let aspectRatio = 21.0/15.0
    
    static let defaultImage = NativeImage()
    
    var image: NativeImage {
        switch(locale.identifier) {
        case Locale.en_GB.identifier:
            return FlagAssets.gbFlag
        case Locale.en_US.identifier:
            return FlagAssets.usFlag
        case Locale.fr_FR.identifier:
            return FlagAssets.frFlag
        case Locale.lv_LV.identifier:
            return FlagAssets.lvFlag
        default:
            return Self.defaultImage
        }
    }
    
    var body: some View {
#if os(iOS)
        Image(uiImage: image)
            .resizable()
            .aspectRatio(21.0/15.0, contentMode: .fit)
#elseif os(macOS)
        Image(nsImage: image)
            .resizable()
            .aspectRatio(21.0/15.0, contentMode: .fit)
#endif
    }
}

struct TileFlag : View {
    var body: some View {
        Tile(
            type: .maskedEmpty,
            lineWidth: 1.0,
            aspectRatio: Flag.aspectRatio)
        {
            Flag()
        }
    }
}

struct ProgressLabel: View {
    @AppStateStorage
    var dailyState: DailyState?
    
    @Environment(\.turnCounter)
    var turnCounter: TurnCounter
    
    @Environment(\.palette)
    var palette: Palette
    
    let locale: Locale
    
    init(_ locale: Locale) {
        self.locale = locale
        self._dailyState = AppStateStorage(wrappedValue: nil, "turnState.\(locale.fileBaseName)", store: nil)
    }
    
    var caption: (LocalizedStringKey, Color)? {
        guard
            let dailyState = dailyState,
            turnCounter.isFresh(dailyState.date, at: Date()),
            dailyState.state != .notStarted
        else {
            return ("Not started", Color.primary)
        }
        
        if case .finished(_, isWon: true) = dailyState.state
        {
            return ("Completed", palette.completedUiLabel)
        }
        
        if case .finished(_, isWon: false) = dailyState.state {
            return ("Unsuccessful", Color.secondary)
        }
        
        if case .inProgress = dailyState.state {
            return ("In progress", palette.inProgressUiLabel)
        }
        
        return nil
    }
    
    var body: some View {
        
        if let caption = self.caption {
            Text(caption.0)
                .font(.caption)
                .foregroundColor(caption.1)
        } else {
            EmptyView()
        }
        
    }
}

struct LanguageRow: View {
    @Environment(\.gameLocale)
    var gameLocale: GameLocale
    
    @AppStateStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
    var isSimplifiedLatvianKeyboard: Bool = false
    
    @AppStateStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    var locale: Locale {
        gameLocale.nativeLocale
    }
    
    var title: LocalizedStringKey {
        locale.displayName
    }
    
    @Environment(\.palette)
    var palette: Palette
    
#if os(iOS)
    @Environment(\.verticalSizeClass)
    var vsc: UserInterfaceSizeClass?
#endif
    
    var shouldShowCaption: Bool {
#if os(iOS)
        if let vsc = vsc, vsc != .compact {
            return true
        }
        return false
#else
        return true
#endif
    }
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                TileFlag()
                    .frame(
                        minWidth: 50,
                        maxWidth: 50,
                        minHeight: 32)
                    .debugBorder(.orange)
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.bold)
                        .fixedSize()
                    
                    ProgressLabel(locale).fixedSize()
                }
            }
            
            Spacer()
            
            InternalStatWidget(
                locale)
            .fixedSize()
            
            Image(systemName: "chevron.forward")
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

struct InternalStatWidget: View {
    
    @AppStateStorage
    var stats: Stats
    
    @AppStateStorage
    var dailyState: DailyState?
    
    @Environment(\.palette)
    var palette: Palette
    
    @Environment(\.turnCounter)
    var turnCounter: TurnCounter
    
    let locale: Locale
    
    init(_ locale: Locale) {
        self.locale = locale
        self._stats = AppStateStorage(
            wrappedValue: Stats(),
            "stats.\(locale.fileBaseName)")
        self._dailyState = AppStateStorage(wrappedValue: nil, "turnState.\(locale.fileBaseName)", store: nil)
    }
    
    var body: some View {
        HStack {
            if stats.played > 0 {
                HStack {
                    Divider()
                    
                    VStack {
                        Text("\(stats.streak) / \(stats.maxStreak)")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                        Text("Streak")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    VStack {
                        Text("\(Double(stats.won) / Double(stats.played) * 100, specifier: "%.0f")")
                            .font(.caption)
                        Text("Win %")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }.frame(minWidth: 30)
                }
            }
        }
        .minimumScaleFactor(0.02)
    }
}

struct NavigationList: View {
    
    let shareCallback: ()->()
    let gearCallback: ()->()
    
    @Environment(\.debug)
    var envDebug: Bool
    
    @Binding var outerDebug: Bool
    @Binding var isSharing: Bool
    
    @Environment(\.palette)
    var palette: Palette
    
    @Environment(\.globalTapCount)
    var globalTapCount: Binding<Int>
    
    @AppStateStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
    var isSimplifiedLatvianKeyboard: Bool = false
    
    func seedFor(_ loc: Locale) -> Int? {
        switch(loc.identifier) {
            // Ensure GB seed is not the same as US
        case Locale.en_GB.identifier:
            return 1337
        case Locale.en_US.identifier:
            return 42
        default:
            return nil
        }
    }
    
    func gameLocale(_ loc: Locale) -> GameLocale? {
        switch(loc.identifier) {
        case Locale.en_US.identifier: return .en_US
        case Locale.en_GB.identifier: return .en_GB
        case Locale.fr_FR.identifier: return .fr_FR
        case Locale.lv_LV.identifier: return .lv_LV(simplified: isSimplifiedLatvianKeyboard)
        case Locale.ee_EE.identifier: return .ee_EE
        default:
            return nil
        }
    }
    
    @ViewBuilder
    var body: some View {
        innerBody
#if os(iOS)
        /* We don't need the title bar taking a lot
         of space (e.g. on iPhone SE it's borderline
         enough). But we do need the titlebar for the buttons.*/
            .navigationBarTitleDisplayMode(.inline)
#endif
            .padding(16)
        /* We need to cap max width for iPad portrait
         mode*/
            .frame(maxWidth: MockDeviceConfig.inch65_iPhone12ProMax.portrait.width)
    }
    
#if os(iOS)
    @Environment(\.verticalSizeClass)
    var vsc: UserInterfaceSizeClass?
#endif
    
    var isCompactHeight: Bool {
#if os(iOS)
        if let vsc = vsc, vsc == .compact {
            return true
        }
#endif
        
        return false
    }
    
    var navigationBarTrailing: ToolbarItemPlacement {
#if os(iOS)
        return .navigationBarTrailing
#else
        return .automatic
#endif
    }
    
    /// When changing the `innerBody` be sure
    /// to verify the aspect ratio visual tests for
    /// different sizes.
    @ViewBuilder
    var innerBody: some View {
        VStack(alignment: .leading, spacing: 48) {
            
            if !isCompactHeight {
                VStack(alignment: .center) {
                    Logo()
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 130)
                        .debugBorder(.yellow)
                }.debugBorder(.white)
            }
            
            VStack(spacing: 8) {
                ForEach(Locale.supportedLocales, id: \.self) {
                    loc in
                    
                    if let gameLoc = gameLocale(loc) {
                        NavigationLink(destination: {
                            GeometryReader { gr in
                                GameHost(
                                    gameLoc,
                                    seed: seedFor(loc))
                                /* We set the environment explicitly, because
                                 it will not be handled by the palette wrapper
                                 (it is instantiated, not nested) */
                                .environment(\.rootGeometry, gr)
                                .environment(\.globalTapCount, globalTapCount)
                                .environment(\.debug, outerDebug || envDebug)
                                .environment(\.palette, palette)
                            }
                            .padding()
                        }, label: {
                            LanguageRow()
                            /* Don't accidentally pass in the actual locale to not mess up the translation for current localization */
                                .environment(\.gameLocale, gameLocale(loc)!)
                        })
                        .buttonStyle(LanguageRowButtonStyle())
                    }
                }
            }
            .debugBorder(.red)
            
            Footer(shareCallback: shareCallback, isSharing: $isSharing)
                .debugBorder(.green)
            
        }
        .debugBorder(.red)
        .toolbar {
            ToolbarItem(placement: navigationBarTrailing) {
                Button(
                    action: {
                        gearCallback()
                    },
                    label: {
                        Label(
                            "Settings",
                            systemImage: "gear")
                    })
                .safeTint(.primary)
                .contextMenu {
                    Button {
                        self.outerDebug.toggle()
                    } label: {
                        Label("Toggle debug mode", systemImage: "hammer")
                    }
                }
            }
        }
    }
}

struct Footer: View {
    @Environment(\.turnCounter)
    var turnCounter: TurnCounter
    
    @AppStateStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
#if os(iOS)
    @Environment(\.verticalSizeClass)
    var vsc: UserInterfaceSizeClass?
#endif
    
    @AppStateStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
    var isSimplifiedLatvianKeyboard: Bool = false
    
    let shareCallback: ()->()
    
    /// Is the share sheet currently open or not (for disabling the button)
    @Binding var isSharing: Bool
    
    func gameLocale(_ loc: Locale) -> GameLocale? {
        switch(loc.identifier) {
        case Locale.en_US.identifier: return .en_US
        case Locale.en_GB.identifier: return .en_GB
        case Locale.fr_FR.identifier: return .fr_FR
        case Locale.lv_LV.identifier: return .lv_LV(simplified: isSimplifiedLatvianKeyboard)
        case Locale.ee_EE.identifier: return .ee_EE
        default:
            return nil
        }
    }
    
    var isSharingDisabled: Bool {
        for loc in Locale.supportedLocales {
            guard let gl = gameLocale(loc) else {
                continue
            }
            
            let ds : DailyState? = AppStateStorage(wrappedValue: nil, gl.turnStateKey, store: nil).wrappedValue
            
            if let ds = ds,
               ds.isFinished == true,
               turnCounter.isFresh(ds.date, at: Date())
            {
                return false
            }
        }
        
        return true
    }
    
    var isCompactVertically: Bool {
#if os(iOS)
        if let vsc = vsc, vsc == .compact {
            return true
        }
#endif
        
        return false
    }
    
    var body: some View {
        HStack() {
            Spacer()
            VStack(spacing: 4) {
                Button(action: {
                    shareCallback()
                }, label: {
                    VStack {
                        Label(
                            "Share a summary",
                            systemImage: "square.and.arrow.up")
                        
                        if !isCompactVertically {
                            Text("Share a summary for every game you have completed today.")
                                .multilineTextAlignment(.center)
#if os(iOS)
                                .fixedSize(horizontal: false, vertical: true )
#endif
                                .font(.caption)
                        }
                    }
                    .safeTint(.primary)
                })
                .disabled(self.isSharingDisabled || self.isSharing)
            }
            Spacer()
        }
        .debugBorder(.red)
    }
}

struct LanguageRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct AbstractTiles<TileType: View>: View {
    let word: [String]
    let minWidth: CGFloat
    let maxWidth: CGFloat
    let items: [GridItem]
    let producer: (String)->TileType
    
    let spacing = CGFloat(2)
    
    init(
        _ word: String,
        cols: Int,
        minWidth: CGFloat,
        maxWidth: CGFloat,
        producer: @escaping (String)->TileType
    ) {
        self.producer = producer
        self.items = .init(
            repeating: GridItem(
                .flexible(minimum: minWidth, maximum: maxWidth),
                spacing: self.spacing,
                alignment: .center),
            count: cols)
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.word = Array(word).map { String($0) }
    }
    
    var randomType: TileBackgroundType {
        TileBackgroundType.random
    }
    
    var body: some View {
        LazyVGrid(columns: self.items, spacing: self.spacing) {
            ForEach(Array(word.enumerated()), id: \.offset) {
                p in
                producer(p.element)
            }
        }
    }
}

struct NavigationList_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AppView_Previews.previews
        
    }
}
