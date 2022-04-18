import SwiftUI

extension Color {
    static func keyboardFill(for type: TileBackgroundType?, from palette: Palette) -> Color {
        
        guard let type = type else {
            return palette.normalKeyboardFill
        }    
        
        return type.fillColor(from: palette)
    }
    
    func adjust(pressed: Bool) -> Color {
        if pressed { 
            return self.darker 
        }
        return self
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension Color {
    
    var darker: Color {
        guard let comps = self.rgba else {
            return self 
        }
        
        return Color.multiply(comps, by: 0.8)
    }
    
    var lighter: Color {
        guard let comps = self.rgba else {
            return self 
        }
        
        return Color.multiply(comps, by: 1.2)
    }
    
    static func multiply(_ comps: RGBA, by ratio: CGFloat) -> Color  { 
        let r = min(max(comps.red * ratio, 0.0), 1.0)
        let g = min(max(comps.green * ratio, 0.0), 1.0)
        let b = min(max(comps.blue * ratio, 0.0), 1.0)
        return Color(red: r, green: g, blue: b)
    }
    
    var uiColor: UIColor { .init(self) }
    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var rgba: RGBA? {
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        return uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) ? (r, g, b, a) : nil
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
