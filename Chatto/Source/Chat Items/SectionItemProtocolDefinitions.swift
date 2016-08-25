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
    func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool
    func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> SectionItemPresenterProtocol
    var presenterType: SectionItemPresenterProtocol.Type { get }
}

public protocol SectionItemPresenterProtocol: class {
    static func registerCells(_ collectionView: UICollectionView)
    var canCalculateHeightInBackground: Bool { get } // Default is false
    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat
    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView
    func configureCell(_ cell: UICollectionReusableView, decorationAttributes: ChatItemDecorationAttributesProtocol?)
    func cellWillBeShown(_ cell: UICollectionReusableView) // optional
    func cellWasHidden(_ cell: UICollectionReusableView) // optional
    func shouldShowMenu() -> Bool // optional. Default is false
    func canPerformMenuControllerAction(_ action: Selector) -> Bool // optional. Default is false
    func performMenuControllerAction(_ action: Selector) // optional
}

public extension SectionItemPresenterProtocol { // Optionals
    var canCalculateHeightInBackground: Bool { return false }
    func cellWillBeShown(_ cell: UICollectionReusableView) {}
    func cellWasHidden(_ cell: UICollectionReusableView) {}
    func shouldShowMenu() -> Bool { return false }
    func canPerformMenuControllerAction(_ action: Selector) -> Bool { return false }
    func performMenuControllerAction(_ action: Selector) {}
}


open class SectionItem: SectionItemProtocol {

    open var section : ChatItemProtocol
    open var items : [ChatItemProtocol]
    
    open var uid: String
    
    public init(section: ChatItemProtocol, items: [ChatItemProtocol]){
        self.section = section;
        self.items = items;
        self.uid = section.uid;
    }
}

protocol SRChatItem: ChatItemProtocol {
    var messageTimestamp: Date {get}
}
