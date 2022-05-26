//
//  AppStateStorage.swift
//  SimpleWordGame
//
//  Created by Janis Kirsteins on 21/05/2022.
//

import SwiftUI

// Switch typealias when ready to migrate
typealias AppStateStorage = AppStateStorageNew //AppStateStorageNew

@available(iOS 14.0, *)
typealias AppStateStorageOld = AppStorage

if #available(iOS 13.0, *) {

}

@available(iOS 13.0, *)
typealias AppStateStorageOld = AppStorageCompat

protocol CloudConflictResolver
{
    func resolve(against: Any) -> Any
}

extension Optional : CloudConflictResolver where Wrapped: CloudConflictResolver
{
    func resolve(against other: Any) -> Any {
        guard let other = other as? Optional<Wrapped> else {
            return self as Any
        }
        
        if let val = self, let other = other {
            return val.resolve(against: other)
        }
        if self != nil {
            return self as Any
        }
        if other != nil {
            return other as Any
        }
        return self as Any
    }
}

extension Stats : CloudConflictResolver
{
    func resolve(against other: Any) -> Any {
        guard let other = other as? Stats else {
            return self
        }
        if self.won > other.won { return self }
        if other.won > self.won { return other }
        if self.streak > other.streak { return self }
        if other.streak > self.streak { return other }
        if self.maxStreak > other.maxStreak { return self }
        if other.maxStreak > self.maxStreak { return other }
        return self
    }
}

extension DailyState : CloudConflictResolver
{
    func resolve(against other: Any) -> Any {
        guard let other = other as? DailyState else {
            return self
        }
        
        if self.isWon {
            return self
        }
        if other.isWon {
            return other
        }
        
        if self.isFinished {
            return self
        }
        if other.isFinished {
            return other
        }
        
        return self
    }
}

@propertyWrapper public struct AppStateStorageNew<Value: Equatable>: DynamicProperty  {
    
    @AppStorage
    var localState: Value
    
    @CloudStorage
    var remoteState: Value
    
//    let def: Value
    
    let key: String
    
    public var projectedValue: Binding<Value> {
        Binding(get: { self.wrappedValue }, set: { _setValue($0) })
    }
    
    
    public var wrappedValue: Value {
        get {
            if let local = localState as? CloudConflictResolver,
               let remote = remoteState as? CloudConflictResolver,
               let good = local.resolve(against: remote) as? Value {
                
                if remoteState != good {
                    self.remoteState = good
                }
                return good
            }

            return remoteState
        }
        nonmutating set { _setValue(newValue) }
    }
    
    private func _setValue(_ val: Value) -> Void
    {
        self.localState = val
        self.remoteState = val
    }

    public init(_ key: String, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String, Value : ExpressibleByNilLiteral
    {
        let local: AppStorage<Value> = AppStorage(wrappedValue: nil, key, store: store)
        self._localState = local
        
        let remote: CloudStorage<Value> = CloudStorage(wrappedValue: nil, key)
        self._remoteState = remote
        
        self.key = key
    }
    
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String {
        self._localState = AppStorage(wrappedValue: wrappedValue, key, store: store)
        self._remoteState = CloudStorage(wrappedValue: wrappedValue, key)
        self.key = key
    }

    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Bool {
        self._localState = AppStorage(wrappedValue: wrappedValue, key, store: store)
        self._remoteState = CloudStorage(wrappedValue: wrappedValue, key)
        self.key = key
    }
}
