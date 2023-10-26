//
//  PropertyObserver.swift
//  PropertyObserver
//
//  Created by LC on 2023/10/17.
//  Copyright © 2023 PropertyObserver. All rights reserved.
//

import Foundation
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
    
    struct Observer<Value> {
        weak var observer: AnyObject?
        let block: (_ oldValue: Value, _ newValue: Value) -> Void
    }
    
    private var observers = [Observer<Value>]()
    
    fileprivate var value: Value {
        didSet { notifyObservers(oldValue: oldValue) }
    }
    
    public init(_ value: Value) {
        self.value = value
    }
    
    /// 添加观察者
    /// - Parameters:
    ///   - observer: 观察对象
    ///   - using: 属性值改变回调 ($0:旧值, $0:新值)
    public func addObserver(on observer: AnyObject, using: @escaping (Value, Value) -> Void) {
        // remove invalid observer before adding new ones
        observers = observers.filter { $0.observer != nil }
        observers.append(Observer(observer: observer, block: using))
        using(value, value)
    }
    
    /// 先移除之前所有的观察者然后再添加观察者
    /// - Parameters:
    ///   - observer: 观察对象
    ///   - using: 属性值改变回调 ($0:旧值, $0:新值)
    public func setObserver(on observer: AnyObject, using: @escaping (Value, Value) -> Void) {
        observers = [Observer(observer: observer, block: using)]
        using(value, value)
    }

    /// 移除指定对象上的观察者
    /// - Parameter observer: 观察对象
    public func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
    
    /// 移除所有观察者
    public func removeObservers() {
        observers.removeAll()
    }
    
    private func notifyObservers(oldValue: Value) {
        for observer in observers {
            DispatchQueue.main.async { observer.block(oldValue, self.value) }
        }
    }
    
}
