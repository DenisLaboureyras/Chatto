//
//  SectionItemProtocolDefinitions.swift
//  Chatto
//
//  Created by Denis Laboureyras on 17/12/2015.
//  Copyright © 2015 Badoo. All rights reserved.
//

import Foundation

public typealias SectionItemType = String

public protocol SectionItemProtocol: class, UniqueIdentificable {
    var section : ChatItemProtocol { get }
    var items : [ChatItemProtocol] { get set}
}

public protocol SectionItemPresenterBuilderProtocol {
    func canHandleChatItem(chatItem: ChatItemProtocol) -> Bool
    func createPresenterWithChatItem(chatItem: ChatItemProtocol) -> SectionItemPresenterProtocol
    var presenterType: SectionItemPresenterProtocol.Type { get }
}

public protocol SectionItemPresenterProtocol: class {
    static func registerCells(collectionView: UICollectionView)
    var canCalculateHeightInBackground: Bool { get } // Default is false
    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat
    func dequeueCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionReusableView
    func configureCell(cell: UICollectionReusableView, decorationAttributes: ChatItemDecorationAttributesProtocol?)
    func cellWillBeShown(cell: UICollectionReusableView) // optional
    func cellWasHidden(cell: UICollectionReusableView) // optional
    func shouldShowMenu() -> Bool // optional. Default is false
    func canPerformMenuControllerAction(action: Selector) -> Bool // optional. Default is false
    func performMenuControllerAction(action: Selector) // optional
}

public extension SectionItemPresenterProtocol { // Optionals
    var canCalculateHeightInBackground: Bool { return false }
    func cellWillBeShown(cell: UICollectionReusableView) {}
    func cellWasHidden(cell: UICollectionReusableView) {}
    func shouldShowMenu() -> Bool { return false }
    func canPerformMenuControllerAction(action: Selector) -> Bool { return false }
    func performMenuControllerAction(action: Selector) {}
}


public class SectionItem: SectionItemProtocol {

    public var section : ChatItemProtocol
    public var items : [ChatItemProtocol]
    
    public var uid: String
    
    public init(section: ChatItemProtocol, items: [ChatItemProtocol]){
        self.section = section;
        self.items = items;
        self.uid = section.uid;
    }
}