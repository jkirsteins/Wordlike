import SwiftUI


extension Color {
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

struct SubmitButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // blue is 0x007afe
            RoundedRectangle(cornerRadius: 4.0)
                .fill(configuration.isPressed ? Color(hex: 0x0058dc) : .blue)
            
            configuration.label
                .foregroundColor(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4.0))
    }
}

struct SubmitTile: View {
    let maxSize: CGSize
    
    var body: some View {
        Button(action: {
            print("Submitting... \(Color.blue.hexaRGB)")
        }, label: {
            Image(systemName: "return")
        })
            .buttonStyle(SubmitButtonStyle())
            .frame(
                maxWidth: maxSize.width, 
                maxHeight: maxSize.height)
    }
} 

struct SubmitTile_Previews: PreviewProvider {
    static var previews: some View {
        SubmitTile(maxSize: 
                    CGSize(width: 200, height: 100))
    }
}
