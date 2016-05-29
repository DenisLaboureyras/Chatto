//
//  ChatSectionPresenterFactory.swift
//  Pods
//
//  Created by Denis Laboureyras on 29/05/2016.
//
//

import Foundation

public protocol ChatSectionPresenterFactoryProtocol {
    func createChatSectionPresenter(chatItem: ChatItemProtocol) -> SectionItemPresenterProtocol
    func configure(withCollectionView collectionView: UICollectionView)
}

final class ChatSectionPresenterFactory: ChatSectionPresenterFactoryProtocol {
    var presenterBuildersByType = [SectionItemType: [SectionItemPresenterBuilderProtocol]]()
    
    init(presenterBuildersByType: [SectionItemType: [SectionItemPresenterBuilderProtocol]]) {
        self.presenterBuildersByType = presenterBuildersByType
    }
    
    func createChatSectionPresenter(chatItem: ChatItemProtocol) -> SectionItemPresenterProtocol {
        for builder in self.presenterBuildersByType[chatItem.type] ?? [] {
            if builder.canHandleChatItem(chatItem) {
                return builder.createPresenterWithChatItem(chatItem)
            }
        }
        return DummySectionItemPresenter()
    }
    
    func configure(withCollectionView collectionView: UICollectionView) {
        for presenterBuilder in self.presenterBuildersByType.flatMap({ $0.1 }) {
            presenterBuilder.presenterType.registerCells(collectionView)
        }
        DummySectionItemPresenter.registerCells(collectionView)
    }
}