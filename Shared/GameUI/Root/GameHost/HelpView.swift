import SwiftUI

struct WrongExampleWord: View {
    
    @Environment(\.locale)
    var locale: Locale
    
    var body: some View {
        switch(locale.languageCode) {
        case Locale.lv_LV.languageCode:
            HStack {
                AgitatedTile(model: TileModel(letter: "k", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "a", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "s", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "t", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "e", state: .wrongLetter))
            }
        case Locale.fr_FR.languageCode:
            HStack {
                AgitatedTile(model: TileModel(letter: "p", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "l", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "e", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "u", state: .wrongLetter))
                AgitatedTile(model: TileModel(letter: "r", state: .maskedFilled))
            }
        default:
            HStack {
                AgitatedTile(model: TileModel(letter: "v", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "a", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "g", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "u", state: .wrongLetter))
                AgitatedTile(model: TileModel(letter: "e", state: .maskedFilled))
            }
        }
    }
}

struct GreenExampleWord: View {
    
    @Environment(\.locale)
    var locale: Locale
    
    var body: some View {
        switch(locale.languageCode) {
        case Locale.lv_LV.languageCode:
            HStack {
                AgitatedTile(model: TileModel(letter: "s", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "p", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "ī", state: .rightPlace))
                AgitatedTile(model: TileModel(letter: "g", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "a", state: .maskedFilled))
            }
        case Locale.fr_FR.languageCode:
            HStack {
                AgitatedTile(model: TileModel(letter: "m", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "e", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "r", state: .rightPlace))
                AgitatedTile(model: TileModel(letter: "c", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "i", state: .maskedFilled))
            }
        default:
            HStack {
                AgitatedTile(model: TileModel(letter: "w", state: .rightPlace))
                AgitatedTile(model: TileModel(letter: "e", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "a", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "r", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "y", state: .maskedFilled))
            }
        }
    }
}

struct YellowExampleWord: View {
    
    @Environment(\.locale)
    var locale: Locale
    
    var body: some View {
        switch(locale.languageCode) {
        case Locale.lv_LV.languageCode:
            HStack {
                AgitatedTile(model: TileModel(letter: "p", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "l", state: .wrongPlace))
                AgitatedTile(model: TileModel(letter: "ū", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "k", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "a", state: .maskedFilled))
            }
        case Locale.fr_FR.languageCode:
            HStack {
                AgitatedTile(model: TileModel(letter: "f", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "i", state: .wrongPlace))
                AgitatedTile(model: TileModel(letter: "g", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "u", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "e", state: .maskedFilled))
            }
        default:
            HStack {
                AgitatedTile(model: TileModel(letter: "p", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "i", state: .wrongPlace))
                AgitatedTile(model: TileModel(letter: "l", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "l", state: .maskedFilled))
                AgitatedTile(model: TileModel(letter: "s", state: .maskedFilled))
            }
        }
    }
}

struct HelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Guess the daily word in 6 tries.")
                    .fixedSize(horizontal: false, vertical: true)
                Text("Each guess must be a valid five-letter word.")
                    .fixedSize(horizontal: false, vertical: true)
                Text("After each guess, the color of the tiles will change to show you how close your guess was to the word.")
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
            
            Text("Examples").fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                GreenExampleWord()
                .frame(maxHeight: 50)
                Text("The letter **W** is in the word and in the correct spot.")
            }
            //
            VStack(alignment: .leading, spacing: 16) {
                YellowExampleWord()
                .frame(maxHeight: 50)
                Text("The letter **I** is in the word but in a different spot.")
            }
            
            VStack(alignment: .leading, spacing: 16) {
                WrongExampleWord()
                .frame(maxHeight: 50)
                Text("The letter **U** is not in the word in any spot.")
            }
            
            Divider()
            
            Text("A new word is available every day.").fontWeight(.bold)
        }
        .frame(maxWidth: MockDeviceConfig.inch65_iPhone12ProMax.portrait.width)
        .navigationTitle("How to play")
    }
    
    struct HelpView_Previews: PreviewProvider {
        static var previews: some View {
            PaletteSetterView {
                HelpView()
            }
            
            if #available(iOS 15.0, *) {
                ForEach(AppView_Previews.configurations) {
                    MockDevice(config: $0) {
                        PaletteSetterView {
                            HelpView()
                        }
                    }
                }
            }
            
            VStack {
                Text("Testing help is scrollable (and doesn't compress text)").frame(minHeight: 200)
                HelpView()
            }
        }
    }
}
