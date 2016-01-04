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

extension ChatViewController: ChatCollectionViewLayoutDelegate {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return self.sections.count
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //collectionView.collectionViewLayout.invalidateLayout()
        return self.sections[section].items.count
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if ( kind == UICollectionElementKindSectionHeader )
        {
            let presenter = self.presenterForIndexSection(indexPath)
            let cell = presenter.dequeueCell(collectionView: collectionView, indexPath: indexPath)
            let decorationAttributes = self.decorationAttributesForIndexSection(indexPath)
            presenter.configureCell(cell, decorationAttributes: decorationAttributes)
            return cell
        }
        
        return UICollectionReusableView()
        
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let presenter = self.presenterForIndexPath(indexPath)
        let cell = presenter.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        let decorationAttributes = self.decorationAttributesForIndexPath(indexPath)
        presenter.configureCell(cell, decorationAttributes: decorationAttributes)
        return cell
    }

    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        // Carefull: this index path can refer to old data source after an update. Don't use it to grab items from the model
        // Instead let's use a mapping presenter <--> cell
        if let oldPresenterForCell = self.presentersByCell.objectForKey(cell) as? ChatItemPresenterProtocol {
            self.presentersByCell.removeObjectForKey(cell)
            oldPresenterForCell.cellWasHidden(cell)
        }
    }

    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        // Here indexPath should always referer to updated data source.
        let presenter = self.presenterForIndexPath(indexPath)
        self.presentersByCell.setObject(presenter, forKey: cell)
        presenter.cellWillBeShown(cell)
    }

    public func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.presenterForIndexPath(indexPath).shouldShowMenu() ?? false
    }

    public func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return self.presenterForIndexPath(indexPath).canPerformMenuControllerAction(action) ?? false
    }

    public func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        self.presenterForIndexPath(indexPath).performMenuControllerAction(action)
    }

    public func presenterForIndexPath(indexPath: NSIndexPath) -> ChatItemPresenterProtocol {
        let decoratedChatItems = self.sections[indexPath.section].items
        return self.presenterForIndex(indexPath.item, decoratedChatItems: decoratedChatItems)
    }
    
    public func presenterForIndexSection(indexPath: NSIndexPath) -> SectionItemPresenterProtocol {
        guard indexPath.section < sections.count else {
            // This can happen from didEndDisplayingCell if we reloaded with less messages
            return DummySectionItemPresenter()
        }
        let decoratedSectionItems = self.sections[indexPath.section].section
        let sectionItem = decoratedSectionItems.chatItem
        if let presenter = self.presentersBySectionItem.objectForKey(sectionItem) as? SectionItemPresenterProtocol {
            return presenter
        }
        let presenter = self.createPresenterForSectionItem(sectionItem)
        self.presentersBySectionItem.setObject(presenter, forKey: sectionItem)
        return presenter
    }

    public func presenterForIndex(index: Int, decoratedChatItems: [DecoratedChatItem]) -> ChatItemPresenterProtocol {
        guard index < decoratedChatItems.count else {
            // This can happen from didEndDisplayingCell if we reloaded with less messages
            return DummyChatItemPresenter()
        }

        let chatItem = decoratedChatItems[index].chatItem
        if let presenter = self.presentersByChatItem.objectForKey(chatItem) as? ChatItemPresenterProtocol {
            return presenter
        }
        let presenter = self.createPresenterForChatItem(chatItem)
        self.presentersByChatItem.setObject(presenter, forKey: chatItem)
        return presenter
    }

    public func createPresenterForChatItem(chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        for builder in self.presenterBuildersByType[chatItem.type] ?? [] {
            if builder.canHandleChatItem(chatItem) {
                return builder.createPresenterWithChatItem(chatItem)
            }
        }
        return DummyChatItemPresenter()
    }
    
    public func createPresenterForSectionItem(chatItem: ChatItemProtocol) -> SectionItemPresenterProtocol {
        for builder in self.sectionPresenterBuildersByType[chatItem.type] ?? [] {
            if builder.canHandleChatItem(chatItem) {
                return builder.createPresenterWithChatItem(chatItem)
            }
        }
        return DummySectionItemPresenter()
    }

    public func decorationAttributesForIndexPath(indexPath: NSIndexPath) -> ChatItemDecorationAttributesProtocol? {
        return self.sections[indexPath.section].items[indexPath.row].decorationAttributes
    }
    
    public func decorationAttributesForIndexSection(indexPath: NSIndexPath) -> ChatItemDecorationAttributesProtocol? {
        return self.sections[indexPath.section].section.decorationAttributes
    }
}
