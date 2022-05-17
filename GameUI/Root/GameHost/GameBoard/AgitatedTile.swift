import SwiftUI
import Combine 

/// A tile that will move occasionally on its own. FUN!
struct AgitatedTile: View {
    @State var type: TileBackgroundType
    @State var flipped: TileModel? = nil
    @State var jumping: Bool = false
    
    let letter: String
    let fixedType: Bool 
    let jumpDuration: TimeInterval = Row.JUMP_DURATION
    let flipDuration: TimeInterval = Row.FLIP_DURATION
    
    let timer: Publishers.Delay<Publishers.Autoconnect<Timer.TimerPublisher>, DispatchQueue>?
    let secs: TimeInterval?
    @State var delayedUntil: Date? = nil
    
    init(model: TileModel) {
        self.letter = model.letter
        self.secs = nil
        self.timer = nil
        self.fixedType = true // stick to given type
        
        self._type = State(wrappedValue: model.state)
    }
    
    init(_ letter: String, secs: TimeInterval? = 5.0) {
        self.letter = letter
        self.secs = secs 
        self.fixedType = false // allow randomizing type
        self._type = State(wrappedValue: .random)
        
        if let secs = secs {
            let it = Timer.publish(
                every: secs, 
                on: .main, 
                in: .common)
                .autoconnect()
            
            // Stagger potential actions a bit
            let delay: DispatchQueue.SchedulerTimeType.Stride = .seconds(10*drand48())
            
            self.timer = it
                .delay(for: delay, scheduler: DispatchQueue.main)
        } else {
            self.timer = nil
        }
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
                duration: flipDuration + drand48() * 0.2,
                jumpDuration: jumpDuration)
            
            if let timer = timer {
                EmptyView().onReceive(timer) { received in
                    applyEffect(0.1)
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
        .onTapGesture {
            applyEffect(1.0, ignoreDelay: true)
        }
    }
    
    func applyEffect(_ ratio: Double = 1.0, ignoreDelay: Bool = false) {
        let now = Date()
        if 
            !ignoreDelay,
            let delayedUntil = delayedUntil, 
                now < delayedUntil 
        {
            return
        }
        
        let r = drand48() / ratio 
        
        if fixedType || r < 0.5 {
            jumping = true
        } else if !fixedType && r < 1 {
            flipped = TileModel(letter: letter, state: TileBackgroundType.random(not: type))
        }
        
        if let secs = secs {
            delayedUntil = Date().addingTimeInterval(secs)
        }
    }
}

struct RandomFlippingTile_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HStack {
                AgitatedTile("H", secs: nil)
                AgitatedTile("E")
                AgitatedTile("L")
                AgitatedTile("L")
                AgitatedTile("O")
            }
        }
    }
}
