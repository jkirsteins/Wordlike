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
        Tile(letter: letter, delay: 0, revealState: keyboardHints.hints[letter], animate: false)
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
        Tile(letter: letter, delay: 0, revealState: keyboardHints.hints[letter], animate: false).background(GeometryReader {
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
                }
            }
            
            HStack(spacing: hspacing ) {
                Group {
                    SizeSettingKeyboardTile(maxSize: $maxSize, letter: "Ā")
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
                Spacer()
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
                    SizeConstrainedKeyboardTile(maxSize: maxSize, letter: "Ļ")
                }
                Spacer()
            }
            
        }
    }
}

struct LatvianKeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        LatvianKeyboardView()
            .environment(\.keyboardHints, KeyboardHints(hints: [
                "Ļ": .wrongPlace,
                "Ž": .rightPlace,
                "S": .wrongLetter,
            ], locale: "lv"))
    }
}
