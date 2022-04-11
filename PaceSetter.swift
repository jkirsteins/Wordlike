import SwiftUI

/// Protocol for determining when a turn begins/ends,
/// and if subsequent periods can form a streak or not.
///
/// An implementation can be interval-based (e.g. 10 
/// seconds - useful for debugging, to test with 
/// short turns) or day-based (the actual game behaviour)
protocol PaceSetter
{
    /// Remaining time before next period
    func remainingTtl(at now: Date) -> TimeInterval
    
    /// For checking if two periods are streak-able
    func point(_ first: Date, isInPrecedingPeriodFrom second: Date) -> Bool
    
    /// Is current period still fresh relative to given time
    func isFresh(_ stateRef: Date, at now: Date) -> Bool
    
    /// Which turn is this? Use it to find the word
    func turnIndex(at now: Date) -> Int
}

extension Calendar {
    static var gregorianUtc: Calendar {
        Calendar.gregorian(withHourOffsetFromUtc: 0)
    }
    
    static func gregorian(withHourOffsetFromUtc h: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: h * 3600)!
        return calendar
    }
}

extension Stats {
    func update(from game: GameState, with: PaceSetter) -> Stats {
        
        guard !game.isTallied else {
            return self 
        }
        
        let streakablePeriods = false
        
        let newStreak = (streakablePeriods && game.isWon ? self.streak + 1 : 0)
        
        let newDistribution: [Int] = (0..<GameState.MAX_ROWS).map {
            ix in 
            
            var result: Int 
            
            if self.guessDistribution.count > ix {
                result = self.guessDistribution[ix]
            } else {
                result = 0
            }
            
            if (ix + 1) == game.submittedRows {
                result += 1
            }
            
            return result
        }
        
        return Stats(
            played: self.played + 1, 
            won: self.won + (game.isWon ? 1 : 0), 
            maxStreak: (game.isWon ? max(newStreak, self.maxStreak) : 0),  
            streak: newStreak, 
            guessDistribution: newDistribution)
    } 
}

extension Date {
    /* Use Calendar.current because
     we want to rollover at local-timezone midnight
     not UTC */
    func startOfNextDay(in cal: Calendar) -> Date {
        return cal.nextDate(
            after: self, 
            matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
    
    func secondsUntilTheNextDay(in cal: Calendar) -> TimeInterval {
        return startOfNextDay(in: cal).timeIntervalSince(self) 
    }
}

class CalendarDailyPaceSetter : PaceSetter
{
    let cal: Calendar
    let wrapped: DailyPaceSetter
    
    init(start: Date, cal: Calendar)
    {
        self.cal = cal 
        self.wrapped = DailyPaceSetter(start: start)
    }
    
    static func current(start: Date, stateRef: Date) -> PaceSetter
    {
        return CalendarDailyPaceSetter(start: start, cal: Calendar.current)
    }
    
    func remainingTtl(at now: Date) -> TimeInterval
    {
        self.wrapped.remainingTtl(at: now, in: cal)
    }
    
    func point(_ first: Date, isInPrecedingPeriodFrom second: Date) -> Bool
    {
        self.wrapped.point(first, isInPrecedingPeriodFrom: second, using: cal)
    }
    
    func isFresh(_ stateRef: Date, at now: Date) -> Bool
    {
        self.wrapped.isFresh(stateRef, at: now, in: cal)
    }
    
    func turnIndex(at now: Date) -> Int {
        self.wrapped.turnIndex(at: now, in: cal)
    }
}

class DailyPaceSetter
{
    // global start of the game
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

class BucketPaceSetter : PaceSetter
{
    // global start of the game
    let start: Date
    
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

extension String {
    // e.g. 2016-04-14T10:44:00+0000
    func toIsoDate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from:self)!
    }
}

struct Daily_PaceSetter_InternalPreview: View {
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var remainingDailyUtc: Int = -1
    @State var remainingDailyUtcP1: Int = -1
    
    var body: some View {
        let before = "2022-03-22T23:59:59+0000".toIsoDate()
        let after = "2022-03-23T00:00:01+0000".toIsoDate()
        let after2 = "2022-03-24T00:00:01+0000".toIsoDate()
        
        let body = DailyPaceSetter(
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

struct Bucket_PaceSetter_InternalPreview: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var remainingBucket: Int = -1
    
    var body: some View {
        let start = "2022-03-22T00:00:00+0000".toIsoDate()
        let first = "2022-03-22T00:00:01+0000".toIsoDate()
        let second = "2022-03-22T00:00:19+0000".toIsoDate()
        let third = "2022-03-22T00:00:21+0000".toIsoDate()
        
        let body = BucketPaceSetter(
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

struct PaceSetter_InternalPreview_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                Daily_PaceSetter_InternalPreview()
                Bucket_PaceSetter_InternalPreview()
            }
        }.padding(24)
    }
}
