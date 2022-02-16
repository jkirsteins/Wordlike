import SwiftUI

struct Row: View {
    let expected = "FUELS"
    
    @State var word: String?
    
    func revealState(_ ix: Int) -> TileBackgroundType?
    {
        guard let word = word?.uppercased(), word.count == 5, ix < 5 else {
            return nil
        }
        
        if Array(word)[ix] == Array(expected)[ix] {
            return .rightPlace
        }
        
        if expected.contains(Array(word)[ix]) {
            return .wrongPlace
        }
        
        return .wrongLetter
    }
    
    var body: some View {
        if let word = word {
            HStack {
                ForEach(0..<5) { ix in
                    Tile(
                        letter: word.count > ix ? String(Array(word)[ix]) : nil, 
                        delay: ix,
                        revealState: revealState(ix))
                }
            }
        } else {
            HStack {
                ForEach(0..<5) { _ in
                    Tile(
                        letter: nil, 
                        delay: 0,
                        revealState: nil)
                }
            }
        }
    }
}

struct Row_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Row(word: "fuels")
            Row(word: "halos")
            Row(word: "fur")  
            Row(word: nil)
        }
    }
}
