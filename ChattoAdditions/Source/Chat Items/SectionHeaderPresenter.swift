//
//  SectionHeaderPresenter.swift
//  Pods
//
//  Created by Denis Laboureyras on 18/12/2015.
//
//

import Foundation
import Chatto


public protocol SectionHeaderViewModelBuilderProtocol {
    associatedtype ModelT: SectionHeaderModelProtocol
    associatedtype ViewModelT: SectionHeaderViewModelProtocol
    func createSectionHeaderViewModel(_ sectionHeader: ModelT) -> ViewModelT
}



public protocol SectionHeaderInteractionHandlerProtocol {
    associatedtype ViewModelT
    func userDidTapOnFailIcon(viewModel: ViewModelT)
    func userDidTapOnBubble(viewModel: ViewModelT)
    func userDidLongPressOnBubble(viewModel: ViewModelT)
}

open class SectionHeaderPresenter<ViewModelBuilderT, InteractionHandlerT> : BaseSectionItemPresenter<SectionHeaderCollectionViewCell> where
    ViewModelBuilderT: SectionHeaderViewModelBuilderProtocol,
    ViewModelBuilderT.ModelT: SectionHeaderModelProtocol,
    ViewModelBuilderT.ViewModelT: SectionHeaderViewModelProtocol,
    InteractionHandlerT: SectionHeaderInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    public typealias CellT = SectionHeaderCollectionViewCell
    public typealias ModelT = ViewModelBuilderT.ModelT
    public typealias ViewModelT = ViewModelBuilderT.ViewModelT
    
    public init (
        sectionHeaderModel: ModelT,
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT?,
        sizingCell: SectionHeaderCollectionViewCell,
        cellStyle: SectionHeaderCollectionViewCellStyleProtocol) {
            self.sectionHeaderModel = sectionHeaderModel
            self.sizingCell = sizingCell
            self.viewModelBuilder = viewModelBuilder
            self.cellStyle = cellStyle
            self.interactionHandler = interactionHandler
    }
    
    let sectionHeaderModel: ModelT
    let sizingCell: SectionHeaderCollectionViewCell
    let viewModelBuilder: ViewModelBuilderT
    let interactionHandler: InteractionHandlerT?
    let cellStyle: SectionHeaderCollectionViewCellStyleProtocol
    
    open override class func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(SectionHeaderCollectionViewCell.self, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "section-header")
    }
    
    override open var canCalculateHeightInBackground: Bool {
        return true
    }
    
    override open func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return cellStyle.height()
    }
    
    open override func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "section-header", for: indexPath)
    }
    
    public fileprivate(set) final lazy var sectionHeaderViewModel: ViewModelT = {
        return self.createViewModel()
    }()
    
    open func createViewModel() -> ViewModelT {
        let viewModel = self.viewModelBuilder.createSectionHeaderViewModel(self.sectionHeaderModel)
        return viewModel
    }
    
    public final override func configureCell(_ cell: UICollectionReusableView, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let cell = cell as? CellT else {
            assert(false, "Invalid cell given to presenter")
            return
        }
        guard let decorationAttributes = decorationAttributes as? ChatItemDecorationAttributes else {
            assert(false, "Expecting decoration attributes")
            return
        }
        
        self.decorationAttributes = decorationAttributes
        self.configureCell(cell, decorationAttributes: decorationAttributes, animated: false, additionalConfiguration: nil)
    }
    
    var decorationAttributes: ChatItemDecorationAttributes!
    open func configureCell(_ cell: CellT, decorationAttributes: ChatItemDecorationAttributes, animated: Bool, additionalConfiguration: (() -> Void)?) {
        cell.performBatchUpdates({ () -> Void in

            cell.baseStyle = self.cellStyle
            cell.sectionHeaderViewModel = self.sectionHeaderViewModel
            additionalConfiguration?()
        }, animated: animated, completion: nil)
    }
    
  }
