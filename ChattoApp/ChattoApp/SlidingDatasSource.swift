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
import Chatto

public enum InsertPosition {
    case Top
    case Bottom
}

public class SlidingDataSource  {

    var uniqueSection = FakeMessageFactory.createUniqueSectionItem("0")
    
    private var pageSize: Int
    private var windowOffset: Int
    private var windowCount: Int
    private var itemGenerator: (() -> ChatItemProtocol)?
    private var items = [ChatItemProtocol]()
    private var sectionsItems = [SectionItemProtocol]()
    private var itemsOffset: Int
    public var itemsInWindow: [SectionItemProtocol] {
        if sectionsItems.count > 0 {
            return sectionsItems
        }else{
            let offset = self.windowOffset - self.itemsOffset
            let itemsInWd = Array(items[offset..<offset+self.windowCount]) as [ChatItemProtocol]
            return [SectionItem(section: uniqueSection, items: itemsInWd)].map {$0 as SectionItemProtocol}
        }
    }

    public init(count: Int, pageSize: Int, itemGenerator: (() -> ChatItemProtocol)?) {
        self.windowOffset = count
        self.itemsOffset = count
        self.windowCount = 0
        self.pageSize = pageSize
        self.itemGenerator = itemGenerator
        self.generateItems(min(pageSize, count), position: .Top)
    }

    public convenience init(items: [ChatItemProtocol], pageSize: Int) {
        self.init(count: 0, pageSize: pageSize, itemGenerator: nil)
        for item in items {
            self.insertItem(item, position: .Bottom)
        }
    }
    
    public convenience init(sectionsItems: [SectionItemProtocol], pageSize: Int) {
        self.init(count: 0, pageSize: pageSize, itemGenerator: nil)
        self.sectionsItems = sectionsItems
    }

    private func generateItems(count: Int, position: InsertPosition) {
        guard count > 0 else { return }
        guard let itemGenerator = self.itemGenerator else {
            fatalError("Can't create messages without a generator")
        }
        for _ in 0..<count {
            self.insertItem(itemGenerator(), position: .Top)
        }
    }

    public func insertItem(item: ChatItemProtocol, position: InsertPosition) {
        if position == .Top {
            self.items.insert(item, atIndex: 0)
            let shouldExpandWindow = self.itemsOffset == self.windowOffset
            self.itemsOffset--
            if shouldExpandWindow {
                self.windowOffset--
                self.windowCount++
            }
        } else {
            let shouldExpandWindow = self.itemsOffset + self.items.count == self.windowOffset + self.windowCount
            if shouldExpandWindow {
                self.windowCount++
            }
            self.items.append(item)
        }
    }

    public func hasPrevious() -> Bool {
        return self.windowOffset > 0
    }

    public func hasMore() -> Bool {
        return self.windowOffset + self.windowCount < self.itemsOffset + self.items.count
    }

    public func loadPrevious() {
        let previousWindowOffset = self.windowOffset
        let previousWindowCount = self.windowCount
        let nextWindowOffset = max(0, self.windowOffset - self.pageSize)
        let messagesNeeded = self.itemsOffset - nextWindowOffset
        if messagesNeeded > 0 {
            self.generateItems(messagesNeeded, position: .Top)
        }
        let newItemsCount = previousWindowOffset - nextWindowOffset
        self.windowOffset = nextWindowOffset
        self.windowCount = previousWindowCount + newItemsCount
    }

    public func loadNext() {
        guard self.items.count > 0 else { return }
        let itemCountAfterWindow = self.itemsOffset + self.items.count - self.windowOffset - self.windowCount
        self.windowCount += min(self.pageSize, itemCountAfterWindow)
    }

    public func adjustWindow(focusPosition focusPosition: Double, maxWindowSize: Int) -> Bool {
        assert(0 <= focusPosition && focusPosition <= 1, "")
        guard 0 <= focusPosition && focusPosition <= 1 else {
            assert(false, "focus should be in the [0, 1] interval")
            return false
        }
        let sizeDiff = self.windowCount - maxWindowSize
        guard sizeDiff > 0 else { return false}
        self.windowOffset +=  Int(focusPosition * Double(sizeDiff))
        self.windowCount = maxWindowSize
        return true
    }
}
