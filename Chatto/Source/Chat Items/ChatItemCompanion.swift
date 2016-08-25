//
//  ChatItemCompanion.swift
//  Pods
//
//  Created by Denis Laboureyras on 27/05/2016.
//
//

import Foundation

public protocol ChatItemsDecoratorProtocol {
    func decorateItems(_ chatItems: [ChatItemProtocol]) -> [DecoratedChatItem]
}

public struct DecoratedChatItem {
    public let chatItem: ChatItemProtocol
    public let decorationAttributes: ChatItemDecorationAttributesProtocol?
    public init(chatItem: ChatItemProtocol, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        self.chatItem = chatItem
        self.decorationAttributes = decorationAttributes
    }
}

public protocol SectionItemsDecoratorProtocol {
    var chatItemsDecorator: ChatItemsDecoratorProtocol? {get set}
    func decorateItems(_ sectionItems: [SectionItemProtocol]) -> [DecoratedSectionItem]
}

public struct DecoratedSectionItem {
    public let chatItem: ChatItemProtocol
    public let decorationAttributes: ChatItemDecorationAttributesProtocol?
    public init(chatItem: ChatItemProtocol, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        self.chatItem = chatItem
        self.decorationAttributes = decorationAttributes
    }
}

public struct SectionItemCompanion: UniqueIdentificable {
    public let sectionItem: ChatItemProtocol
    public let presenter: SectionItemPresenterProtocol
    public var decorationAttributes: ChatItemDecorationAttributesProtocol?
    public var uid: String {
        return self.sectionItem.uid
    }
}

public struct ChatItemCompanion: UniqueIdentificable {
    public let chatItem: ChatItemProtocol
    public let presenter: ChatItemPresenterProtocol
    public var decorationAttributes: ChatItemDecorationAttributesProtocol?
    public var uid: String {
        return self.chatItem.uid
    }
}


public protocol ChatSectionProtocol : UniqueIdentificable {
    var section: SectionItemCompanion {get set};
    var items: ChatItemCompanionCollection {get set};
}

open class ChatSection: ChatSectionProtocol {
    open var section: SectionItemCompanion;
    open var items: ChatItemCompanionCollection;
    public init(section: SectionItemCompanion, items: ChatItemCompanionCollection) {
        self.section = section
        self.items = items
    }
    
    open var uid: String {
        return self.section.sectionItem.uid
    }
    
}

public typealias ChatSectionCompanionCollection = ReadOnlyOrderedSectionedDictionary<ChatSection>
public typealias ChatItemCompanionCollection = ReadOnlyOrderedDictionary<ChatItemCompanion>
