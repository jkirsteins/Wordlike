import SwiftUI

struct KeyboardHintView: View {
    let hints: KeyboardHints
    
    var orderedKeys: [String] { 
        Array(hints.keys).sorted()
    }
    
    var body: some View {
        if hints.isEmpty {
            Text("You haven't guessed any letters yet.")
        }
        
        HStack {
            ForEach(orderedKeys, id: \.self) {
                key in 
                
                VStack {
                    Tile(letter: key,
                         delay: 0, 
                         revealState: hints[key], 
                         animate: false)
                }
            }
        }
    }
}

struct KeyboardHints_TestView: View {
    let state: GameState 
    
    var body: some View {
        return VStack {
            ForEach([state]) {
                st in 
                VStack {
                    Text(verbatim: st.expected.word.uppercased())
                        .font(.largeTitle)
                    
                    VStack {
                        Text("Submitted rows")
                        ForEach(st.rows.filter({ $0.isSubmitted })) {
                            rowModel in 
                            
                            Row(delayRowIx: 0, model: rowModel)
                        }
                    }
                    
                    VStack {
                        Text("Hints")
                        
                        KeyboardHintView(hints: state.keyboardHints)
                    }
                }
            }
        }
    }
}

struct KeyboardHints_TestView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Test that unsubmitted rows are ignored.")
            Divider()
            KeyboardHints_TestView(state: GameState(
                initialized: true, 
                expected: DayWord(word: "fuels", day: 1, locale: "en"), rows: [
                    RowModel(word: "pluck", expected: "fuels", isSubmitted: true),
                    RowModel(word: "pales", expected: "fuels", isSubmitted: false)
                ], isTallied: false, date: Date()))
        }
        
        VStack {
            Text("Test that green overrides yellow (same row).")
            Divider()
            KeyboardHints_TestView(state: GameState(
                initialized: true, 
                expected: DayWord(word: "holly", day: 1, locale: "en"), rows: [
                    RowModel(word: "ladle", expected: "holly", isSubmitted: true),
                ], isTallied: false, date: Date()))
        }
        
        VStack {
            Text("Test that green overrides yellow (2 rows).")
            Divider()
            KeyboardHints_TestView(state: GameState(
                initialized: true, 
                expected: DayWord(word: "fuels", day: 1, locale: "en"), rows: [
                    RowModel(word: "pales", expected: "fuels", isSubmitted: true),
                    RowModel(word: "splat", expected: "fuels", isSubmitted: true),
                ], isTallied: false, date: Date()))
        }
        
        VStack {
            Text("Test empty.")
            Divider()
            KeyboardHints_TestView(state: GameState(
                initialized: true, 
                expected: DayWord(word: "fuels", day: 1, locale: "en"), rows: [
                    RowModel(word: "crazy", expected: "fuels", isSubmitted: true)
                ], isTallied: false, date: Date()))
        }
    }
}
