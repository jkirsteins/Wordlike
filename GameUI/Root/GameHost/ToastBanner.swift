import SwiftUI

struct ToastBanner: View {
    let message: String
    
    @Environment(\.debug)
    var debugViz: Bool
    
    @Environment(\.palette)
    var palette: Palette
    
    var body: some View {
        VStack {
            Spacer().frame(maxHeight: 24)
            Text(message)
                .foregroundColor(palette.toastForeground)
                .fontWeight(.bold)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(palette.toastBackground))
        }
        .transition(.opacity)
        .padding()
        .border(debugViz ? .red : .clear)
    }
}

struct ToastBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ToastBanner(message: "Light message!?")
                .environment(\.palette, LightPalette2())
            ToastBanner(message: "Dark message!?")
                .environment(\.palette, DarkPalette2())
        }
    }
}
