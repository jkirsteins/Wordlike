import SwiftUI


struct SubmitButtonStyle: ButtonStyle {
    let normal = Color.blue 
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // blue is 0x007afe
            RoundedRectangle(cornerRadius: 4.0)
                .fill(configuration.isPressed ? normal.darker : normal)
            
            configuration.label
                .foregroundColor(configuration.isPressed ? .white.darker : .white)
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
