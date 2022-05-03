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
                Text(verbatim: "Reason: \(data.1 ?? "none")").testColor(good: data.1 == "2nd letter must be R")
            }
            
            Test("Constraints - keep the deepest constraint message", { () -> (WordModel?, String?) in 
                
                let w = WordTree(locale: .lv_LV)
                
                let _ = w.add(word: "soļot")
                let _ = w.add(word: "šauju")
                let _ = w.add(word: "sauju")
                
                let model = [
                    RowModel(
                        word: 
                            WordModel("solis", locale: w.locale), 
                        expected: 
                            WordModel("soļot", locale: w.locale), 
                        isSubmitted: true),
                    RowModel(
                        word: 
                            WordModel("pļauj", locale: w.locale), 
                        expected: 
                            WordModel("soļot", locale: w.locale), 
                        isSubmitted: true),
                ]
                
                let trySubmit = WordModel(characters: [
                    MultiCharacterModel("SŠ", locale: w.locale),
                    MultiCharacterModel("A", locale: w.locale),
                    MultiCharacterModel("U", locale: w.locale),
                    MultiCharacterModel("J", locale: w.locale),
                    MultiCharacterModel("U", locale: w.locale),
                ])
                
                var reason: String? = nil
                let found = w.contains(
                    word: trySubmit, 
                    mustMatch: model, 
                    reason: &reason)
                return (found, reason)
            }) { data in 
                Text(verbatim: "Found: \(data.0?.displayValue ?? "none" )").testColor(good: data.0 == nil)
                Text(verbatim: "Reason: \(data.1 ?? "none")")
                    .testColor(good: data.1 == "2nd letter must be O")
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
            
            /// Test the speed of the lookup to notice
            /// regressions (and historically, it was
            /// helpful to compare with a naive list lookup)
            Test("Basic speed test", { () -> 
                // success / seconds
                (Bool, Double)
                in
                
                // prepare tree
                let wt: WordTree = WordValidator.loadGuessTree(locale: .lv_LV(simplified: false))
                
                // prepare models
                let toFind = WordModel("žagas", locale: .lv_LV)
                var reason: String? = nil
                
                let start = Date()
                let found = wt.contains(word: toFind, mustMatch: nil, reason: &reason)
                let end = Date()
                
                return (
                    found != nil,  end.timeIntervalSince(start)
                )
            }) { data in
                
                Text(verbatim: "Found (tree): \(data.0)").testColor(good: data.0)
                Text(verbatim: "Interval (tree): \(data.1)").testColor(good: (data.1 < 0.00025))
            }
        }
    }
}

struct InternalWordTreeTestView_Previews: PreviewProvider {
    static var previews: some View {
        InternalWordTreeTestView()
    }
}
