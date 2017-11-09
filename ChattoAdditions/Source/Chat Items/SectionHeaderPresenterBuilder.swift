//
//  SectionHeaderPresenterBuilder.swift
//  Pods
//
//  Created by Denis Laboureyras on 18/12/2015.
//
//

import Foundation
import Chatto

open class SectionHeaderPresenterBuilder<ViewModelBuilderT, InteractionHandlerT>
: SectionItemPresenterBuilderProtocol where
    ViewModelBuilderT: SectionHeaderViewModelBuilderProtocol,
//    ViewModelBuilderT.ModelT: SectionHeaderModelProtocol,
//    ViewModelBuilderT.ViewModelT: SectionHeaderViewModelProtocol,
    InteractionHandlerT: SectionHeaderInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    typealias ViewModelT = ViewModelBuilderT.ViewModelT
    typealias ModelT = ViewModelBuilderT.ModelT
    
    public init(
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT? = nil) {
            self.viewModelBuilder = viewModelBuilder
            self.interactionHandler = interactionHandler
    }
    
    let viewModelBuilder: ViewModelBuilderT
    let interactionHandler: InteractionHandlerT?
    let layoutCache = NSCache<AnyObject, AnyObject>()
    
    lazy var sizingCell: SectionHeaderCollectionViewCell = {
        var cell: SectionHeaderCollectionViewCell? = nil
        if Thread.isMainThread {
            cell = SectionHeaderCollectionViewCell.sizingCell()
        } else {
            DispatchQueue.main.sync(execute: {
                cell =  SectionHeaderCollectionViewCell.sizingCell()
            })
        }
        
        return cell!
    }()
    
    open lazy var sectionHeaderStyle: SectionHeaderCollectionViewCellStyleProtocol = SectionHeaderCollectionViewCellDefaultSyle()
    
    open func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is SectionHeaderModelProtocol ? true : false
    }
    
    
    open func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> SectionItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return SectionHeaderPresenter<ViewModelBuilderT, InteractionHandlerT>(
            sectionHeaderModel: chatItem as! ModelT,
            viewModelBuilder: self.viewModelBuilder,
            interactionHandler: self.interactionHandler,
            sizingCell: sizingCell,
            cellStyle: self.sectionHeaderStyle
        )
    }
    
    open var presenterType: SectionItemPresenterProtocol.Type {
        return SectionHeaderPresenter<ViewModelBuilderT, InteractionHandlerT>.self
    }
}
