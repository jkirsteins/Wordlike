import SwiftUI

fileprivate struct FrenchLogo: View {
    @State var wtype: TileBackgroundType = .rightPlace
    
    var body: some View {
        VStack {
            HStack {
                AgitatedTile("M")
                AgitatedTile("o")
                AgitatedTile("t")
                AgitatedTile("d")
                AgitatedTile("e")
            }
            HStack {
                AgitatedTile("j")
                AgitatedTile("o")
                AgitatedTile("u")
                AgitatedTile("r")
                Tile("_").opacity(0)
            }
        }
    }
}

fileprivate struct EnglishLogo: View {
    @State var wtype: TileBackgroundType = .rightPlace
    
    var body: some View {
        VStack {
            HStack {
                AgitatedTile("W")
                AgitatedTile("o")
                AgitatedTile("r")
                AgitatedTile("d")
                Tile("_").opacity(0)
            }
            HStack {
                Tile("_").opacity(0)
                AgitatedTile("l")
                AgitatedTile("i")
                AgitatedTile("k")
                AgitatedTile("e")
            }
        }
    }
}

fileprivate struct LatvianLogo: View {
    var body: some View {
        VStack {
            HStack {
                AgitatedTile("V")
                AgitatedTile("ā")
                AgitatedTile("r")
                AgitatedTile("d")
                AgitatedTile("u")
            }
            HStack {
                AgitatedTile("l")
                AgitatedTile("i")
                AgitatedTile("s")
                Tile("_").opacity(0)
                Tile("_").opacity(0)
            }
        }
    }
}

struct Logo: View {
    @Environment(\.locale)
    var locale: Locale 
    
    var body: some View {
        switch(locale) {
            case .lv_LV:
            LatvianLogo()
            case .fr_FR:
            FrenchLogo()
            default:
            EnglishLogo()
        }
    }
}

struct Logo_Previews: PreviewProvider {
    static let locales: [Locale] = [
        .en_US,
        .en_GB,
        .fr_FR,
        .lv_LV
    ]
    static var previews: some View {
        ForEach(Self.locales, id: \.self) { loc in 
            PaletteSetterView {
                VStack {
                    Text("Logo in \(loc.identifier)")
                    Logo()
                }
            }
            .padding()
            .environment(\.locale, loc)
        }
    }
}
