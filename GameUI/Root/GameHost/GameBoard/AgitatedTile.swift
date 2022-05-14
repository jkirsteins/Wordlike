import SwiftUI
import Combine 

/// A tile that will move occasionally on its own. FUN!
struct AgitatedTile: View {
    @State var type: TileBackgroundType = .random 
    @State var flipped: TileModel? = nil
    @State var jumping: Bool = false
    
    let letter: String
    
    let timer: Publishers.Delay<Publishers.Autoconnect<Timer.TimerPublisher>, DispatchQueue>
    
    init(_ letter: String, secs: TimeInterval = 5.0) {
        self.letter = letter
        
        let it = Timer.publish(
            every: secs, 
            on: .main, 
            in: .common)
            .autoconnect()
        
        // Stagger potential actions a bit
        let delay: DispatchQueue.SchedulerTimeType.Stride = .seconds(10*drand48())
        
        self.timer = it
            .delay(for: delay, scheduler: DispatchQueue.main)
    }
    
    var body: some View {
        VStack {
            FlippableTile(
                letter: TileModel(
                    letter: letter,
                    state: type), 
                flipped: flipped, 
                tag: 0, 
                jumpIx: jumping ? 0 : nil, 
                midCallback: { }, 
                flipCallback: { 
                    guard let flipped = flipped else {
                        return
                    }
                    
                    type = flipped.state
                    self.flipped = nil
                }, 
                jumpCallback: { _ in 
                    jumping = false
                },
                duration: 1.5,
                jumpDuration: 1.5)
            
            EmptyView().onReceive(timer) { received in
                let r = drand48()
                
                if r < 0.05 {
                    jumping = true
                } else if r < 0.1 {
                    flipped = TileModel(letter: letter, state: TileBackgroundType.random(not: type))
                }
            }
        }.onAppear {
            // Reset after transitions (otherwise
            // we might get stuck in an infinished,
            // half-rotated state)
            flipped = nil
        }
        .onDisappear {
            
        }
    }
}

struct RandomFlippingTile_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack {
                AgitatedTile("H")
                AgitatedTile("E")
                AgitatedTile("L")
                AgitatedTile("L")
                AgitatedTile("O")
                
            }
        }
    }
}
