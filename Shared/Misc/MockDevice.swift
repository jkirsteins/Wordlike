import SwiftUI

/*
 
 This can be used to generate screenshots for different
 device configurations. It should also work with
 different size classes (so e.g. iPad landscape should
 show expanded navigation view etc.)
 
 */
struct MockSizeClassModifier: ViewModifier {
    let config: SizeClassOrientationConfig
    
    func body(content: Content) -> some View {
#if os(iOS)
        content
            .environment(
                \.horizontalSizeClass,
                 config.horizontalSizeClass)
            .environment(
                \.verticalSizeClass,
                 config.verticalSizeClass)
#else
        content
#endif
    }
}

/// View for simulating constraints of different
/// device sizes.
@available(iOS 15.0, *)
struct MockDevice<Content: View>: View {
    let config: MockDeviceConfig
    @ViewBuilder var content: ()->Content
    
    @State var debug: Bool = true
    @State var portrait: Bool = true
    
    @State var locale: Locale = .current
    @State var viewPort: CGSize = .zero
    
#if os(iOS)
    @State var screenshotter: ScreenshotMaker? = nil
#endif
    
    var orientationConfig: MockOrientationConfig {
        portrait ? config.portrait : config.landscape
    }
    
    var actualString: String {
        let w = String(format: "%.1f", viewPort.width)
        let h = String(format: "%.1f", viewPort.height)
        let a = String(format: "%.2f", viewPort.width/viewPort.height)
        return "\(w)x\(h) (aspect: \(a))"
    }
    
    var scaleToApply: Double {
        guard orientationConfig.width > viewPort.height || orientationConfig.height > viewPort.height else {
            return 1.0
        }
        
        if orientationConfig.isPortrait {
            return viewPort.height / orientationConfig.height
        } else {
            return viewPort.width / orientationConfig.width
        }
    }
    
    var screenshotDescription: String {
        let w = orientationConfig.width * orientationConfig.scaleFactor
        let h = orientationConfig.height * orientationConfig.scaleFactor
        return "\(String(format: "%.0f", w))x\(String(format: "%.0f", h))"
    }
    
    var configDescription: String {
        "\(orientationConfig.comment). \(orientationConfig.width > orientationConfig.height ? "Landscape" : "Portrait")."
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(configDescription)
            Text("Screenshot: \(screenshotDescription). \(config.isMandatory ? "Mandatory." : "")")
            
            HStack {
                Button("Debug") { debug.toggle() }
                Button("Rotate") {
                    portrait.toggle()
                }
#if os(iOS)
                Button("Screenshot") {
                    guard let s = screenshotter else {
                        fatalError("Can't screenshot")
                    }
                    
                    let scale = orientationConfig.scaleFactor / scaleToApply
                    let img = s.screenshot(scale: scale)!
                    
                    let pixelWidth = img.size.width*scale
                    let pixelHeight = img.size.height*scale
                    guard
                        pixelWidth == orientationConfig.pixelWidth,
                        pixelHeight == orientationConfig.pixelHeight
                    else {
                        print("Failed to screenshot. Got size \(pixelWidth) \(pixelHeight) but expected \(orientationConfig.pixelWidth) \(orientationConfig.pixelHeight)")
                        return
                    }
                    
                    
                    print("Screenshotted \(img.size.width*scale) \(img.size.height*scale) ")
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                }
#endif
            }
            
            HStack {
                ForEach(Locale.supportedLocales, id: \.self) { loc in
                    Button("\(loc.identifier)") {
                        self.locale = loc
                    }
                }
            }
            
            Divider()
            
            /* The rectangle will fill available
             space and be used as the viewport */
            Rectangle().fill(.gray)
            /* Overlay lets this go outside of bounds,
             not affecting the size. */
                .overlay {
                    content()
                        .modifier(MockSizeClassModifier(config: orientationConfig.sizeClass))
                        .environment(\.debug, debug)
                        .environment(\.locale, locale)
#if os(iOS)
                        .screenshotView {
                            self.screenshotter = $0
                        }
#endif
                        .aspectRatio(orientationConfig.aspectRatio, contentMode: .fit)
                        .frame(
                            width: orientationConfig.width,
                            height: orientationConfig.height)
                        .scaleEffect(scaleToApply)
                }
                .aspectRatio(orientationConfig.aspectRatio, contentMode: .fit)
                .background(GeometryReader {
                    gr in
                    Color.clear.onAppear {
                        self.viewPort = gr.size
                    }.onChange(of: gr.size) {
                        newSize in
                        self.viewPort = newSize
                    }
                })
            /* padding takes us out of the render zone,
             so we can add a red border */
                .padding(1)
                .border(.red)
        }
    }
}

enum MockUserInterfaceSizeClass {
    case regular
    case compact
}

struct SizeClassOrientationConfig: Equatable, Hashable {
    let horizontalSizeClass: NativeUserInterfaceSizeClass
    let verticalSizeClass: NativeUserInterfaceSizeClass
    
    var swapped: SizeClassOrientationConfig {
        SizeClassOrientationConfig(
            horizontalSizeClass: verticalSizeClass,
            verticalSizeClass: horizontalSizeClass)
    }
    
