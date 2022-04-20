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

/// Latvian qwerty keyboard
struct LatvianKeyboard: View {
    @State var maxSize: CGSize = .zero
    
    @EnvironmentObject 
    var toastMessageCenter: ToastMessageCenter
    
    let hspacing = CGFloat(1) 
    let vspacing = CGFloat(1) 
    
    var wideSize: CGSize {
        CGSize(
            width: maxSize.width*1.5 + hspacing, 
            height: maxSize.height)
    }
    
    var body: some View {
        KeyboardContainer(spacing: vspacing) {
            RowContainer(spacing: hspacing) {
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "E")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ē")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "R")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "T")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "U")
                }
                
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ū")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "I")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ī")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "O")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "P")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ķ")
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ļ")
                }
                
                
            }
            
            RowContainer(spacing: hspacing ) {
                Group {
                    SizeSettingKeyboardButton(maxSize: $maxSize, letter: "A")
                    KeyboardButton(letter: "Ā")
                    KeyboardButton(letter: "S")
                    KeyboardButton(letter: "Š")
                    KeyboardButton(letter: "D")
                }
                Group {
                    KeyboardButton(letter: "F")
                    KeyboardButton(letter: "G")
                    KeyboardButton(letter: "Ģ")
                    KeyboardButton(letter: "H")
                    KeyboardButton(letter: "J")
                }
                Group {
                    KeyboardButton(letter: "K")
                    KeyboardButton(letter: "L")
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceButton(maxSize: wideSize)
                
                Group {
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Z")
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Ž")
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "C")
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Č")
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "V")
                }
                Group {
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "B")
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "N")
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Ņ")
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "M")
                }
                
                SubmitButton(maxSize: wideSize)
            }
        }
    }
}

struct LatvianKeyboardView_Previews: PreviewProvider {
    static let state = GameState(expected: TurnAnswer(word: "fuels", day: 1, locale: "en"))
    
    static var previews: some View {
        VStack {
            Text("Latvian keyboard (light)")
            
            LatvianKeyboard()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: "lv"))
                .environment(\.palette, LightPalette())
        }.environmentObject(state)
        
        VStack {
            Text("Latvian keyboard (light hc)")
            
            LatvianKeyboard()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: "lv"))
                .environment(\.palette, LightHCPalette())
        }.environmentObject(state)
        
        VStack {
            Text("Latvian keyboard (dark)")
            
            LatvianKeyboard()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: "lv"))
                .environment(\.palette, DarkPalette())
        }.environmentObject(state)
    }
}
