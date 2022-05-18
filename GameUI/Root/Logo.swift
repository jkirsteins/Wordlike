import SwiftUI

fileprivate let SPACING = GridPadding.normal

fileprivate struct FrenchLogo: View {
    @State var wtype: TileBackgroundType = .rightPlace
    
    var body: some View {
        VStack(spacing: SPACING) {
            HStack(spacing: SPACING) {
                AgitatedTile("M")
                AgitatedTile("o")
                AgitatedTile("t")
                Tile("_").opacity(0).frame(maxWidth: 8)
                AgitatedTile("d")
                AgitatedTile("u")
            }
            HStack(spacing: SPACING) {
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
        VStack(spacing: SPACING) {
            HStack(spacing: SPACING) {
                AgitatedTile("W")
                AgitatedTile("o")
                AgitatedTile("r")
                AgitatedTile("d")
                Tile("_").opacity(0)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: SPACING) {
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

fileprivate struct ShortLatvianLogo: View {
    
    let maxd = Double(12.0)
    
    var randRotate: Double {
        let x = maxd * drand48()
        let r = (maxd/2.0) - x
        return r
    }
    
    @Environment(\.palette)
    var palette: Palette
    
    var body: some View {
        /* smaller SPACING because the "-" at the end
         makes everything smaller already
        */
        VStack(alignment: .leading, spacing: SPACING/2) {
            HStack(spacing: SPACING/2) {
                AgitatedTile("V")
                AgitatedTile("ā")
                AgitatedTile("r")
                AgitatedTile("d")
                AgitatedTile("u")
                RoundedRectangle(cornerRadius: 2)
                    .fill(palette.revealedTextColor)
                    .frame(maxWidth: 14, maxHeight: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2).stroke(palette.wrongLetterStroke)
                    )
                    .rotationEffect(.degrees(randRotate))
//                Text("-").fontWeight(.bold).font(.title)
//                    .front
//                    .border(.black)
                Tile("_").opacity(0).frame(maxWidth: 8)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: SPACING/2) {
                Tile("_").opacity(0).frame(maxWidth: 8)
                AgitatedTile("l")
                AgitatedTile("i")
                AgitatedTile("s")
                Tile("_").opacity(0)
                Tile("_").opacity(0)
                Text("-").fontWeight(.bold).font(.title).opacity(0)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

fileprivate struct LatvianLogo: View {
    var body: some View {
        ShortLatvianLogo()
            .frame(maxWidth: .infinity)
    }
}

struct Logo: View {
    @Environment(\.locale)
    var locale: Locale 
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
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
        .debugBelow {
            Text(verbatim: locale.identifier)
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