    static let rWrH = SizeClassOrientationConfig(
        horizontalSizeClass: .regular,
        verticalSizeClass: .regular)
    
    static let cWrH = SizeClassOrientationConfig(
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular)
    
    static let rWcH = SizeClassOrientationConfig(
        horizontalSizeClass: .regular,
        verticalSizeClass: .compact)
    
    static let cWcH = SizeClassOrientationConfig(
        horizontalSizeClass: .compact,
        verticalSizeClass: .compact)
}

struct SizeClassDeviceConfig: Equatable, Hashable {
    let portrait: SizeClassOrientationConfig
    let landscape: SizeClassOrientationConfig
    
    static let ipad = SizeClassDeviceConfig(portrait: .rWrH, landscape: .rWrH)
    static let iphoneMax = SizeClassDeviceConfig(portrait: .cWrH, landscape: .rWcH)
    static let iphonePlus = SizeClassDeviceConfig(portrait: .cWrH, landscape: .rWcH)
    static let iphone = SizeClassDeviceConfig(portrait: .cWrH, landscape: .cWcH)
}

typealias Points = Double

struct MockOrientationConfig: Equatable, Hashable {
    let width: Points
    let height: Points
    let scaleFactor: Double
    let comment: String
    let sizeClass: SizeClassOrientationConfig
    let isMandatory: Bool
    
    var aspectRatio: Double {
        width / height
    }
    
    var pixelWidth: Double { width * scaleFactor }
    var pixelHeight: Double { height * scaleFactor }
    
    var isPortrait: Bool {
        width < height
    }
    
    var dimensionString: String {
        let w = String(format: "%.1f", width)
        let h = String(format: "%.1f", height)
        let a = String(format: "%.2f", aspectRatio)
        return "\(w)x\(h) (aspect: \(a))"
    }
}

struct MockDeviceConfig: Equatable, Hashable, Identifiable {
    let id = UUID()
    
    /// width should be accessed via orientation
    private let width: Points
    /// height should be accessed via orientation
    private let height: Points
    /// scaleFactor should be accessed via orientation
    private let scaleFactor: Double
    /// comment should be accessed via orientation
    private let comment: String
    
    var portrait: MockOrientationConfig {
        MockOrientationConfig(
            width: width,
            height: height,
            scaleFactor: scaleFactor,
            comment: comment,
            sizeClass: sizeClasses.portrait,
            isMandatory: isMandatory)
    }
    
    var landscape: MockOrientationConfig {
        MockOrientationConfig(
            width: height,
            height: width,
            scaleFactor: scaleFactor,
            comment: comment,
            sizeClass: sizeClasses.landscape,
            isMandatory: false) // only portrait
    }
    
    /* For size class source-of-truth see:
     https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/adaptivity-and-layout/
     */
    let sizeClasses: SizeClassDeviceConfig
    
    var isMandatory: Bool {
        Self.mandatoryScreenshotConfigs.contains(self)
    }
    
    // Mandatory screenshots:
    // https://help.apple.com/app-store-connect/#/devd274dd925
    static let mandatoryScreenshotConfigs: [MockDeviceConfig] = [
        .inch65_iPhone12ProMax,
        .inch55_iPhone8Plus,
        .inch129_iPadPro4
    ]
    
    static let inch65_iPhone12ProMax = MockDeviceConfig(
        width: 428,
        height: 926,
        scaleFactor: 3,
        comment: "6.5 inch (iPhone 12 Pro Max)",
        sizeClasses: .iphoneMax
    )
    
    static let inch58_iPhone12Pro = MockDeviceConfig(
        width: 390,
        height: 844,
        scaleFactor: 3,
        comment: "5.8 inch (iPhone 12 Pro)",
        sizeClasses: .iphone
    )
    
    static let inch58_iPhone11Pro = MockDeviceConfig(
        width: 375,
        height: 812,
        scaleFactor: 3,
        comment: "5.8 inch (iPhone 11 Pro)",
        sizeClasses: .iphone
    )
    
    static let inch55_iPhone8Plus = MockDeviceConfig(
        width: 414,
        height: 736,
        scaleFactor: 3,
        comment: "5.5 inch (iPhone 8 Plus)",
        sizeClasses: .iphonePlus
    )
    
    static let inch4_iPhoneSE = MockDeviceConfig(
        width: 320,
        height: 568,
        scaleFactor: 2,
        comment: "4 inch (iPhone SE)",
        sizeClasses: .iphone)
    
    static let inch4_iPhoneSE2 = MockDeviceConfig(
        width: 375,
        height: 667,
        scaleFactor: 2,
        comment: "4 inch (iPhone SE 2nd gen)",
        sizeClasses: .iphone)
    
    static let inch129_iPadPro4 = MockDeviceConfig(
        width: 1024,
        height: 1366,
        scaleFactor: 2,
        comment: "12.9 inch (iPad Pro gen 4)",
        sizeClasses: .ipad)
}

struct MockDevice_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            MockDevice(config: .inch65_iPhone12ProMax) {
                Rectangle().fill(.red)
            }
            MockDevice(config: .inch4_iPhoneSE) {
                Rectangle().fill(.yellow)
            }
        }
        AppView_Previews.previews
    }
}
