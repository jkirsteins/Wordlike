import SwiftUI

protocol PaceSetter
{
    
}

extension Calendar {
    static var gregorianUtc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
}

extension Date {
    var startOfNextDay: Date {
        return Calendar.gregorianUtc.nextDate(
            after: self, 
            matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
    var secondsUntilTheNextDay: TimeInterval {
        return startOfNextDay.timeIntervalSince(self) 
    }
}

class DailyPaceSetter : PaceSetter
{
    // global start of the game
    let start: Date
    
    // state's point-in-time
    let stateRef: Date
    
    init(start: Date, stateRef: Date) {
        self.start = start
        self.stateRef = stateRef
    }
    
    func remainingTtl(at now: Date) -> TimeInterval {
        now.secondsUntilTheNextDay
    }
    
    func isFresh(at now: Date) -> Bool {
        Calendar.gregorianUtc.isDate(now, equalTo: self.stateRef, toGranularity: .day)
    }
}

class BucketPaceSetter : PaceSetter
{
    // global start of the game
    let start: Date
    
    // state's point-in-time
    let stateRef: Date
    
    let bucket: TimeInterval
    
    init(start: Date, stateRef: Date, bucket: TimeInterval) {
        self.start = start
        self.stateRef = stateRef
        self.bucket = bucket
    }
    
    func remainingTtl(at now: Date) -> TimeInterval {
        return nextRollover(from: now).timeIntervalSince(now)
    }
    
    func nextRollover(from now: Date) -> Date {
        var nextStop: Date = self.start
        while (nextStop < now) {
            nextStop = nextStop.addingTimeInterval(bucket)
        }
        return nextStop
    }
    
    func isFresh(at now: Date) -> Bool {
        now.timeIntervalSince(self.stateRef) < bucket
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
    var body: some View {
        let before = "2022-03-22T23:59:59+0000".toIsoDate()
        let after = "2022-03-23T00:00:01+0000".toIsoDate()
        
        let body = DailyPaceSetter(
            start: WordValidator.MAR_22_2022,
            stateRef: WordValidator.MAR_22_2022)
        
        let isFreshBefore = body.isFresh(at: before)
        let isFreshAfter = body.isFresh(at: after)
        let remainingBefore = body.remainingTtl(at: before)
        let remainingAfter = body.remainingTtl(at: after)
        
        return VStack(spacing: 8) {
            Text("Daily rollover")
                .font(.largeTitle)
            Divider()
            
            VStack {
                Text(verbatim: "Fresh (-1 sec): \(isFreshBefore)")
                    .fontWeight(.bold)
                    .foregroundColor(isFreshBefore ? Color.green : Color.red)
                
                Text(verbatim: "Stale (+1 sec): \(!isFreshAfter)")
                    .fontWeight(.bold)
                    .foregroundColor(isFreshAfter ? Color.red : Color.green)
                
                Text(verbatim: "Remaining (1 sec): \(remainingBefore)")
                    .fontWeight(.bold)
                    .foregroundColor(remainingBefore == 1 ? Color.green : Color.red)
                
                Text(verbatim: "Remaining (24h - 1 sec): \(remainingAfter)")
                    .fontWeight(.bold)
                    .foregroundColor(remainingAfter == 86399.0 ? Color.green : Color.red)
                
            }
        }
    }
}

struct Bucket_PaceSetter_InternalPreview: View {
    var body: some View {
        let start = "2022-03-22T00:00:00+0000".toIsoDate()
        let first = "2022-03-22T00:00:01+0000".toIsoDate()
        let second = "2022-03-22T00:00:19+0000".toIsoDate()
        
        let body = BucketPaceSetter(
            start: start,
            stateRef: start,
            bucket: 10.0
        )
        
        let isFreshBefore = body.isFresh(at: first)
        let isFreshAfter = body.isFresh(at: second)
        let remainingFirst = body.remainingTtl(at: first)
        let remainingSecond = body.remainingTtl(at: second)
        
        return VStack(spacing: 8) {
            Text("Bucket rollover")
                .font(.largeTitle)
            Divider()
            
            VStack {
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
                
            }
        }
    }
}

struct PaceSetter_InternalPreview_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            Daily_PaceSetter_InternalPreview()
            Bucket_PaceSetter_InternalPreview()
        }
    }
}
