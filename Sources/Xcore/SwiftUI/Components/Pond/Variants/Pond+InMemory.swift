//
// Xcore
// Copyright © 2021 Xcore
// MIT license, see LICENSE file for details
//

import Foundation

public struct InMemoryPond: Pond {
    private var storage = MutableBox<[String: Any]>([:])
    public let id = "inMemory"

    public init() {}

    public func get<T>(_ type: T.Type, _ key: Key) -> T? {
        switch T.self {
            case is Data.Type, is Optional<Data>.Type:
                return storage[key.id] as? T
            default:
                if Mirror.isCollection(T.self) {
                    return storage[key.id] as? T
                } else {
                    return StringConverter(storage[key.id])?.get(type)
                }
        }
    }

    public func set<T>(_ key: Key, value: T?) {
        if value == nil {
            remove(key)
        } else if let value = value as? Data {
            storage[key.id] = value
        } else if let value = StringConverter(value)?.get(String.self) {
            storage[key.id] = value
        } else if let value = value, Mirror.isCollection(value) {
            storage[key.id] = value
        } else {
            #if DEBUG
            fatalError("Unable to save value for \(key.id): \(String(describing: value))")
            #endif
        }
    }

    public func remove(_ key: Key) {
        storage[key.id] = nil
    }

    public func contains(_ key: Key) -> Bool {
        storage.keys.contains(key.id)
    }

    public func removeAll() {
        storage.value.removeAll()
    }
}

// MARK: - Dot Syntax Support

extension Pond where Self == InMemoryPond {
    /// Returns inMemory variant of `Pond`.
    public static var inMemory: Self { .init() }
}
