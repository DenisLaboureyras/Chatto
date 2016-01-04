//
//  DummySectionItemPresenter.swift
//  Pods
//
//  Created by Denis Laboureyras on 04/01/2016.
//
//

import Foundation

// Handles messages that aren't supported so they appear as invisible
class DummySectionItemPresenter: SectionItemPresenterProtocol {
    
    class func registerCells(collectionView: UICollectionView) {
        collectionView.registerClass(DummyCollectionReusableView.self, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "section-id-unhandled-message")
    }
    
    var canCalculateHeightInBackground: Bool {
        return true
    }
    
    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 0
    }
    
    func dequeueCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "section-id-unhandled-message", forIndexPath: indexPath)
    }
    
    func configureCell(cell: UICollectionReusableView, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        cell.hidden = true
    }
}


class DummyCollectionReusableView: UICollectionReusableView {}
