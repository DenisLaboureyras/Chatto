//
//  ChatItemPresenterFactory.swift
//  Pods
//
//  Created by Denis Laboureyras on 27/05/2016.
//
//

import Foundation


public protocol ChatItemPresenterFactoryProtocol {
    func createChatItemPresenter(chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol
    func configure(withCollectionView collectionView: UICollectionView)
}

final class ChatItemPresenterFactory: ChatItemPresenterFactoryProtocol {
    var presenterBuildersByType = [ChatItemType: [ChatItemPresenterBuilderProtocol]]()
    
    init(presenterBuildersByType: [ChatItemType: [ChatItemPresenterBuilderProtocol]]) {
        self.presenterBuildersByType = presenterBuildersByType
    }
    
    func createChatItemPresenter(chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        for builder in self.presenterBuildersByType[chatItem.type] ?? [] {
            if builder.canHandleChatItem(chatItem) {
                return builder.createPresenterWithChatItem(chatItem)
            }
        }
        return DummyChatItemPresenter()
    }
    
    func configure(withCollectionView collectionView: UICollectionView) {
        for presenterBuilder in self.presenterBuildersByType.flatMap({ $0.1 }) {
            presenterBuilder.presenterType.registerCells(collectionView)
        }
        DummyChatItemPresenter.registerCells(collectionView)
    }
}
