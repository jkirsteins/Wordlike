import SwiftUI

private struct KeyboardHintEnvironmentKey: EnvironmentKey {
    static let defaultValue: KeyboardHints = KeyboardHints(hints: [:], locale: "en")
}

extension EnvironmentValues {
    var keyboardHints: KeyboardHints {
        get { self[KeyboardHintEnvironmentKey.self] }
        set { self[KeyboardHintEnvironmentKey.self] = newValue }
    }
}

struct KeyboardTile: View {
    let letter: String 
    
    @Environment(\.keyboardHints) 
    var keyboardHints: KeyboardHints
    
    var body: some View {
        Button(letter) {
            print("bim")
        }
        .buttonStyle(
            KeyboardButtonStyle(type: keyboardHints.hints[letter]))
        //        .frame(maxWidth: 30, maxHeight: 100)
        
        
        .aspectRatio(1.0, contentMode: .fit)
        //        .scaledToFit()
        
        //        .frame(minWidth: 8, maxWidth: 44, minHeight: 8, maxHeight: 44)
        
        //        .border(.black)
        //        Tile(letter: letter, delay: 0, revealState: keyboardHints.hints[letter], animate: false)
    }
}

struct KeyboardButtonStyle: ButtonStyle {
    @Environment(\.palette) var palette: Palette
    
    let type: TileBackgroundType?
    
    func fontSize(_ gr: GeometryProxy) -> Double {
        if gr.size.height < 50 {
            // Hardcode some value which is used for
            // small previews (like in a keyboard
            // accessory view)
            return 12
        }
        
        return gr.size.height/1.5
    }
    
    func padding(_ gr: GeometryProxy) -> Double {
        if gr.size.height < 50 {
            // Hardcode some value which is used for
            // small previews (like in a keyboard
            // accessory view)
            return 0
        }
        
        return 4
    }
    
    var computedType: TileBackgroundType {
        return type ?? .wrongLetter
    }
    
    func textColor(_ configuration: Configuration) -> Color {
        guard let type = type else {
            return .white
        }
        
        guard type != .wrongLetter else {
            return .white
        }
        
        return .white
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(
                    Color.keyboardFill(
                        for: type, from: palette)
                        .adjust(
                            pressed: configuration.isPressed)
                )
            
            configuration.label
                .foregroundColor(textColor(configuration))
        }
        .clipShape(RoundedRectangle(cornerRadius: 4.0))
    }
}

struct SizeConstrainedKeyboardTile: View {
    let maxSize: CGSize
    let letter: String 
    
    var body: some View {
        KeyboardTile(
            letter: letter).frame(
                minWidth: maxSize.width,
                maxWidth: maxSize.width, 
                minHeight: maxSize.height,
                maxHeight: maxSize.height)
    }
}

struct SizeSettingKeyboardTile: View {
    @Binding var maxSize: CGSize 
    
    let letter: String 
    
    @Environment(\.keyboardHints) 
    var keyboardHints: KeyboardHints
    
    var body: some View {
        KeyboardTile(letter: letter).background(GeometryReader {
            proxy in 
            
            Color.clear
                .onAppear {
                    maxSize = proxy.size
                }
                .onChange(of: proxy.size) { newSize in
                    maxSize = newSize
                }
        })
    }
}

struct LatvianKeyboardView: View {
    @State var maxSize: CGSize = .zero
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1) 
    
    var wideSize: CGSize {
        CGSize(width: maxSize.width*2, height: maxSize.height)
    }
    
    var body: some View {
        VStack(spacing: vspacing) {
            HStack(spacing: hspacing) {
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "E")
                    
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Ē")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "R")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "T")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "U")
                }
                
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Ū")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "I")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Ī")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "O")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "P")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Ķ")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Ļ")
                }
                
                
            }
            
            HStack(spacing: hspacing ) {
                Group {
                    SizeSettingKeyboardTile(maxSize: $maxSize, letter: "A")
                    KeyboardTile(letter: "Ā")
                    KeyboardTile(letter: "S")
                    KeyboardTile(letter: "Š")
                    KeyboardTile(letter: "D")
                }
                Group {
                    KeyboardTile(letter: "F")
                    KeyboardTile(letter: "G")
                    KeyboardTile(letter: "Ģ")
                    KeyboardTile(letter: "H")
                    KeyboardTile(letter: "J")
                }
                Group {
                    KeyboardTile(letter: "K")
                    KeyboardTile(letter: "L")
                }
            }
            
            HStack(spacing: hspacing) {
                BackspaceTile(maxSize: wideSize)
                
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Z")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Ž")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "C")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Č")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "V")
                }
                Group {
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "B")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "N")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Ņ")
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "M")
                }
                
                SubmitTile(maxSize: CGSize(width: maxSize.width*2, height: maxSize.height))
            }
            
        }
        .frame(maxWidth: 600)
        .border(.green)
    }
}

struct LatvianKeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Latvian keyboard (light)")
            
            LatvianKeyboardView()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: "lv"))
                .environment(\.palette, LightPalette())
        }
        
        VStack {
            Text("Latvian keyboard (light hc)")
            
            LatvianKeyboardView()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: "lv"))
                .environment(\.palette, LightHCPalette())
        }
        
        VStack {
            Text("Latvian keyboard (dark)")
            
            LatvianKeyboardView()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: "lv"))
                .environment(\.palette, DarkPalette())
        }
    }
}
