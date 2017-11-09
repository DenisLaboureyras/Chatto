//
//  ReadOnlyOrderedDictionary.swift
//  Pods
//
//  Created by Denis Laboureyras on 27/05/2016.
//
//

import Foundation

public struct ReadOnlyOrderedDictionary<T>: Collection where T: UniqueIdentificable {
   

    
    fileprivate let items: [T]
    fileprivate let itemIndexesById: [String: Int] // Maping to the position in the array instead the item itself for better performance
    
    public init(items: [T]) {
        var dictionary = [String: Int](minimumCapacity: items.count)
        for (index, item) in items.enumerated() {
            dictionary[item.uid] = index
        }
        self.items = items
        self.itemIndexesById = dictionary
    }
    
    public func indexOf(_ uid: String) -> Int? {
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
    
    public func makeIterator() -> IndexingIterator<[T]> {
        return self.items.makeIterator()
    }
    
    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return self.items.index(i, offsetBy: n)
    }
    
    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        return self.items.index(i, offsetBy: n, limitedBy: limit)
    }
    
    public func index(after i: Int) -> Int {
        return self.items.index(after: i)
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return self.items.count
    }
}

public struct ReadOnlyOrderedSectionedDictionary<T>: Collection where T: ChatSectionProtocol {
    
    
    fileprivate let items: [T]
    fileprivate let itemIndexesById: [String: Int] // Maping to the position in the array instead the item itself for better performance
    
    public init(items: [T]) {
        var dictionary = [String: Int](minimumCapacity: items.count)
        for (index, item) in items.enumerated() {
            dictionary[item.uid] = index
        }
        self.items = items
        self.itemIndexesById = dictionary
    }
    
    public func indexOf(_ uid: String) -> Int? {
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
    
    public func makeIterator() -> IndexingIterator<[T]> {
        return self.items.makeIterator()
    }
    
    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return self.items.index(i, offsetBy: n)
    }
    
    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        return self.items.index(i, offsetBy: n, limitedBy: limit)
    }
    
    public func index(after i: Int) -> Int {
        return self.items.index(after: i)
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return self.items.count
    }
}
