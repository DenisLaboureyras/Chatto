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

extension BaseChatViewController: ChatCollectionViewLayoutDelegate {
    
    @objc(numberOfSectionsInCollectionView:) public func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return self.chatSectionCompanionCollection.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //collectionView.collectionViewLayout.invalidateLayout()
        return self.chatSectionCompanionCollection[section].items.count
    }
    
    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:) public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if ( kind == UICollectionView.elementKindSectionHeader )
        {
            let presenter = self.presenterForIndexSection(indexPath)
            let cell = presenter.dequeueCell(collectionView: collectionView, indexPath: indexPath)
            let decorationAttributes = self.decorationAttributesForIndexSection(indexPath)
            presenter.configureCell(cell, decorationAttributes: decorationAttributes)
            return cell
        }
        
        return UICollectionReusableView()
        
    }

    @objc(collectionView:cellForItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let presenter = self.presenterForIndexPath(indexPath)
        let cell = presenter.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        let decorationAttributes = self.decorationAttributesForIndexPath(indexPath)
        presenter.configureCell(cell, decorationAttributes: decorationAttributes)
        return cell
    }

    @objc(collectionView:didEndDisplayingCell:forItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Carefull: this index path can refer to old data source after an update. Don't use it to grab items from the model
        // Instead let's use a mapping presenter <--> cell
        if let oldPresenterForCell = self.presentersByCell.object(forKey: cell) as? ChatItemPresenterProtocol {
            self.presentersByCell.removeObject(forKey: cell)
            oldPresenterForCell.cellWasHidden(cell)
        }
    }
    
    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Here indexPath should always referer to updated data source.
        
        let presenter = self.presenterForIndexPath(indexPath)
        self.presentersByCell.setObject(presenter, forKey: cell)
        
        if self.isAdjustingInputContainer {
            UIView.performWithoutAnimation({
                // See https://github.com/badoo/Chatto/issues/133
                presenter.cellWillBeShown(cell)
                cell.layoutIfNeeded()
            })
        } else {
            presenter.cellWillBeShown(cell)
        }
    }

    @objc(collectionView:shouldShowMenuForItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return self.presenterForIndexPath(indexPath).shouldShowMenu()
    }

    @objc(collectionView:canPerformAction:forItemAtIndexPath:withSender:) public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return self.presenterForIndexPath(indexPath).canPerformMenuControllerAction(action)
    }

    @objc(collectionView:performAction:forItemAtIndexPath:withSender:) public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        self.presenterForIndexPath(indexPath).performMenuControllerAction(action)
    }

    public func presenterForIndexPath(_ indexPath: IndexPath) -> ChatItemPresenterProtocol {
        let decoratedChatItems = self.chatSectionCompanionCollection[indexPath.section].items
        return self.presenterForIndex(indexPath.item, chatItemCompanionCollection: decoratedChatItems)
    }
    
    public func presenterForIndexSection(_ indexPath: IndexPath) -> SectionItemPresenterProtocol {
        guard indexPath.section < chatSectionCompanionCollection.count else {
            // This can happen from didEndDisplayingCell if we reloaded with less messages
            return DummySectionItemPresenter()
        }
        return self.chatSectionCompanionCollection[indexPath.section].section.presenter
        
    }

    public func presenterForIndex(_ index: Int, chatItemCompanionCollection items: ChatItemCompanionCollection) -> ChatItemPresenterProtocol {
        guard index < items.count else {
            // This can happen from didEndDisplayingCell if we reloaded with less messages
            return DummyChatItemPresenter()
        }

        return items[index].presenter
    }

    public func createPresenterForChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        return self.presenterFactory.createChatItemPresenter(chatItem)
    }
    
    public func createPresenterForSectionItem(_ chatItem: ChatItemProtocol) -> SectionItemPresenterProtocol {
        return self.sectionPresenterFactory.createChatSectionPresenter(chatItem)
    }

    public func decorationAttributesForIndexPath(_ indexPath: IndexPath) -> ChatItemDecorationAttributesProtocol? {
        return self.chatSectionCompanionCollection[indexPath.section].items[indexPath.row].decorationAttributes
    }
    
    public func decorationAttributesForIndexSection(_ indexPath: IndexPath) -> ChatItemDecorationAttributesProtocol? {
        return self.chatSectionCompanionCollection[indexPath.section].section.decorationAttributes
    }
}
