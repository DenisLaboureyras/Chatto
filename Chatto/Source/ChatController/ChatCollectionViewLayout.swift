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
    weak var collectionView: UICollectionView! {get}
    func chatCollectionViewLayoutModel() -> ChatCollectionViewLayoutModel
}

public struct ChatCollectionViewLayoutModel {
    let contentSize: CGSize
    let layoutAttributes: [UICollectionViewLayoutAttributes]
    let layoutAttributesBySectionAndItem: [[UICollectionViewLayoutAttributes]]
    let layoutAttributesSections: [UICollectionViewLayoutAttributes]
    let calculatedForWidth: CGFloat

    public static func createModel(_ collectionViewWidth: CGFloat, itemsLayoutData: [(indexPath: IndexPath, height: CGFloat, headerMargin: CGFloat, bottomMargin: CGFloat)], sectionsLayoutData: [(indexPath: IndexPath, height: CGFloat)]) -> ChatCollectionViewLayoutModel {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        var layoutAttributesBySectionAndItem = [[UICollectionViewLayoutAttributes]]()
        var layoutAttributesSections = [UICollectionViewLayoutAttributes]()
        layoutAttributesBySectionAndItem.append([UICollectionViewLayoutAttributes]())

        var verticalOffset: CGFloat = 0
        for layoutData in itemsLayoutData {
            let (indexPath, height, headerMargin, bottomMargin) = layoutData
            let itemSize = CGSize(width: collectionViewWidth, height: height)
            if(indexPath.row == 0){verticalOffset += headerMargin}
            let frame = CGRect(origin: CGPoint(x: 0, y: verticalOffset), size: itemSize)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            layoutAttributes.append(attributes)
            if(indexPath.section < layoutAttributesBySectionAndItem.count){
                layoutAttributesBySectionAndItem[indexPath.section].append(attributes)
            }else{
                layoutAttributesBySectionAndItem.append([attributes])
            }

            verticalOffset += itemSize.height
            verticalOffset += bottomMargin
        }
        
        for sectionLayoutData in sectionsLayoutData {
            let (indexPath, height) = sectionLayoutData
            let layoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
            
            let itemSize = CGSize(width: collectionViewWidth, height: height)
            let frame = CGRect(origin: CGPoint(x: 0, y: verticalOffset), size: itemSize)
            
            layoutAttributes.frame = frame
            layoutAttributesSections.append(layoutAttributes)
        }

        return ChatCollectionViewLayoutModel(
            contentSize: CGSize(width: collectionViewWidth, height: verticalOffset),
            layoutAttributes: layoutAttributes,
            layoutAttributesBySectionAndItem: layoutAttributesBySectionAndItem,
            layoutAttributesSections : layoutAttributesSections,
            calculatedForWidth: collectionViewWidth
        )
    }
}


open class ChatCollectionViewLayout: UICollectionViewFlowLayout {
    var layoutModel: ChatCollectionViewLayoutModel!
    open weak var delegate: ChatCollectionViewLayoutDelegate?

    // Optimization: after reloadData we'll get invalidateLayout, but prepareLayout will be delayed until next run loop.
    // Client may need to force prepareLayout after reloadData, but we don't want to compute layout again in the next run loop.
    fileprivate var layoutNeedsUpdate = true
    open override func invalidateLayout() {
        super.invalidateLayout()
        self.layoutNeedsUpdate = true
    }

