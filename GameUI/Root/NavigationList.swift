import SwiftUI

fileprivate enum ActiveSheet {
    case settings 
}

extension ActiveSheet: Identifiable {
    var id: Self { self }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

struct FlagAssets {
    static func flagFromName(_ name: String) -> UIImage? {
        
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
    
    static func reqFlagFromName(_ name: String) -> UIImage {
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
    @Environment(\.locale)
    var locale: Locale
    
    static let aspectRatio = 21.0/15.0
    
    static let defaultImage = UIImage()
    
    var image: UIImage {
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
        Image(uiImage: image)
            .resizable()
            .aspectRatio(21.0/15.0, contentMode: .fit)
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

struct CircleFlag : View {
    let strokeColor: Color
    
    init(stroke: Color) {
        self.strokeColor = stroke
    }
    
    var body: some View {
        Flag()
            .clipShape(Circle())
            .overlay(
                Circle().stroke(
                    strokeColor)
                    .background(.clear))
    }
}

struct ProgressLabel: View {
    @AppStorage 
    var dailyState: DailyState?
    
    @Environment(\.turnCounter) 
    var turnCounter: TurnCounter
    
    @Environment(\.palette)
    var palette: Palette
    
    let locale: Locale
    
    init(_ locale: Locale) {
        self.locale = locale
        self._dailyState = AppStorage("turnState.\(locale.fileBaseName)", store: nil)
    }
    
    var caption: (String, Color)? {
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
    @Environment(\.locale)
    var locale: Locale 
    
    @AppStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
    var isSimplifiedLatvianKeyboard: Bool = false
    
    @AppStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    var extraCaption: [String]? {
        if locale == .lv_LV {
            let row1 = isHardMode ? "Hard mode. " : ""
            let row2 = "\(isSimplifiedLatvianKeyboard ? "Simplified" : "Extended") keyboard."
            return "\(row1)\n\(row2)".split(separator: "\n").map { String($0) }
        }
        else {
            return isHardMode ? ["Hard mode."] : nil
        }
    }
    
    var title: String {
        locale.displayName
    }
    
    @Environment(\.palette)
    var palette: Palette 
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .top) {
                TileFlag()
                    .frame(
                        minWidth: 50,
                        maxWidth: 50)
                VStack(alignment: .leading) {
                    Text(title)
                        .fontWeight(.bold)
                        .fixedSize()
                    if let extraCaption = extraCaption {
                        ForEach(extraCaption, id: \.self) {
                            Text($0)
                                .fixedSize()
                                .lineLimit(1)
                                .font(.caption)
                        }
                    }
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
    
    @AppStorage
    var stats: Stats
    
    @AppStorage 
    var dailyState: DailyState?
    
    @Environment(\.palette)
    var palette: Palette
    
    @Environment(\.turnCounter) 
    var turnCounter: TurnCounter
    
    let locale: Locale
    
    init(_ locale: Locale) {
        self.locale = locale 
        self._stats = AppStorage(
            wrappedValue: Stats(), 
            "stats.\(locale.fileBaseName)")
        self._dailyState = AppStorage("turnState.\(locale.fileBaseName)", store: nil)
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
    @Binding var debug: Bool
    
    @Environment(\.palette) 
    var palette: Palette
    
    @Environment(\.globalTapCount)
    var globalTapCount: Binding<Int>
    
    @AppStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
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
        /* We don't need the title bar taking a lot
         of space (e.g. on iPhone SE it's borderline
         enough). But we do need the titlebar for the buttons.*/
            .navigationBarTitleDisplayMode(.inline)
            .padding(16)
    }
    
    /// When changing the `innerBody` be sure
    /// to verify the aspect ratio visual tests for
    /// different sizes.
    @ViewBuilder
    var innerBody: some View {
        VStack(alignment: .leading) {
            
            VStack {
                Spacer().frame(minHeight: 32)
                Logo()
                    .frame(minHeight: 100)
                    .debugBorder(.yellow)
                Spacer().frame(minHeight: 32)
            }.debugBorder(.white)
            
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
                                .environment(\.debug, debug)
                                .environment(\.palette, palette)
                        }
                        .padding()
                    }, label: {
                        LanguageRow()
                            .environment(\.locale, loc)
                    })
                        .buttonStyle(LanguageRowButtonStyle())
                }
            }
            .debugBorder(.red)
            
            VStack {
                Spacer()
                Footer(
                    shareCallback: shareCallback,
                    gearCallback: gearCallback,
                    debug: $debug)
                    .padding()
                    .debugBorder(.green)
                Spacer().frame(maxHeight: 16)
            }
            .debugBorder(.red)
        }
        .debugBorder(.green)
    }
}

struct Footer: View {
    @Environment(\.turnCounter) 
    var turnCounter: TurnCounter
    
