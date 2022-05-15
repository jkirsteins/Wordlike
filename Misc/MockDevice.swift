import SwiftUI

/*
 
 NOTE: THIS CAN NOT BE USED FOR LANDSCAPE+iPAD
 (BECAUSE IT IGNORES THE MULTI-COLUMNS OF NAV VIEW)
 
 */

/// View for simulating constraints of different
/// device sizes.
struct MockDevice<Content: View>: View {
    let config: MockDeviceConfig
    
    @ViewBuilder var content: ()->Content
    
    @State var debug: Bool = true
    @State var locale: Locale = .current
    @State var actualSize: CGSize = .zero
    @State var screenshotter: ScreenshotMaker? = nil
    
    var actualString: String {
        let w = String(format: "%.1f", actualSize.width)
        let h = String(format: "%.1f", actualSize.height)
        let a = String(format: "%.2f", actualSize.width/actualSize.height)
        return "\(w)x\(h) (aspect: \(a))"
    }
    
    var scaleToApply: Double {
        actualSize.width / config.width 
    }
    
    var screenshotDescription: String {
        let w = config.width * config.scaleFactor
        let h = config.height * config.scaleFactor
        return "\(String(format: "%.0f", w))x\(String(format: "%.0f", h))"
    }
    
    var body: some View {
        GeometryReader { surrounding in 
            VStack(spacing: 0) {
                Text(config.comment)
                Text("Screenshot: \(screenshotDescription). \(config.isMandatory ? "Mandatory." : "")")
                
                HStack {
                    Button("Debug") { debug.toggle() }
                    Button("Screenshot") {
                        guard let s = screenshotter else { 
                            fatalError("Can't screenshot")
                        }
                        
                        let scale = config.scaleFactor / scaleToApply
                        let img = s.screenshot(scale: scale)!
                        
                        print("Screenshotted \(img.size.width*scale) \(img.size.height*scale) ")
                        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                    }
                }
                
                HStack {
                    ForEach(Locale.supportedLocales, id: \.self) { loc in
                        Button("\(loc.identifier)") {
                            self.locale = loc
                        }
                    }
                }
                
                Divider()
                
                ZStack {
                    content()
                        .environment(\.debug, debug)
                        .environment(\.locale, locale)
                        .screenshotView {
                            self.screenshotter = $0
                        }
                        .frame(
                            maxWidth: config.width, 
                            maxHeight: config.height)
                }
                .frame(
                    width: config.width,
                    height: config.height)
                .fixedSize()
                .scaleEffect(scaleToApply)
                .frame(
                    maxWidth: surrounding.size.width,
                    maxHeight: surrounding.size.width / config.aspectRatio)
                .clipped()
                .border(.red)
                .background(GeometryReader {
                    gr in 
                    Color.clear.onAppear {
                        actualSize = gr.size
                    }.onChange(of: gr.size) { new in
                        actualSize = new
                    }
                })
            }
        }
    }
}

struct MockDeviceConfig: Equatable, Hashable, Identifiable {
    typealias Points = Double
    
    let id = UUID()
    
    let width: Points
    let height: Points
    let scaleFactor: Double
    let comment: String
    
    var dimensionString: String {
        let w = String(format: "%.1f", width)
        let h = String(format: "%.1f", height)
        let a = String(format: "%.2f", aspectRatio)
        return "\(w)x\(h) (aspect: \(a))"
    }
    
    var aspectRatio: Double {
        width / height
    }
    
    var isMandatory: Bool {
        Self.mandatoryScreenshotConfigs.contains(self)
    }
    
    var rotated: MockDeviceConfig {
        MockDeviceConfig(
            width: height, 
            height: width, 
            scaleFactor: scaleFactor, 
            comment: "Rotated: \(comment)")
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
        comment: "6.5 inch (iPhone 12 Pro Max)")
    
    static let inch58_iPhone12Pro = MockDeviceConfig(
        width: 390, 
        height: 844, 
        scaleFactor: 3,
        comment: "5.8 inch (iPhone 12 Pro)")
    
    static let inch55_iPhone8Plus = MockDeviceConfig(
        width: 414, 
        height: 736, 
        scaleFactor: 3,
        comment: "5.5 inch (iPhone 8 Plus)")
    
    static let inch4_iPhoneSE = MockDeviceConfig(
        width: 320, 
        height: 568, 
        scaleFactor: 2, 
        comment: "4 inch (iPhone SE)")
    
    static let inch4_iPhoneSE2 = MockDeviceConfig(
        width: 375, 
        height: 667, 
        scaleFactor: 2, 
        comment: "4 inch (iPhone SE 2nd gen)")
    
    static let inch129_iPadPro4 = MockDeviceConfig(
        width: 1024, 
        height: 1366, 
        scaleFactor: 2, 
        comment: "12.9 inch (iPad Pro gen 4)")
}

struct MockDevice_Previews: PreviewProvider {
    static var previews: some View {
        MockDevice(config: .inch65_iPhone12ProMax) {
            Rectangle().fill(.red)
        }
        MockDevice(config: .inch4_iPhoneSE) {
            Rectangle().fill(.yellow)
        }
        AppView_Previews.previews
    }
}
