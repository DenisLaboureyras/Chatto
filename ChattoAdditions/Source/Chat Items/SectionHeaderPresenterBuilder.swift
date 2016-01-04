//
//  SectionHeaderPresenterBuilder.swift
//  Pods
//
//  Created by Denis Laboureyras on 18/12/2015.
//
//

import Foundation
import Chatto

public class SectionHeaderPresenterBuilder<ViewModelBuilderT, InteractionHandlerT where
    ViewModelBuilderT: SectionHeaderViewModelBuilderProtocol,
    ViewModelBuilderT.ModelT: SectionHeaderModelProtocol,
    ViewModelBuilderT.ViewModelT: SectionHeaderViewModelProtocol,
    InteractionHandlerT: SectionHeaderInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT>
: SectionItemPresenterBuilderProtocol {
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
    let layoutCache = NSCache()
    
    lazy var sizingCell: SectionHeaderCollectionViewCell = {
        var cell: SectionHeaderCollectionViewCell? = nil
        if NSThread.isMainThread() {
            cell = SectionHeaderCollectionViewCell.sizingCell()
        } else {
            dispatch_sync(dispatch_get_main_queue(), {
                cell =  SectionHeaderCollectionViewCell.sizingCell()
            })
        }
        
        return cell!
    }()
    
    public lazy var sectionHeaderStyle: SectionHeaderCollectionViewCellStyleProtocol = SectionHeaderCollectionViewCellDefaultSyle()
    
    public func canHandleChatItem(chatItem: ChatItemProtocol) -> Bool {
        return chatItem is SectionHeaderModelProtocol ? true : false
    }
    
    
    public func createPresenterWithChatItem(chatItem: ChatItemProtocol) -> SectionItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return SectionHeaderPresenter<ViewModelBuilderT, InteractionHandlerT>(
            sectionHeaderModel: chatItem as! ModelT,
            viewModelBuilder: self.viewModelBuilder,
            interactionHandler: self.interactionHandler,
            sizingCell: sizingCell,
            cellStyle: self.sectionHeaderStyle
        )
    }
    
    public var presenterType: SectionItemPresenterProtocol.Type {
        return SectionHeaderPresenter<ViewModelBuilderT, InteractionHandlerT>.self
    }
}