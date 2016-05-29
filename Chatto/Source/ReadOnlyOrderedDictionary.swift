//
//  ReadOnlyOrderedDictionary.swift
//  Pods
//
//  Created by Denis Laboureyras on 27/05/2016.
//
//

import Foundation

public struct ReadOnlyOrderedDictionary<T where T: UniqueIdentificable>: CollectionType {
    
    private let items: [T]
    private let itemIndexesById: [String: Int] // Maping to the position in the array instead the item itself for better performance
    
    public init(items: [T]) {
        var dictionary = [String: Int](minimumCapacity: items.count)
        for (index, item) in items.enumerate() {
            dictionary[item.uid] = index
        }
        self.items = items
        self.itemIndexesById = dictionary
    }
    
    public func indexOf(uid: String) -> Int? {
        return self.itemIndexesById[uid]
    }
    
    public subscript(index: Int) -> T {
        return self.items[index]
    }
    
    public subscript(uid: String) -> T? {
        if let index = self.indexOf(uid) {
            return self.items[index]
        }
        return nil
    }
    
    public func generate() -> AnyGenerator<T> {
        var index = 0
        
        return AnyGenerator(body: {
            guard index < self.items.count else {
                return nil
            }
            
            defer { index += 1 }
            return self.items[index]
        })
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return self.items.count
    }
}

public struct ReadOnlyOrderedSectionedDictionary<T where T: ChatSectionProtocol>: CollectionType {
    
    private let items: [T]
    private let itemIndexesById: [String: Int] // Maping to the position in the array instead the item itself for better performance
    
    public init(items: [T]) {
        var dictionary = [String: Int](minimumCapacity: items.count)
        for (index, item) in items.enumerate() {
            dictionary[item.uid] = index
        }
        self.items = items
        self.itemIndexesById = dictionary
    }
    
    public func indexOf(uid: String) -> Int? {
        return self.itemIndexesById[uid]
    }
    
    public subscript(index: Int) -> T {
        return self.items[index]
    }
    
    public subscript(uid: String) -> T? {
        if let index = self.indexOf(uid) {
            return self.items[index]
        }
        return nil
    }
    
    public func generate() -> AnyGenerator<T> {
        var index = 0
        
        return AnyGenerator(body: {
            guard index < self.items.count else {
                return nil
            }
            
            defer { index += 1 }
            return self.items[index]
        })
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return self.items.count
    }
}
