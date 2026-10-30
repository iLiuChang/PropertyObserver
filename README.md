# PropertyObserver

![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-lightgrey.svg)
![Version](https://img.shields.io/badge/Version-2.0.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-supported-blueviolet.svg)

## Overview

A property observer for Swift. Mark a property with `@PropertyObservable` and subscribe through its projected value:

- **Current value** — a new subscription receives the current value immediately
- **Changes** — later assignments call the same closure with the previous value and the value from that assignment
- **Caller thread** — the closure runs synchronously on the thread that subscribed or assigned the property

## Features

- **Property Wrapper** — observe a stored property without a separate publisher
- **Multiple Subscribers** — more than one object can observe the same property
- **Replace Subscribers** — `setObserver` removes every existing subscription, then adds one
- **Lifetime** — a subscription ends when its owner is released
- **Caller Thread** — callbacks stay on the thread that triggered them

## Requirements

- iOS 12.0+
- macOS 10.13+
- tvOS 12.0+
- watchOS 4.0+
- Mac Catalyst 13.0+
- visionOS 1.0+
- Swift 5.9+

## Installation

### CocoaPods

```ruby
pod 'PropertyObserver'
```

Then run:

```bash
pod install
```

### Swift Package Manager

In Xcode: **File → Add Packages…** and enter:

```
https://github.com/iLiuChang/PropertyObserver.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iLiuChang/PropertyObserver.git", from: "2.0.0")
]
```

### Manual

1. Download the files in the `Sources` folder
2. Drag them into your Xcode project

## Usage

Declare the property on a class. The wrapper stores a reference type, so use it on a class rather than a struct.

```swift
import PropertyObserver

final class User {
    @PropertyObservable var name = ""
}
```

Subscribe with the projected value. The first call receives the current value for both arguments. Capture the owner weakly so the subscription can end when the owner is released.

```swift
final class NameLabel {
    var text = ""

    func bind(_ user: User) {
        user.$name.addObserver(on: self) { [weak self] _, newValue in
            self?.text = newValue
        }
    }
}
```

Assigning the property notifies every active subscription on the assigning thread:

```swift
user.name = "Leo"
```

The closure above is called as `("", "Leo")`.

### Replace Every Subscription

`setObserver` removes all existing subscriptions, then adds this one and delivers the current value:

```swift
user.$name.setObserver(on: self) { [weak self] _, newValue in
    self?.text = newValue
}
```

### Remove

```swift
user.$name.remove(observer: self)
user.$name.removeObservers()
```

## API Reference

### PropertyObservable

Access the observer through the property's projected value: `$name`.

| Property | Description |
|---|---|
| `wrappedValue` | The stored value. Assigning it notifies observers. |
| `projectedValue` | The `PropertyObserver` for this property. |

### PropertyObserver

| Method | Description |
|---|---|
| `addObserver(on:using:)` | Adds a subscription and delivers the current value on the caller's thread. Both arguments of that first call are the current value. Later calls receive the old and new values from one assignment and run on the thread that assigned the property. |
| `setObserver(on:using:)` | Removes every subscription, then adds one and delivers the current value on the caller's thread. |
| `remove(observer:)` | Removes the subscriptions owned by that object. |
| `removeObservers()` | Removes all subscriptions. |

`using` is called as `(oldValue, newValue)`. The same owner can hold more than one subscription. `remove(observer:)` removes all of them.

## Architecture

`PropertyObservable` is a struct that owns one `PropertyObserver` class. Copies of a wrapping struct share that class, which is why the wrapper belongs on a class.

Assigning `wrappedValue` stores the new value and calls each subscription synchronously. The closure receives the value from before that assignment and the value written by it. The owner's reference is weak. When the owner is released, later assignments skip that subscription.

Each subscription has its own identity. If a callback removes the current subscriptions and adds new ones, the rest of that notification still refers to the subscriptions that existed when the assignment happened. A subscription created inside the callback does not receive that in-flight change. It has already received the current value from `addObserver` or `setObserver`.

## License

MIT License. See [LICENSE](LICENSE) for details.
