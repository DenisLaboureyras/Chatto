//
//  SectionItemsDemoDecorator.swift
//  ChattoApp
//
//  Created by Denis Laboureyras on 18/12/2015.
//  Copyright © 2015 Badoo. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions

final class SectionItemsDemoDecorator: SectionItemsDecoratorProtocol {
    
    var chatItemsDecorator: ChatItemsDecoratorProtocol?
    struct Constants {
        static let shortSeparation: CGFloat = 3
        static let normalSeparation: CGFloat = 10
        static let timeIntervalThresholdToIncreaseSeparation: NSTimeInterval = 120
    }
    
    func decorateItems(sectionItems: [SectionItemProtocol]) -> [ChatSection] {
        
        var decoratedSectionItems = [ChatSection]()
        
        for sectionItem in sectionItems {
            
            let bottomMargin: CGFloat = 0
            let showsTail = false
            
            let decoratedSection = DecoratedSectionItem(
                chatItem: sectionItem.section,
                decorationAttributes: ChatItemDecorationAttributes(bottomMargin: bottomMargin, showsTail: showsTail)
            )
            
            let decoratedItems = chatItemsDecorator?.decorateItems(sectionItem.items) ?? sectionItem.items.map {DecoratedChatItem(chatItem: $0, decorationAttributes: nil)}
            
            let chatSection = ChatSection(section: decoratedSection, items: decoratedItems)

            
            
            decoratedSectionItems.append(chatSection)
        }
        
        return decoratedSectionItems
    }
    
}
