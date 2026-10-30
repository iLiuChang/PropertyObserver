//
//  PropertyObserver.swift
//  PropertyObserver
//
//  Created by LC on 2023/10/17.
//  Copyright © 2023 PropertyObserver. All rights reserved.
//

@propertyWrapper
public struct PropertyObservable<Value> {
    private var observable: PropertyObserver<Value>
    
    public var wrappedValue: Value {
        get {
            return observable.value
        }
        set {
            observable.value = newValue
        }
    }
    
    public init(wrappedValue: Value) {
        observable = .init(wrappedValue)
    }
    
    public init(initialValue: Value) {
        observable = .init(initialValue)
    }
    
    public var projectedValue: PropertyObserver<Value> { observable }
}

public final class PropertyObserver<Value> {

    private struct Observer {
        weak var owner: AnyObject?
        let id: Int
        let block: (Value, Value) -> Void
    }

    private var observers = [Observer]()
    private var nextObserverID = 0

    fileprivate var value: Value {
        didSet { notifyObservers(oldValue: oldValue) }
    }

    public init(_ value: Value) {
        self.value = value
    }

    /// Adds a subscription and delivers the current value on the caller's thread.
    ///
    /// The first callback receives the current value for both arguments.
    /// Later callbacks run on the thread that assigned the new value, with the old and new values from that assignment.
    /// The subscription ends when `observer` is released.
    /// Capture `observer` weakly in `using` to avoid a retain cycle.
    /// - Parameters:
    ///   - observer: Object that owns the subscription.
    ///   - using: Called as `(oldValue, newValue)`.
    public func addObserver(on observer: AnyObject, using: @escaping (Value, Value) -> Void) {
        purgeInvalidObservers()
        let entry = makeObserver(owner: observer, block: using)
        observers.append(entry)
        invoke(entry, oldValue: value, newValue: value)
    }

    /// Removes all subscriptions, then adds one and delivers the current value on the caller's thread.
    ///
    /// Capture `observer` weakly in `using` to avoid a retain cycle.
    /// - Parameters:
    ///   - observer: Object that owns the subscription.
    ///   - using: Called as `(oldValue, newValue)`.
    public func setObserver(on observer: AnyObject, using: @escaping (Value, Value) -> Void) {
        let entry = makeObserver(owner: observer, block: using)
        observers = [entry]
        invoke(entry, oldValue: value, newValue: value)
    }

    /// Removes subscriptions owned by `observer`.
    /// - Parameter observer: Object that owns the subscriptions.
    public func remove(observer: AnyObject) {
        observers.removeAll { $0.owner == nil || $0.owner === observer }
    }

    /// Removes all subscriptions.
    public func removeObservers() {
        observers.removeAll()
    }

    private func makeObserver(owner: AnyObject, block: @escaping (Value, Value) -> Void) -> Observer {
        let entry = Observer(owner: owner, id: nextObserverID, block: block)
        nextObserverID += 1
        return entry
    }

    private func purgeInvalidObservers() {
        observers.removeAll { $0.owner == nil }
    }

    private func notifyObservers(oldValue: Value) {
        let newValue = value
        purgeInvalidObservers()
        let snapshot = observers
        for entry in snapshot {
            invoke(entry, oldValue: oldValue, newValue: newValue)
        }
    }

    /// Invokes the callback on the current thread when the subscription is still active.
    private func invoke(_ entry: Observer, oldValue: Value, newValue: Value) {
        guard let current = observers.first(where: { $0.id == entry.id }),
              current.owner != nil else { return }
        current.block(oldValue, newValue)
    }

}