    open override func prepare() {
        super.prepare()
        guard self.layoutNeedsUpdate else { return }
        guard let delegate = self.delegate else { return }
        var oldLayoutModel = self.layoutModel
        self.layoutModel = delegate.chatCollectionViewLayoutModel()
        self.layoutNeedsUpdate = false
        if #available(iOS 9.0, *) {
            self.sectionHeadersPinToVisibleBounds = true
        } else {
            // Fallback on earlier versions
        }
        DispatchQueue.global(qos: .default).async { () -> Void in
            // Dealloc of layout with 5000 items take 25 ms on tests on iPhone 4s
            // This moves dealloc out of main thread
            if oldLayoutModel != nil {
            // Use nil check above to remove compiler warning: Variable 'oldLayoutModel' was written to, but never read
                oldLayoutModel = nil
            }
        }
    }

    open override var collectionViewContentSize: CGSize {
        return self.layoutModel?.contentSize ?? .zero
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = layoutAttributesForElementsInRectCustom(rect)//self.layoutModel.layoutAttributes.filter { $0.frame.intersects(rect) }

        return layoutAttributes
    }
    
    fileprivate func layoutAttributesForElementsInRectCustom(_ rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var answer = self.layoutModel.layoutAttributes.filter { $0.frame.intersects(rect) }
        
        var missingSections = IndexSet();
        for layoutAttributes in answer {
            if (layoutAttributes.representedElementCategory == .cell) {
                missingSections.insert(layoutAttributes.indexPath.section);
            }
        }
        for layoutAttributes in answer {
            if (layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader) {
                missingSections.remove(layoutAttributes.indexPath.section);
            }
        }
        
        
        for (idx, _) in missingSections.enumerated() {
            let indexPath = IndexPath(item: 0, section: idx)
            if let layoutAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath) {
                answer.append(layoutAttributes)
            }
            
        }
        
        
        
        return answer;

    }

    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
       
        if(elementKind == UICollectionElementKindSectionHeader){
            
            guard let cv = self.delegate?.collectionView else {return nil;};
            let contentOffset: CGPoint = cv.contentOffset;
            
            guard indexPath.section < self.layoutModel.layoutAttributesSections.count else {return nil;}
            let layoutAttributes = self.layoutModel.layoutAttributesSections[indexPath.section]
            
            let section = layoutAttributes.indexPath.section;
            let numberOfItemsInSection = cv.numberOfItems(inSection: section);
            
            let firstObjectIndexPath = IndexPath(item:0, section:section);
            let lastObjectIndexPath = IndexPath(item:max(0, (numberOfItemsInSection - 1)), section:section);
            
            var firstObjectAttrs: UICollectionViewLayoutAttributes!;
            var lastObjectAttrs: UICollectionViewLayoutAttributes!;
            
            if (numberOfItemsInSection > 0) {
                firstObjectAttrs = self.layoutAttributesForItem(at: firstObjectIndexPath);
                lastObjectAttrs = self.layoutAttributesForItem(at: lastObjectIndexPath);
            } else {
                firstObjectAttrs = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                    at:firstObjectIndexPath);
                lastObjectAttrs = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                    at:lastObjectIndexPath);
            }
            
            let headerHeight = layoutAttributes.frame.height;
            var origin = layoutAttributes.frame.origin;
            origin.y = min(
                max(
                    contentOffset.y + cv.contentInset.top,
                    (firstObjectAttrs.frame.minY - headerHeight)
                ),
                (lastObjectAttrs.frame.maxY - headerHeight)
            );
            
            layoutAttributes.zIndex = 1024;
            layoutAttributes.frame = CGRect(origin: origin, size: layoutAttributes.frame.size);
            print("layoutAttributes \(indexPath.section)")
            print(layoutAttributes.frame)
            return layoutAttributes;
        }
        return nil;
    }
    
    
    open override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at indexPath : IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let attributes = self.layoutAttributesForSupplementaryView(ofKind: elementKind, at:indexPath);
        return attributes;
    }
    
    open override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at indexPath : IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = self.layoutAttributesForSupplementaryView(ofKind: elementKind, at:indexPath);
        return attributes;
    }
    

    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section < self.layoutModel.layoutAttributesBySectionAndItem.count && indexPath.item < self.layoutModel.layoutAttributesBySectionAndItem[indexPath.section].count {
            return self.layoutModel.layoutAttributesBySectionAndItem[indexPath.section][indexPath.item]
        }
        assert(false, "Unexpected indexPath requested:\(indexPath)")
        return nil
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        //change to recalculate headers
        return true
    }
}
