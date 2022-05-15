import SwiftUI

fileprivate struct FrenchLogo: View {
    @State var wtype: TileBackgroundType = .rightPlace
    
    var body: some View {
        VStack {
            HStack {
                AgitatedTile("M")
                AgitatedTile("o")
                AgitatedTile("t")
                Tile("_").opacity(0).frame(maxWidth: 8)
                AgitatedTile("d")
                AgitatedTile("e")
            }
            HStack {
                AgitatedTile("j")
                AgitatedTile("o")
                AgitatedTile("u")
                AgitatedTile("r")
                Tile("_").opacity(0)
                Tile("_").opacity(0).frame(maxWidth: 8)
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
            .frame(maxWidth: .infinity)
            
            HStack {
                Tile("_").opacity(0)
                AgitatedTile("l")
                AgitatedTile("i")
                AgitatedTile("k")
                AgitatedTile("e")
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .debugBorder(.green)
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
        HStack {
            VStack(alignment: .leading) {
                /* Switch on region not language code,
                 because we want to display the localized logo
                 even if rest of UI is expected to be in a 
                 different language.*/
                switch(locale.languageCode, locale.regionCode) {
                    /* In Latvia look at either region or
                     language code to influence the logo. */
                case 
                    (_, Locale.lv_LV.regionCode),
                    (Locale.lv_LV.languageCode, _):
                    LatvianLogo()
                    
                    /* In other languages go by language code */
                case (Locale.fr_FR.languageCode, _):
                    FrenchLogo()
                default:
                    EnglishLogo()
                }
            }
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
        VStack(alignment: .leading) {
            Text("Multiple together")
            
            HStack {
                VStack {
                    Logo()
                        .environment(\.locale, .lv_LV)
                }
            }
            .padding(2)
            .border(.red)
            
            HStack {
                Logo()
                    .environment(\.locale, .fr_FR)
            }
            .padding(2)
            .border(.red)
            
            HStack {
                Logo()
                    .environment(\.locale, .en_US)
            }
            .padding(2)
            .border(.red)
            
            Divider()
            
            Text("The inner logo should have the same width/no extra padding")
            
            HStack {
                EnglishLogo()
                    .frame(maxWidth: .infinity)
                    .border(.green, width: 2)
            }
            .border(.red)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .border(.green)
        
        ForEach(Self.locales, id: \.self) { loc in 
            PaletteSetterView {
                VStack {
                    Text("Logo in \(loc.identifier)")
                    Logo()
                        .border(.red)
                }.border(.green)
            }
            .padding()
            .environment(\.locale, loc)
        }
    }
}
