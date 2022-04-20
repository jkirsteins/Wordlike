import SwiftUI

/// A turn counter that operates on a calendar, and
/// rolls over at midnight.
///
/// It should be used through
/// `CalendarDailyTurnCounter.current`
class DailyTurnCounter
{
    // Start of the turn
    let start: Date
    
    init(start: Date) {
        self.start = start
    }
    
    func diffInDays(first: Date, second: Date, cal: Calendar) -> Int {
        let firstStart = cal.startOfDay(for: first)
        let secondStart = cal.startOfDay(for: second)
        
        return cal.dateComponents([.day], from: firstStart, to: secondStart).day!
    }
    
    func point(_ first: Date, isInPrecedingPeriodFrom second: Date, using cal: Calendar) -> Bool {
        
        let diffInDays = diffInDays(
            first: first, 
            second: second, 
            cal: cal)
        
        return diffInDays == 1
    }
    
    func remainingTtl(at now: Date, in cal: Calendar) -> TimeInterval {
        now.secondsUntilTheNextDay(in: cal)
    }
    
    func turnIndex(at now: Date, in cal: Calendar) -> Int {
        return diffInDays(first: self.start, second: now, cal: cal)
    }
    
    func isFresh(_ stateRef: Date, at now: Date, in cal: Calendar) -> Bool {
        cal.isDate(now, equalTo: stateRef, toGranularity: .day)
    }
}

/// Visual tests for the daily turn counter.
struct DailyTurnCounter_InternalPreview: View {
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var remainingDailyUtc: Int = -1
    @State var remainingDailyUtcP1: Int = -1
    
    var body: some View {
        let before = "2022-03-22T23:59:59+0000".toIsoDate()
        let after = "2022-03-23T00:00:01+0000".toIsoDate()
        let after2 = "2022-03-24T00:00:01+0000".toIsoDate()
        
        let body = DailyTurnCounter(
            start: WordValidator.MAR_22_2022)
        
        let utcCal = Calendar.gregorianUtc
        let utcP1Cal = Calendar.gregorian(withHourOffsetFromUtc: 1)
        
        let isFreshBefore = body.isFresh(WordValidator.MAR_22_2022, at: before, in: utcCal)
        let isFreshBeforeP1 = body.isFresh(WordValidator.MAR_22_2022, at: before, in: utcP1Cal)
        let isFreshAfter = body.isFresh(WordValidator.MAR_22_2022, at: after, in: utcCal)
        let remainingBefore = body.remainingTtl(at: before, in: utcCal)
        let remainingBeforeP1 = body.remainingTtl(at: before, in: utcP1Cal)
        let remainingAfter = body.remainingTtl(
            at: after, in: utcCal)
        
        let beforeAfterSub = body.point(before, isInPrecedingPeriodFrom: after, using: utcCal)
        let beforeAfterSubP1 = body.point(before, isInPrecedingPeriodFrom: after, using: utcP1Cal)
        let beforeAfter2SubP1 = body.point(before, isInPrecedingPeriodFrom: after2, using: utcP1Cal)
        
        let turn0 = body.turnIndex(at: before, in: utcCal)
        let turn1P1 = body.turnIndex(at: before, in: utcP1Cal)
        let turn1 = body.turnIndex(at: after, in: utcCal)
        let turn2 = body.turnIndex(at: after2, in: utcCal)
        
        return VStack(spacing: 8) {
            Text("Daily rollover")
                .font(.largeTitle)
            
            Divider()
            
            VStack {
                Text("Remaining: \(self.remainingDailyUtc) (UTC) \(self.remainingDailyUtcP1) (UTC+1)")
                    .onReceive(timer) {
                        _ in 
                        
                        self.remainingDailyUtc = Int(body.remainingTtl(at: Date(), in: utcCal))
                        self.remainingDailyUtcP1 = Int(body.remainingTtl(at: Date(), in: utcP1Cal))
                    }
                
                Text(verbatim: "Fresh (midnight -1 sec UTC): \(isFreshBefore)")
                    .fontWeight(.bold)
                    .foregroundColor(isFreshBefore ? Color.green : Color.red)
                
                Text(verbatim: "Fresh (midnight -1 sec UTC+1): \(isFreshBeforeP1)")
                    .fontWeight(.bold)
                    .foregroundColor(isFreshBeforeP1 ? Color.red : Color.green)
                
                Text(verbatim: "Stale (+1 sec): \(!isFreshAfter)")
                    .fontWeight(.bold)
                    .foregroundColor(isFreshAfter ? Color.red : Color.green)
                
                Text(verbatim: "Remaining (midnight -1 sec UTC): \(remainingBefore)")
                    .fontWeight(.bold)
                    .foregroundColor(remainingBefore == 1 ? Color.green : Color.red)
                
                Text(verbatim: "Remaining (midnight -1 sec UTC+1): \(remainingBeforeP1)")
                    .fontWeight(.bold)
                    .foregroundColor(remainingBeforeP1 == 82801 ? Color.green : Color.red)
                
                Text(verbatim: "Remaining (24h - 1 sec): \(remainingAfter)")
                    .fontWeight(.bold)
                    .foregroundColor(remainingAfter == 86399.0 ? Color.green : Color.red)
                
                VStack {
                    Text("Sequential checks").font(.title)
                    
                    Text(verbatim: "Seq B/A UTC: \(beforeAfterSub)")
                        .fontWeight(.bold)
                        .foregroundColor(beforeAfterSub ? Color.green : Color.red)
                    
                    Text(verbatim: "Seq B/A UTC+1: \(beforeAfterSubP1)")
                        .fontWeight(.bold)
                        .foregroundColor(!beforeAfterSubP1 ? Color.green : Color.red)
                    
                    Text(verbatim: "Seq B/A2 UTC+1: \(beforeAfter2SubP1)")
                        .fontWeight(.bold)
                        .foregroundColor(beforeAfter2SubP1 ? Color.green : Color.red)
                }
                
                VStack {
                    Text("Turn counter").font(.title)
                    
                    Text(verbatim: "Turn0 UTC: \(turn0)")
                        .fontWeight(.bold)
                        .foregroundColor(turn0 == 0 ? Color.green : Color.red)
                    
                    Text(verbatim: "Turn0 UTC+1: \(turn1P1)")
                        .fontWeight(.bold)
                        .foregroundColor(turn1P1 == 1 ? Color.green : Color.red)
                    
                    Text(verbatim: "Turn1 UTC: \(turn1)")
                        .fontWeight(.bold)
                        .foregroundColor(turn1 == 1 ? Color.green : Color.red)
                    
                    Text(verbatim: "Turn2 UTC: \(turn2)")
                        .fontWeight(.bold)
                        .foregroundColor(turn2 == 2 ? Color.green : Color.red)
                }
                
            }
        }
    }
}

struct DailyTurnCounter_InternalPreviews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                DailyTurnCounter_InternalPreview()
            }
        }.padding(24)
    }
}

