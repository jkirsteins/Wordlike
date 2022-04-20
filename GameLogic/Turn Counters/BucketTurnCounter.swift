import SwiftUI

/// Turn counter that is useful when debugging.
///
/// Each turn is a given number of seconds (`bucket`) long.
class BucketTurnCounter : TurnCounter
{
    /// Start of the turn 
    let start: Date
    
    /// Length of each turn
    let bucket: TimeInterval
    
    init(start: Date, bucket: TimeInterval) {
        self.start = start
        self.bucket = bucket
    }
    
    func remainingTtl(at now: Date) -> TimeInterval {
        return nextRollover(from: now).timeIntervalSince(now)
    }
    
    func point(_ first: Date, isInPrecedingPeriodFrom second: Date) -> Bool {
        
        let openBorder = nextRollover(from: first)
        let closeBorder = openBorder + bucket
        return (openBorder < second) && (second < closeBorder)
    }
    
    func nextRollover(from now: Date) -> Date {
        var nextStop: Date = self.start
        while (nextStop < now) {
            nextStop = nextStop.addingTimeInterval(bucket)
        }
        return nextStop
    }
    
    func turnIndex(at now: Date) -> Int {
        var result = 0
        var nextStop: Date = self.start
        while (nextStop < now) {
            nextStop = nextStop.addingTimeInterval(bucket)
            result += 1
        }
        return result - 1
    }
    
    func isFresh(_ stateRef: Date, at now: Date) -> Bool {
        nextRollover(from: now).timeIntervalSince(stateRef) <= bucket
    }
}

struct BucketTurnCounter_InternalPreview: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var remainingBucket: Int = -1
    
    var body: some View {
        let start = "2022-03-22T00:00:00+0000".toIsoDate()
        let first = "2022-03-22T00:00:01+0000".toIsoDate()
        let second = "2022-03-22T00:00:19+0000".toIsoDate()
        let third = "2022-03-22T00:00:21+0000".toIsoDate()
        
        let body = BucketTurnCounter(
            start: start,
            bucket: 10.0
        )
        
        let isFreshBefore = body.isFresh(start, at: first)
        let isFreshAfter = body.isFresh(start, at: second)
        let remainingFirst = body.remainingTtl(at: first)
        let remainingSecond = body.remainingTtl(at: second)
        
        let firstSecondSeq = body.point(first, isInPrecedingPeriodFrom: second)
        let firstThirdSeq = body.point(first, isInPrecedingPeriodFrom: third)
        let secondThirdSeq = body.point(second, isInPrecedingPeriodFrom: third)
        
        let turnIx1 = body.turnIndex(at: first)
        let turnIx2 = body.turnIndex(at: second)
        let turnIx3 = body.turnIndex(at: third)
        
        return VStack(spacing: 8) {
            Text("Bucket rollover")
                .font(.largeTitle)
            
            Divider()
            
            VStack {
                Text("TTL: \(self.remainingBucket)")
                    .onReceive(timer) {
                        _ in 
                        
                        self.remainingBucket = Int(body.remainingTtl(at: Date()))
                    }
                
                Text(verbatim: "Fresh (-1 sec): \(isFreshBefore)")
                    .fontWeight(.bold)
                    .foregroundColor(isFreshBefore ? Color.green : Color.red)
                
                Text(verbatim: "Stale (+1 sec): \(!isFreshAfter)")
                    .fontWeight(.bold)
                    .foregroundColor(isFreshAfter ? Color.red : Color.green)
                
                Text(verbatim: "Remaining (9 sec): \(remainingFirst)")
                    .fontWeight(.bold)
                    .foregroundColor(remainingFirst == 9 ? Color.green : Color.red)
                
                Text(verbatim: "Remaining (1 sec): \(remainingSecond)")
                    .fontWeight(.bold)
                    .foregroundColor(remainingSecond == 1 ? Color.green : Color.red)
                
                Text(verbatim: "1/2 seq: \(firstSecondSeq)")
                    .fontWeight(.bold)
                    .foregroundColor(firstSecondSeq ? Color.green : Color.red)
                
                Text(verbatim: "1/3 seq: \(firstThirdSeq)")
                    .fontWeight(.bold)
                    .foregroundColor(!firstThirdSeq ? Color.green : Color.red)
                
                Text(verbatim: "2/3 seq: \(secondThirdSeq)")
                    .fontWeight(.bold)
                    .foregroundColor(secondThirdSeq ? Color.green : Color.red)
                
                Text(verbatim: "TurnIx 0: \(turnIx1)")
                    .fontWeight(.bold)
                    .foregroundColor(turnIx1 == 0 ? Color.green : Color.red)
                
                VStack {
                    Text(verbatim: "TurnIx 1: \(turnIx2)")
                        .fontWeight(.bold)
                        .foregroundColor(turnIx2 == 1 ? Color.green : Color.red)
                    
                    Text(verbatim: "TurnIx 2: \(turnIx3)")
                        .fontWeight(.bold)
                        .foregroundColor(turnIx3 == 2 ? Color.green : Color.red)
                }
                
            }
        }
    }
}
