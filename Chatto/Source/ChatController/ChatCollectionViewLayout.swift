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

import UIKit

public protocol ChatCollectionViewLayoutDelegate: class {
    var collectionView: UICollectionView! {get}
    func chatCollectionViewLayoutModel() -> ChatCollectionViewLayoutModel
}

public struct ChatCollectionViewLayoutModel {
    let contentSize: CGSize
    let layoutAttributes: [UICollectionViewLayoutAttributes]
    let layoutAttributesBySectionAndItem: [[UICollectionViewLayoutAttributes]]
    let calculatedForWidth: CGFloat

    public static func createModel(collectionViewWidth: CGFloat, itemsLayoutData: [(indexPath: NSIndexPath, height: CGFloat, bottomMargin: CGFloat)]) -> ChatCollectionViewLayoutModel {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        var layoutAttributesBySectionAndItem = [[UICollectionViewLayoutAttributes]]()
        layoutAttributesBySectionAndItem.append([UICollectionViewLayoutAttributes]())

        var verticalOffset: CGFloat = 0
        for layoutData in itemsLayoutData {
            let (indexPath, height, bottomMargin) = layoutData
            let itemSize = CGSize(width: collectionViewWidth, height: height)
            let frame = CGRect(origin: CGPoint(x: 0, y: verticalOffset), size: itemSize)
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = frame
            layoutAttributes.append(attributes)
            layoutAttributesBySectionAndItem[0].append(attributes)
            verticalOffset += itemSize.height
            verticalOffset += bottomMargin
        }

        return ChatCollectionViewLayoutModel(
            contentSize: CGSize(width: collectionViewWidth, height: verticalOffset),
            layoutAttributes: layoutAttributes,
            layoutAttributesBySectionAndItem: layoutAttributesBySectionAndItem,
            calculatedForWidth: collectionViewWidth
        )
    }
}


public class ChatCollectionViewLayout: UICollectionViewLayout {
    var layoutModel: ChatCollectionViewLayoutModel!
    public weak var delegate: ChatCollectionViewLayoutDelegate?

    // Optimization: after reloadData we'll get invalidateLayout, but prepareLayout will be delayed until next run loop.
    // Client may need to force prepareLayout after reloadData, but we don't want to compute layout again in the next run loop.
    private var layoutNeedsUpdate = true
    public override func invalidateLayout() {
        super.invalidateLayout()
        self.layoutNeedsUpdate = true
    }

    public override func prepareLayout() {
        super.prepareLayout()
        guard self.layoutNeedsUpdate else { return }
        guard let delegate = self.delegate else { return }
        var oldLayoutModel = self.layoutModel
        self.layoutModel = delegate.chatCollectionViewLayoutModel()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            // Dealloc of layout with 5000 items take 25 ms on tests on iPhone 4s
            // This moves dealloc out of main thread
            oldLayoutModel = nil
        }
    }

    public override func collectionViewContentSize() -> CGSize {
        if self.layoutNeedsUpdate {
            self.prepareLayout()
        }
        return self.layoutModel.contentSize
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = test(rect)//self.layoutModel.layoutAttributes.filter { $0.frame.intersects(rect) }
        print(layoutAttributes)
        return layoutAttributes
    }
    
    func test(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var answer = self.layoutModel.layoutAttributes.filter { $0.frame.intersects(rect) }
        let cv = self.delegate?.collectionView;
        let contentOffset: CGPoint = cv?.contentOffset ?? CGPointZero;
        
        let missingSections = NSMutableIndexSet();
        for layoutAttributes in answer {
            if (layoutAttributes.representedElementCategory == .Cell) {
                print(layoutAttributes.indexPath)
                missingSections.addIndex(layoutAttributes.indexPath.section);
            }
        }
        for layoutAttributes in answer {
            if (layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader) {
                print(layoutAttributes.indexPath)
                missingSections.removeIndex(layoutAttributes.indexPath.section);
            }
        }
        
        missingSections.enumerateIndexesUsingBlock { (idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            let indexPath = NSIndexPath(forItem: 0, inSection: idx)
            if let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) {
                answer.append(layoutAttributes)
            }

        }
        
        
        
        for layoutAttributes in answer {
            print(layoutAttributes.indexPath)
            
            if (layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader) {
                
                let section = layoutAttributes.indexPath.section;
                let numberOfItemsInSection = cv?.numberOfItemsInSection(section) ?? 0;
                
                //let firstCellIndexPath = NSIndexPath(forItem:0, inSection:section);
                //let lastCellIndexPath = NSIndexPath(forItem:max(0, (numberOfItemsInSection - 1)), inSection:section);
                
                let firstObjectIndexPath = NSIndexPath(forItem:0, inSection:section);
                let lastObjectIndexPath = NSIndexPath(forItem:max(0, (numberOfItemsInSection - 1)), inSection:section);
                
                var firstObjectAttrs: UICollectionViewLayoutAttributes!;
                var lastObjectAttrs: UICollectionViewLayoutAttributes!;
                
                if (numberOfItemsInSection > 0) {
                    firstObjectAttrs = self.layoutAttributesForItemAtIndexPath(firstObjectIndexPath);
                    lastObjectAttrs = self.layoutAttributesForItemAtIndexPath(lastObjectIndexPath);
                } else {
                    firstObjectAttrs = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                        atIndexPath:firstObjectIndexPath);
                    lastObjectAttrs = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter,
                        atIndexPath:lastObjectIndexPath);
                }
                
                let headerHeight = CGRectGetHeight(layoutAttributes.frame);
                var origin = layoutAttributes.frame.origin;
                origin.y = min(
                    max(
                        contentOffset.y + (cv?.contentInset.top ?? 0),
                        (CGRectGetMinY(firstObjectAttrs.frame) - headerHeight)
                    ),
                    (CGRectGetMaxY(lastObjectAttrs.frame) - headerHeight)
                );
                
                layoutAttributes.zIndex = 1024;
                layoutAttributes.frame = CGRect(origin: origin, size: layoutAttributes.frame.size)
                
            }
            
        }
        
        return answer;

    }

    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        if indexPath.section < self.layoutModel.layoutAttributesBySectionAndItem.count && indexPath.item < self.layoutModel.layoutAttributesBySectionAndItem[indexPath.section].count {
//            return self.layoutModel.layoutAttributesBySectionAndItem[indexPath.section][indexPath.item]
//        }
//        assert(false, "Unexpected indexPath requested:\(indexPath)")
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
        let verticalOffset: CGFloat = 0
        
        let height: CGFloat = 40
        let itemSize = CGSize(width: 375, height: height)
        let frame = CGRect(origin: CGPoint(x: 0, y: verticalOffset), size: itemSize)
        
        attributes.frame = frame
        
        return attributes
    }

    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section < self.layoutModel.layoutAttributesBySectionAndItem.count && indexPath.item < self.layoutModel.layoutAttributesBySectionAndItem[indexPath.section].count {
            return self.layoutModel.layoutAttributesBySectionAndItem[indexPath.section][indexPath.item]
        }
        assert(false, "Unexpected indexPath requested:\(indexPath)")
        return nil
    }

    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return self.layoutModel.calculatedForWidth != newBounds.width
    }
}
