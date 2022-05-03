import SwiftUI

struct InternalWordTreeTestView: View {
    var body: some View {
        TestList("WordTree tests") {
            Test(
                "Test simple insert and lookup", 
                { () -> (Bool, Bool, Bool, WordModel?, WordModel?) in
                    let w = WordTree(locale: .en_US)
                    return  (
                        w.add(word: "fuel"), 
                        w.add(word: "fuelss"),
                        w.add(word: "fuels"),
                        w.contains("fuels"),
                        w.contains("fuel")
                    )
                }) 
            { data in 
                Text(verbatim: "Failed to insert fuel: \(data.0)").testColor(good: data.0 == false)
                Text(verbatim: "Failed to insert fuelss: \(data.1)").testColor(good: data.1 == false)
                Text(verbatim: "Inserted fuels: \(data.2)").testColor(good: data.2)
                Text(verbatim: "Retrieved fuels: \(data.3?.displayValue ?? "none")").testColor(good: data.3 != nil)
                Text(verbatim: "Retrieved fuel (as a subset of fuels): \(data.4?.displayValue ?? "none")").testColor(good: data.4 != nil)
            }
            
            Test(
                "Lookup should fail if word not present", 
                { () -> (WordModel?) in
                    let w = WordTree(locale: .en_US)
                    return  (
                        w.contains("fuels")
                    )
                }) 
            { data in 
                Text(verbatim: "Retrieved fuels: \(data?.displayValue ?? "none")").testColor(good: data == nil)
            }
            
            Test(
                "Retrieved words should be unambiguous", 
                { () -> (WordModel?) in
                    let w = WordTree(locale: .lv_LV)
                    let word = WordModel(characters: [
                        MultiCharacterModel("sš", locale: .lv_LV),
                        MultiCharacterModel("v", locale: .lv_LV),
                        MultiCharacterModel("ī", locale: .lv_LV),
                        MultiCharacterModel("k", locale: .lv_LV),
                        MultiCharacterModel("a", locale: .lv_LV),
                    ])
                    var reason: String? = nil
                    let _ = w.add(word: "svīka")
                    let _ = w.add(word: "švīka")
                    let found = w.contains(
                        word: word, 
                        mustMatch: nil, 
                        reason: &reason)
                    return found
                }) 
            { data in 
                Text("Retrieved word: \(data?.displayValue ?? "none")").testColor(good: data != nil)
                Text(verbatim: "Is unambiguous: \(data?.isUnambiguous ?? false)").testColor(good: data?.isUnambiguous == true)
            }
            
            Test("Constraints - ignore unsubmitted rows", { () -> (WordModel?, String?) in
                let expected = "broth"
                let w = WordTree(locale: .en_US)
                
                let _ = w.add(word: "blobs")
                
                // Green: R
                // Yellow: B
                let model = [
                    RowModel(
                        word: 
                            WordModel("crabs", locale: w.locale), 
                        expected: 
                            WordModel(expected, locale: w.locale),
                        isSubmitted: false)
                ]
                
                var reason: String? = nil
                let found = w.contains(word: "blobs", mustMatch: model, reason: &reason)
                return (found, reason)
            }) { data in 
                Text(verbatim: "Found: \(data.0?.displayValue ?? "none")").testColor(good: data.0 != nil)
                Text(verbatim: "Reason: \(data.1 ?? "none")").testColor(good: data.1 == nil)
            }
            
            Test("Constraints - mention green ahead of yellow", { () -> (WordModel?, String?) in
                
                let w = WordTree(locale: .en_US)
                
                let _ = w.add(word: "blobs")
                
                // Green: R
                // Yellow: B
                let model = [
                    RowModel(
                        word: 
                            WordModel("crabs", locale: w.locale), 
                        expected: 
                            WordModel("broth", locale: w.locale), 
                        isSubmitted: true)
                ]
                
                var reason: String? = nil
                let found = w.contains(word: "blobs", mustMatch: model, reason: &reason)
                return (found, reason)
            }) { data in 
                Text(verbatim: "Found: \(data.0?.displayValue ?? "none" )").testColor(good: data.0 == nil)
                Text(verbatim: "Reason: \(data.1 ?? "none")").testColor(good: data.1 == "2nd letter must be L")
            }
            
            Test("Constraints - mention yellow", { () -> (WordModel?, String?) in
                
                let w = WordTree(locale: .en_US)
                
                let _ = w.add(word: "glade")
                
                // Yellow: B
                let model = [
                    RowModel(
                        word: 
                            WordModel("crabs", locale: w.locale), 
                        expected: 
                            WordModel("blood", locale: w.locale), 
                        isSubmitted: true)
                ]
                
                var reason: String? = nil
                let found = w.contains(
                    word: "glade", 
                    mustMatch: model, 
                    reason: &reason)
                return (found, reason)
            }) { data in 
                Text(verbatim: "Found: \(data.0?.displayValue ?? "none" )").testColor(good: data.0 == nil)
                Text(verbatim: "Reason: \(data.1 ?? "none")").testColor(good: data.1 == "Guess must contain B")
            }
            
            Test("Basic speed test", { () -> (
                // list lookup (success / seconds)
                (Bool, Double),
                // tree lookup 
                (Bool, Double) ) in
                
                // prepare tree
                let guesses = WordValidator.load("lv_G").map {
                    $0.uppercased()
                }
                
                let wt = WordTree(locale: .lv_LV)
                for g in guesses {
                    let _ = wt.add(word: g)
                }
                
                // prepare old validator
                let wv = WordValidator(locale: .lv_LV(simplified: false))
                
                // prepare models
                let toFind = WordModel("žagas", locale: .lv_LV)
                let expected = WordModel("agars", locale: .lv_LV)
                var reasonA: String? = nil
                var reasonB: String? = nil
                
                
                let start = Date()
                let found1 = wv.canSubmit(
                    word: toFind, 
                    expected: expected, 
                    model: nil, 
                    mustMatchKnown: true, 
                    reason: &reasonA)
                let start2 = Date()
                let found2 = wt.contains(word: toFind, mustMatch: nil, reason: &reasonB)
                let end = Date()
                
                return (
                    (found1 != nil, start2.timeIntervalSince(start)),
                    (found2 != nil, end.timeIntervalSince(start2))
                )
            }) { data in
                
                Text(verbatim: "Found (list): \(data.0.0)").testColor(good: data.0.0)
                Text(verbatim: "Found (tree): \(data.1.0)").testColor(good: data.1.0)
                Text(verbatim: "Interval (list): \(data.0.1)").testColor(good: data.0.0)
                Text(verbatim: "Interval (tree): \(data.1.1)").testColor(good: (data.1.1 < 0.0001))
                Text(verbatim: "Interval ratio (tree/list): \(data.1.1 / data.0.1)").testColor(good: data.1.1 / data.0.1 < 0.01)
            }
        }
    }
}

struct InternalWordTreeTestView_Previews: PreviewProvider {
    static var previews: some View {
        InternalWordTreeTestView()
    }
}
