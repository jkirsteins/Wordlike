import SwiftUI

private struct KeyboardHintEnvironmentKey: EnvironmentKey {
    static let defaultValue: KeyboardHints = KeyboardHints(
        hints: Dictionary<CharacterModel, TileBackgroundType>(), 
        locale: .en_US)
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
    
    let locale = Locale.lv_LV
    
    
    var body: some View {
        KeyboardContainer(spacing: vspacing) {
            RowContainer(spacing: hspacing) {
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "E", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ē",
                        locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "R",
                        locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "T",
                        locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "U",
                        locale: locale)
                }
                
                Group {
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ū", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "I", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ī", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "O", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "P", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ķ", locale: locale)
                    SizeConstrainedKeyboardButton(
                        maxSize: maxSize, letter: "Ļ", locale: locale)
                }
                
                
            }
            
            RowContainer(spacing: hspacing ) {
                Group {
                    SizeSettingKeyboardButton(maxSize: $maxSize, letter: "A", locale: locale)
                    KeyboardButton(letter: "Ā", locale: locale)
                    KeyboardButton(letter: "S", locale: locale)
                    KeyboardButton(letter: "Š", locale: locale)
                    KeyboardButton(letter: "D", locale: locale)
                }
                Group {
                    KeyboardButton(letter: "F", locale: locale)
                    KeyboardButton(letter: "G", locale: locale)
                    KeyboardButton(letter: "Ģ", locale: locale)
                    KeyboardButton(letter: "H", locale: locale)
                    KeyboardButton(letter: "J", locale: locale)
                }
                Group {
                    KeyboardButton(letter: "K", locale: locale)
                    KeyboardButton(letter: "L", locale: locale)
                }
            }
            
            RowContainer(spacing: hspacing) {
                BackspaceButton(maxSize: wideSize)
                
                Group {
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Z", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Ž", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "C", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Č", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "V", locale: locale)
                }
                Group {
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "B", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "N", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "Ņ", locale: locale)
                    SizeConstrainedKeyboardButton(maxSize: maxSize, letter: "M", locale: locale)
                }
                
                SubmitButton<WordValidator>(maxSize: wideSize)
            }
        }
    }
}

struct LatvianKeyboardView_Previews: PreviewProvider {
    static let state = GameState(expected: TurnAnswer(word: "fuels", day: 1, locale: .lv_LV(simplified: false), validator: WordValidator(locale: .lv_LV(simplified: false))))
    
    static var previews: some View {
        VStack {
            Text("Latvian keyboard (light)")
            
            LatvianKeyboard()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: .lv_LV(simplified: false)))
                .environment(\.palette, LightPalette())
        }.environmentObject(state)
        
        VStack {
            Text("Latvian keyboard (light hc)")
            
            LatvianKeyboard()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: .lv_LV(simplified: false)))
                .environment(\.palette, LightHCPalette())
        }.environmentObject(state)
        
        VStack {
            Text("Latvian keyboard (dark)")
            
            LatvianKeyboard()
                .environment(\.keyboardHints, KeyboardHints(hints: [
                    "Ļ": .wrongPlace,
                    "Ž": .rightPlace,
                    "S": .wrongLetter,
                ], locale: .lv_LV(simplified: false)))
                .environment(\.palette, DarkPalette())
        }.environmentObject(state)
    }
}
