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

struct SectionChangeMove: Equatable, Hashable {
    let indexOld: Int
    let indexNew: Int
    init(indexOld: Int, indexNew: Int) {
        self.indexOld = indexOld
        self.indexNew = indexNew
    }
    
    var hashValue: Int { return indexOld ^ indexNew }
}

func == (lhs: SectionChangeMove, rhs: SectionChangeMove) -> Bool {
    return lhs.indexOld == rhs.indexOld && lhs.indexNew == rhs.indexNew
}

struct CollectionChangeMove: Equatable, Hashable {
    let indexPathOld: NSIndexPath
    let indexPathNew: NSIndexPath
    init(indexPathOld: NSIndexPath, indexPathNew: NSIndexPath) {
        self.indexPathOld = indexPathOld
        self.indexPathNew = indexPathNew
    }

    var hashValue: Int { return indexPathOld.hash ^ indexPathNew.hash }
}

func == (lhs: CollectionChangeMove, rhs: CollectionChangeMove) -> Bool {
    return lhs.indexPathOld == rhs.indexPathOld && lhs.indexPathNew == rhs.indexPathNew
}

struct CollectionChanges {
    let insertedIndexSections: NSIndexSet
    let deletedIndexSections: NSIndexSet
    let movedIndexSections: [SectionChangeMove]
    let insertedIndexPaths: Set<NSIndexPath>
    let deletedIndexPaths: Set<NSIndexPath>
    let movedIndexPaths: [CollectionChangeMove]

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
}

func generateChanges(oldCollection oldCollection: [SectionItemProtocol], newCollection: [SectionItemProtocol]) -> CollectionChanges {
    func generateSectionIndexesById(uids: [String]) -> [String: Int] {
        var map = [String: Int](minimumCapacity: uids.count)
        for (index, uid) in uids.enumerate() {
            map[uid] = index
        }
        return map
    }
    
    func generateIndexesById(sections: [SectionItemProtocol]) -> [String: NSIndexPath] {
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
