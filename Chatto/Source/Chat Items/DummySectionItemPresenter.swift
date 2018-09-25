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
    
    class func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(DummyCollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "section-id-unhandled")
    }
    
    var canCalculateHeightInBackground: Bool {
        return true
    }
    
    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 30
    }
    
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "section-id-unhandled", for: indexPath)
    }
    
    func configureCell(_ cell: UICollectionReusableView, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        cell.isHidden = true
    }
}


class DummyCollectionReusableView: UICollectionReusableView {}
