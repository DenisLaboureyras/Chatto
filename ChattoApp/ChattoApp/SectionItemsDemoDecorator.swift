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
        static let timeIntervalThresholdToIncreaseSeparation: TimeInterval = 120
    }
    
    func decorateItems(_ sectionItems: [SectionItemProtocol]) -> [DecoratedSectionItem] {
        
        var decoratedSectionItems = [DecoratedSectionItem]()
        
        for sectionItem in sectionItems {
            
            let bottomMargin: CGFloat = 0
            let showsTail = false
            
            let decoratedSection = DecoratedSectionItem(
                chatItem: sectionItem.section,
                decorationAttributes: ChatItemDecorationAttributes(bottomMargin: bottomMargin, showsTail: showsTail)
            )
            
            decoratedSectionItems.append(decoratedSection)
        }
        
        return decoratedSectionItems
    }
    
}
