import SwiftUI

/// Helpers for Color to get the right colors for
/// tiles or keyboard button colors.
extension Color {
    static var random: Color {        
        return Color(
            red:    Double.random,
            green:  Double.random,
            blue:   Double.random
        )
    }
    
    static func keyboardFill(for type: TileBackgroundType?, from palette: Palette) -> Color {
        
        guard let type = type else {
            return palette.normalKeyboardFill
        }
        
        return type.fillColor(from: palette)
    }
    
    /// Helper for keyboard buttons (darken a color
    /// if the button is pressed)
    func adjust(pressed: Bool) -> Color {
        if pressed {
            return self.darker
        }
        return self
    }
    
    /// Initialize via hex e.g. 0xFF0000 for red
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    /// Darken a color
    var darker: Color {
        guard let comps = self.rgba else {
            return self
        }
        
        return Color.multiply(comps, by: 0.8)
    }
    
    func darker(_ times: Int) -> Color {
        times == 1 ? self.darker : self.darker.darker(times - 1)
    }
    
    /// Lighten a color
    var lighter: Color {
        guard let comps = self.rgba else {
            return self
        }
        
        return Color.multiply(comps, by: 1.2)
    }
    
    func lighter(_ times: Int) -> Color {
        times == 1 ? self.lighter : self.lighter.lighter(times - 1)
    }
    
    /// Multiple all components of a color
    static func multiply(_ comps: RGBA, by ratio: CGFloat) -> Color {
        let r = min(max(comps.red * ratio, 0.1), 1.0)
        let g = min(max(comps.green * ratio, 0.1), 1.0)
        let b = min(max(comps.blue * ratio, 0.1), 1.0)
        return Color(red: r, green: g, blue: b)
    }
    
    var uiColor: NativeColor { .init(self) }
    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var rgba: RGBA? {
#if os(macOS)
        let ciColor:CIColor = CIColor(color: uiColor)!
        
        return (ciColor.red, ciColor.green, ciColor.blue, ciColor.alpha)
#else
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        return uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) ? (r, g, b, a) : nil
#endif
    }
    var hexaRGB: String? {
        guard let (red, green, blue, _) = rgba else { return nil }
        return String(format: "#%02x%02x%02x",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
    }
    var hexaRGBA: String? {
        guard let (red, green, blue, alpha) = rgba else { return nil }
        return String(format: "#%02x%02x%02x%02x",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255),
                      Int(alpha * 255))
    }
}

struct InternalColorTestView: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(.blue.darker.darker)
                .frame(width: 45, height: 45)
            Rectangle()
                .fill(.blue.darker)
                .frame(width: 45, height: 45)
            Rectangle()
                .fill(.blue)
                .frame(width: 45, height: 45)
            Rectangle()
                .fill(.blue.lighter)
                .frame(width: 45, height: 45)
            Rectangle()
                .fill(.blue.lighter.lighter)
                .frame(width: 45, height: 45)
        }
    }
}

struct InternalColorTestView_Previews: PreviewProvider {
    static var previews: some View {
        InternalColorTestView()
    }
}
