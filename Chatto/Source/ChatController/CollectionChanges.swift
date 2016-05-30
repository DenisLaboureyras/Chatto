/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import Foundation

public protocol UniqueIdentificable {
    var uid: String { get }
}

public struct SectionChangeMove: Equatable, Hashable {
    public let indexOld: Int
    public let indexNew: Int
    public init(indexOld: Int, indexNew: Int) {
        self.indexOld = indexOld
        self.indexNew = indexNew
    }
    
    public var hashValue: Int { return indexOld ^ indexNew }
    
    func description() -> String {
        return "move section: \(indexOld) to section: \(indexNew)"
    }
}

public func == (lhs: SectionChangeMove, rhs: SectionChangeMove) -> Bool {
    return lhs.indexOld == rhs.indexOld && lhs.indexNew == rhs.indexNew
}

public struct CollectionChangeMove: Equatable, Hashable {
    public let indexPathOld: NSIndexPath
    public let indexPathNew: NSIndexPath
    public init(indexPathOld: NSIndexPath, indexPathNew: NSIndexPath) {
        self.indexPathOld = indexPathOld
        self.indexPathNew = indexPathNew
    }

    public var hashValue: Int { return indexPathOld.hash ^ indexPathNew.hash }
    
    func description() -> String {
        return "move section: \(indexPathOld.section) row : \(indexPathOld.row) to section: \(indexPathNew.section) row : \(indexPathNew.row) "
    }
}

public func == (lhs: CollectionChangeMove, rhs: CollectionChangeMove) -> Bool {
    return lhs.indexPathOld == rhs.indexPathOld && lhs.indexPathNew == rhs.indexPathNew
}

public struct CollectionChanges {
    public let insertedIndexSections: NSIndexSet
    public let deletedIndexSections: NSIndexSet
    public let movedIndexSections: [SectionChangeMove]
    public let insertedIndexPaths: Set<NSIndexPath>
    public let deletedIndexPaths: Set<NSIndexPath>
    public let movedIndexPaths: [CollectionChangeMove]

    init(
        insertedIndexSections: NSIndexSet,
        deletedIndexSections: NSIndexSet,
        movedIndexSections: [SectionChangeMove],
        insertedIndexPaths: Set<NSIndexPath>,
        deletedIndexPaths: Set<NSIndexPath>,
        movedIndexPaths: [CollectionChangeMove]
        ) {
        self.insertedIndexSections = insertedIndexSections
        self.deletedIndexSections = deletedIndexSections
        self.movedIndexSections = movedIndexSections
        self.insertedIndexPaths = insertedIndexPaths
        self.deletedIndexPaths = deletedIndexPaths
        self.movedIndexPaths = movedIndexPaths
    }
    
    func descriptionChanges() {
        print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        print("insertedIndexSections");
        insertedIndexSections.enumerateIndexesUsingBlock { (index, stop) -> Void in
            print("section : \(index)")
        }
        print("deletedIndexSections");
        deletedIndexSections.enumerateIndexesUsingBlock { (index, stop) -> Void in
            print("section : \(index)")
        }
        print("movedIndexSections");
        for section in movedIndexSections {
            print(section.description())
        }
        print("insertedIndexPaths");
        for path in insertedIndexPaths {
            print("section : \(path.section) row : \(path.row)")
        }
        print("deletedIndexPaths");
        for path in deletedIndexPaths {
            print("section : \(path.section) row : \(path.row)")
        }
        print("movedIndexPaths");
        for path in movedIndexPaths {
            print(path.description())
        }
        print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    }
}

func generateChanges(oldCollection oldCollection: [ChatSectionProtocol], newCollection: [ChatSectionProtocol]) -> CollectionChanges {
    func generateSectionIndexesById(uids: [String]) -> [String: Int] {
        var map = [String: Int](minimumCapacity: uids.count)
        for (index, uid) in uids.enumerate() {
            map[uid] = index
        }
        return map
    }
    
    func generateIndexesById(sections: [ChatSectionProtocol]) -> [String: NSIndexPath] {
        var map = [String: NSIndexPath]()
        for (indexSection, section) in sections.enumerate() {
            for (indexRow, item) in section.items.enumerate() {
                map[item.uid] = NSIndexPath(forRow: indexRow, inSection: indexSection)
            }
        }
        return map
    }

    let oldSectionIds = oldCollection.map { $0.uid }
    let newSectionIds = newCollection.map { $0.uid }
    let oldIndexsSectionById = generateSectionIndexesById(oldSectionIds)
    let newIndexsSectionById = generateSectionIndexesById(newSectionIds)
    let oldIndexsPathById = generateIndexesById(oldCollection)
    let newIndexsPathById = generateIndexesById(newCollection)
    let oldIds = oldIndexsPathById.keys
    let newIds = newIndexsPathById.keys
    /*
    print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    
    print("oldIds")
    for (key, path) in oldIndexsPathById {
        print("key : \(key) section : \(path.section) row : \(path.row)")
    }
    print("newIds")
    for (key, path) in newIndexsPathById {
        print("key : \(key) section : \(path.section) row : \(path.row)")
    }
    */
    let deletedIndexSections = NSMutableIndexSet()
    let insertedIndexSections = NSMutableIndexSet()
    var movedIndexSections = [SectionChangeMove]()
    
    // Deletions Sections
    for oldId in oldSectionIds {
        let isDeleted = newIndexsSectionById[oldId] == nil
        if isDeleted {
            deletedIndexSections.addIndex(oldIndexsSectionById[oldId]!)
        }
    }
    
    // Insertions and movements Sections
    for newId in newSectionIds {
        let newIndex = newIndexsSectionById[newId]!
        if let oldIndex = oldIndexsSectionById[newId] {
            if oldIndex != newIndex {
                movedIndexSections.append(SectionChangeMove(indexOld: oldIndex, indexNew: newIndex))
            }
        } else {
            // It's new
            insertedIndexSections.addIndex(newIndex)
        }
    }

    
    
    var deletedIndexPaths = Set<NSIndexPath>()
    var insertedIndexPaths = Set<NSIndexPath>()
    var movedIndexPaths = [CollectionChangeMove]()

    // Deletetions
    for oldId in oldIds {
        let isDeleted = newIndexsPathById[oldId] == nil
        if isDeleted {
            deletedIndexPaths.insert(oldIndexsPathById[oldId]!)
        }
    }

    // Insertions and movements
    for newId in newIds {
        let newIndexPath = newIndexsPathById[newId]!
        if let oldIndexPath = oldIndexsPathById[newId] {
            if oldIndexPath != newIndexPath {
                movedIndexPaths.append(CollectionChangeMove(indexPathOld: oldIndexPath, indexPathNew: newIndexPath))
            }
        } else {
            // It's new
            insertedIndexPaths.insert(newIndexPath)
        }
    }

    return CollectionChanges(
        insertedIndexSections: insertedIndexSections,
        deletedIndexSections: deletedIndexSections,
        movedIndexSections: movedIndexSections,
        insertedIndexPaths: insertedIndexPaths,
        deletedIndexPaths: deletedIndexPaths,
        movedIndexPaths: movedIndexPaths)
}
