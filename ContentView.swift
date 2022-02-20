import SwiftUI
import UniformTypeIdentifiers 

struct Draggable : View {
    var body: some View {
        Rectangle()
            .fill(.green)
            .frame(maxWidth: 100, maxHeight: 100)
            .onDrag {
                NSItemProvider(contentsOf: URL(string: "http://example.com")!)!
            }
    }
}

class TileDropDelegate : DropDelegate
{
    var canAccept: Bool = false
    var markBusy: (()->()) = { }
    
    init(canAccept: Bool, markBusy: @escaping ()->()) {
        self.canAccept = canAccept
        self.markBusy = markBusy
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        canAccept
    }
    
    func dropEntered(info: DropInfo) {
        print("Entered")
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        // By this you inform user that something will be just relocated
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        print("Performing")
        
        _ = info.itemProviders(for: [UTType.url])
        
        markBusy()
        
        return true
    }
}

struct DragTarget : View {
    
    @State var row: Int 
    @State var col: Int
    @ObservedObject var delegate: MyDropDelegate
    
    var body: some View {
        let isTaken = delegate.isTaken(row, col)
        
        let innerDelegate = TileDropDelegate(canAccept: !isTaken, markBusy: {
            delegate.markBusy(row, col)
        })
        
        return ZStack {
            if isTaken {
                Rectangle()
                    .fill(.red)
                Text(verbatim: "Taken")
            } else {
                Rectangle()
                    .fill(.yellow)
                Text(verbatim: "Drag here")
            }
        }
        .frame(maxWidth: 100, maxHeight: 100)
        .aspectRatio(1.0, contentMode: .fit)
        .onDrop(
            of: [UTType.url],
            delegate: innerDelegate
        )
    }
}

class MyDropDelegate : DropDelegate, ObservableObject
{
    @Published var count = 0
    
    @Published var state = [
        [false, false, false, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false],
        [false, false, false, false, false]
    ]
    
    func canAccept(_ x: Int, _ y: Int) -> Bool {
        !self.isTaken(x, y)
    } 
    
    func isTaken(_ x: Int, _ y: Int) -> Bool {
        let myState = state
        let row = myState.count > y ? myState[y] : []
        let col = row.count > x ? row[x] : false
        return col
    }
    
    func markBusy(_ x: Int, _ y: Int) {
        print("Mark busy")
        guard state.count > y, state[y].count > x else {
            return
        }
        state[y][x] = true
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        true
    }
    
    func dropEntered(info: DropInfo) {
        print("Entered")
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        // By this you inform user that something will be just relocated
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        print("Performing")
        self.count += 1 
        
        let items = info.itemProviders(for: [UTType.url])
        
        return true
    }
}

struct RowOld: View {
    @State var row: Int
    @ObservedObject var delegate: MyDropDelegate
    
    var body: some View {
        HStack {
            ForEach(0..<5) {
                DragTarget(row: self.row, col: $0, delegate: delegate)
            }
        }
    }
}

struct Rows: View {
    @StateObject var delegate = MyDropDelegate()
    
    var body: some View {
        VStack {
            ForEach(0..<6) {
                RowOld(row: $0, delegate: delegate)
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Draggable()
            
            Rows()
        }
    }
}
