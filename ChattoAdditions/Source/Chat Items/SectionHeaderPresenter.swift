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
    typealias ModelT: SectionHeaderModelProtocol
    typealias ViewModelT: SectionHeaderViewModelProtocol
    func createSectionHeaderViewModel(sectionHeader: ModelT) -> ViewModelT
}



public protocol SectionHeaderInteractionHandlerProtocol {
    typealias ViewModelT
    func userDidTapOnFailIcon(viewModel viewModel: ViewModelT)
    func userDidTapOnBubble(viewModel viewModel: ViewModelT)
    func userDidLongPressOnBubble(viewModel viewModel: ViewModelT)
}

public class SectionHeaderPresenter<ViewModelBuilderT, InteractionHandlerT where
    ViewModelBuilderT: SectionHeaderViewModelBuilderProtocol,
    ViewModelBuilderT.ModelT: SectionHeaderModelProtocol,
    ViewModelBuilderT.ViewModelT: SectionHeaderViewModelProtocol,
    InteractionHandlerT: SectionHeaderInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT> : BaseSectionItemPresenter<SectionHeaderCollectionViewCell> {
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
    
    public override class func registerCells(collectionView: UICollectionView) {
        collectionView.registerClass(SectionHeaderCollectionViewCell.self, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier: "section-header")
    }
    
    override public var canCalculateHeightInBackground: Bool {
        return true
    }
    
    override public func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return cellStyle.height()
    }
    
    public override func dequeueCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "section-header", forIndexPath: indexPath)
    }
    
    public private(set) final lazy var sectionHeaderViewModel: ViewModelT = {
        return self.createViewModel()
    }()
    
    public func createViewModel() -> ViewModelT {
        let viewModel = self.viewModelBuilder.createSectionHeaderViewModel(self.sectionHeaderModel)
        return viewModel
    }
    
    public final override func configureCell(cell: UICollectionReusableView, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
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
    public func configureCell(cell: CellT, decorationAttributes: ChatItemDecorationAttributes, animated: Bool, additionalConfiguration: (() -> Void)?) {
        cell.performBatchUpdates({ () -> Void in

            cell.baseStyle = self.cellStyle
            cell.sectionHeaderViewModel = self.sectionHeaderViewModel
            additionalConfiguration?()
        }, animated: animated, completion: nil)
    }
    
  }