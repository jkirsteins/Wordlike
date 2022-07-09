import SwiftUI

/// We wrap a String message in a struct that is
/// always brand new (to trigger the on-change even
/// for the same message).
struct ToastMessage : Equatable {
    let id = UUID() 
    let message: LocalizedStringKey
}

/// Class to propogate messages from child views
/// to parent views that might want to show them.
///
/// This is also responsible for injecting some
/// joke messages, if a certain messages gets repeated
/// too much (e.g. button mashing)
class ToastMessageCenter : ObservableObject {
    /// Actual message that will be displayed
    @Published var message: ToastMessage? = nil
    
    /// Requested message might be overridden
    /// with an easter-egg message
    var requestedMessage: LocalizedStringKey? = nil
    
    let jokeMessages: [LocalizedStringKey] = [
        "Seriously?",
        "Sure, keep doing the same thing...",
        "I promise the outcome won't change",
        "Persistence won't pay off this time",
        "Consider doing something else",
        "What do you seek?",
        "I'll be sick from all the shaking...",
        "I promise you that is not a valid word",
        "You can do better than that",
        "There is no prize for the most clicks",
    ].shuffled()
    
    /// We want to stop showing the jokes after a timeout
    /// (i.e. only on vigorous same-message-button-mashing)
    var expireJokeAt: Date? = nil
    
    /// We want to keep a joke message around for a while, to give
    /// the user the time to read it.
    var currentJoke: LocalizedStringKey? = nil
    
    /// This triggers rollover for joke index
    var countSame: Int = 0
    
    /// This keeps incrementing to fetch the next joke (we don't grab
    /// a random joke to ensure every joke gets equal screentime)
    var jokeIndex: Int = 0
    
    func set(_ message: LocalizedStringKey) {
        defer {
            requestedMessage = message
        }
        
        let shouldExpireJoke: Bool
        if let expireJokeAt = self.expireJokeAt, expireJokeAt <= Date() {
            shouldExpireJoke = true
        } else {
            shouldExpireJoke = false
        }
        
        if !shouldExpireJoke, message == requestedMessage {
            countSame += 1
            
            expireJokeAt = Date() + 2.0
            
            if countSame % 15 == 0 {
                jokeIndex += 1
                let joke = jokeMessages[jokeIndex % jokeMessages.count] 
                currentJoke = joke
            }
        } else {
            // Reset joke state completely
            self.currentJoke = nil
            self.expireJokeAt = nil
            self.countSame = 0
        }
        
        self.message = ToastMessage(message: currentJoke ?? message)
    }
}