    @AppStorage(SettingsView.HARD_MODE_KEY)
    var isHardMode: Bool = false
    
    @AppStorage(SettingsView.SIMPLIFIED_LATVIAN_KEYBOARD_KEY)
    var isSimplifiedLatvianKeyboard: Bool = false
    
    let shareCallback: ()->()
    let gearCallback: ()->()
    @Binding var debug: Bool
    
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
        VStack {
            HStack() {
                Spacer()
                VStack(spacing: 4) {
                    Button(action: { 
                        shareCallback()
                    }, label: {
                        Label(
                            
                            "Share a summary", 
                            systemImage: "square.and.arrow.up")
                    })
                        .disabled(self.isSharingDisabled)
                        .tint(.primary)
                    
                    Text("Share a summary for every game you have completed today.")
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true )
                        .font(.caption)
                }
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: { 
                        gearCallback()
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
    }
}

struct LanguageRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct Tiles: View {
    let word: [String] 
    let minWidth: CGFloat
    let maxWidth: CGFloat
    let items: [GridItem]
    
    static let spacing = CGFloat(2)
    
    init(
        _ word: String, 
        cols: Int,
        minWidth: CGFloat,
        maxWidth: CGFloat
    ) {
        self.items = .init(
            repeating: GridItem(
                .flexible(minimum: minWidth, maximum: maxWidth),
                spacing: Self.spacing,
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
        LazyVGrid(columns: self.items, spacing: Self.spacing) {
            ForEach(Array(word.enumerated()), id: \.offset) {
                p in 
                Tile(p.element, randomType)
            }
        }
    }
}

/// For previewing in different sizes
/// (or just aspect ratios, if not enough space)
struct InternalDeviceSizeTestView: View {
    let combo: (CGFloat, CGFloat, String, String, CGFloat)
    
    @State var debug: Bool = true
    
    var wp: CGFloat {
        combo.0/combo.4
    }
    
    var hp: CGFloat {
        combo.1/combo.4
    }
    
    @State var actualSize: CGSize = .zero
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(combo.3)
                    Text("\(String(format: "%.2f", wp))x\(String(format: "%.2f", hp))")
                    
                    Text("\(String(format: "%.2f", actualSize.width))x\(String(format: "%.2f", actualSize.height))")
                    
                    Text("Aspect: \(String(format: "%.2f", wp/hp)) vs actual \(String(format: "%.2f", actualSize.width/actualSize.height))")
                }
                Button("Debug") {
                    debug.toggle()
                }
            }.padding()
            
            PaletteSetterView {
                GeometryReader { gr in
                    NavigationView {
                        
                        NavigationList(shareCallback: { 
                            
                        }, gearCallback: {
                            
                        }, debug: $debug)
                        EmptyView()
                    }
                    .debugBorder(.yellow)
                    .onAppear {
                        actualSize = gr.size
                    }
                    .onChange(of: gr.size) { ns in 
                        actualSize = ns
                    }
                }
                .border(.red, width: 2)
                .aspectRatio(wp/hp, contentMode: .fit)
                .frame(
                    minWidth: wp,
                    minHeight: hp)
                .scaleEffect(0.75)
            }
            .aspectRatio(wp/hp, contentMode: .fit)
            .border(.white)
        }
        .environment(\.debug, debug)
    }
}

struct NavigationList_Previews: PreviewProvider {
    
    static let devices: [(CGFloat, CGFloat, String, String, CGFloat)] = [        
        // Required for screenshots
        (1125, 2436, "6.5 inch", "iPhone 11 Pro", 3),
        (1242, 2208, "5.5 inch", "iPhone 6s Plus", 3),
        
        // Just for testing
        (640, 1136, "4 inch", "iPhone SE", 2),
        (750, 1334, "4 inch", "iPhone SE (2nd gen)", 2),
        (1242, 2688, "4 inch", "iPhone 11 Pro Max", 3)
    ]
    
    static var previews: some View {
        ForEach(devices, id: \.3) {
            combo in 
            
            InternalDeviceSizeTestView(combo: combo)
        }
        
        ForEach(Locale.supportedLocales, id: \.self) {
            loc in
            PaletteSetterView {
                NavigationView {
                    NavigationList(shareCallback: { 
                        
                    }, gearCallback: {
                        
                    }, debug: .constant(false))
                    EmptyView()
                }
            }.environment(\.locale, loc)
        }
        
    }
}
