//
//  SectionHeaderCollectionViewCell.swift
//  Pods
//
//  Created by Denis Laboureyras on 18/12/2015.
//
//

import Foundation
import Chatto

public protocol SectionHeaderCollectionViewCellStyleProtocol {
    func attributedStringForDate(_ date: String) -> NSAttributedString
    func textFont(viewModel: SectionHeaderViewModelProtocol) -> UIFont
    func textColor(viewModel: SectionHeaderViewModelProtocol) -> UIColor
    func backgroundColor(viewModel: SectionHeaderViewModelProtocol) -> UIColor
    func height() -> CGFloat
    
}

public struct SectionHeaderCollectionViewCellLayoutConstants {
    let horizontalMargin: CGFloat = 11
    let horizontalInterspacing: CGFloat = 4
}


/**
 Base class for section headers
 
 */

open class SectionHeaderCollectionViewCell: UICollectionViewCell {
    
    open var animationDuration: CFTimeInterval = 0.33
    open var viewContext: ViewContext = .normal
    
    open static func sizingCell() -> SectionHeaderCollectionViewCell {
        let cell = SectionHeaderCollectionViewCell(frame: CGRect.zero)
        cell.viewContext = .sizing
        return cell
    }
    
    open fileprivate(set) var isUpdating: Bool = false
    open func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() ->())?) {
        self.isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
            if animated {
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animate(withDuration: self.animationDuration, animations: updateAndRefreshViews, completion: { (finished) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }
    
    var sectionHeaderViewModel: SectionHeaderViewModelProtocol! {
        didSet {
            updateViews()
        }
    }
    
    open var baseStyle: SectionHeaderCollectionViewCellStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }
    
    override open var isSelected: Bool {
        didSet {
            if oldValue != self.isSelected {
                self.updateViews()
            }
        }
    }
    
    var layoutConstants = SectionHeaderCollectionViewCellLayoutConstants() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    fileprivate var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white;
        label.backgroundColor = UIColor.darkGray
        label.layer.cornerRadius = 8;
        label.layer.masksToBounds = false;
        label.clipsToBounds = true;
        label.textAlignment = .center;
        label.text = "example"
        return label
    }()

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    open fileprivate(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SectionHeaderCollectionViewCell.bubbleTapped(_:)))
        return tapGestureRecognizer
    }()
    
    open var onBubbleTapped: ((_ cell: SectionHeaderCollectionViewCell) -> Void)?
    @objc
    func bubbleTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        self.onBubbleTapped?(self)
    }
    
    
    fileprivate func commonInit() {
        self.backgroundColor = UIColor.clear;
        self.contentView.isExclusiveTouch = true
        self.isExclusiveTouch = true
        let boundsLabel = CGRect(x: 10, y: 5, width: self.bounds.width - 20, height: self.bounds.height - 10)
        self.label.frame = boundsLabel;
        self.addSubview(self.label);
    }
    
    
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    // MARK: View model binding
    
    final fileprivate func updateViews() {
        if self.viewContext == .sizing { return }
        if self.isUpdating { return }
        guard let viewModel = self.sectionHeaderViewModel, let style = self.baseStyle else { return }
        self.accessoryTimestamp?.attributedText = style.attributedStringForDate(viewModel.date)
        
        self.label.textColor = style.textColor(viewModel: viewModel)
        self.label.backgroundColor = style.backgroundColor(viewModel: viewModel)
        self.label.font = style.textFont(viewModel: viewModel)
        
        if self.label.text != viewModel.text {self.label.text = viewModel.text}
        
        self.setNeedsLayout()
    }
    
    // MARK: layout
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        //let layoutModel = self.calculateLayout(availableWidth: self.contentView.bounds.width)
        
        // TODO: refactor accessorView?
        
        if let accessoryView = self.accessoryTimestamp {
            accessoryView.bounds = CGRect(origin: CGPoint.zero, size: accessoryView.intrinsicContentSize)
            let accessoryViewWidth = accessoryView.bounds.width
            let accessoryViewMargin: CGFloat = 10
            let leftDisplacement = max(0, min(self.timestampMaxVisibleOffset, accessoryViewWidth + accessoryViewMargin))
            var contentViewframe = self.contentView.frame
            
            contentViewframe.origin.x = -leftDisplacement
            
            self.contentView.frame = contentViewframe
            accessoryView.center = CGPoint(x: self.bounds.width - leftDisplacement + accessoryViewWidth / 2, y: self.contentView.center.y)
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.calculateLayout(availableWidth: size.width).size
    }
    
    fileprivate func calculateLayout(availableWidth: CGFloat) -> SectionHeaderLayoutModel {
        let parameters = SectionHeaderLayoutModelParameters(
            containerWidth: availableWidth,
            containerHeight: 30,
            horizontalMargin: self.layoutConstants.horizontalMargin,
            horizontalInterspacing: self.layoutConstants.horizontalInterspacing
        )
        var layoutModel = SectionHeaderLayoutModel()
        layoutModel.calculateLayout(parameters: parameters)
        return layoutModel
    }
    
    // MARK: timestamp revealing
    var timestampMaxVisibleOffset: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    var accessoryTimestamp: UILabel?
    open func revealAccessoryView(maximumOffset offset: CGFloat, animated: Bool) {
        if self.accessoryTimestamp == nil {
            if offset > 0 {
                let accessoryTimestamp = UILabel()
                accessoryTimestamp.attributedText = self.baseStyle?.attributedStringForDate(self.sectionHeaderViewModel.date)
                self.addSubview(accessoryTimestamp)
                self.accessoryTimestamp = accessoryTimestamp
                self.layoutIfNeeded()
            }
            
            if animated {
                UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                    self.timestampMaxVisibleOffset = offset
                    self.layoutIfNeeded()
                })
            } else {
                self.timestampMaxVisibleOffset = offset
            }
        } else {
            if animated {
                UIView.animate(withDuration: self.animationDuration, animations: { () -> Void in
                    self.timestampMaxVisibleOffset = offset
                    self.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        if offset == 0 {
                            self.removeAccessoryView()
                        }
                })
                
            } else {
                self.timestampMaxVisibleOffset = offset
            }
        }
    }
    
    func removeAccessoryView() {
        self.accessoryTimestamp?.removeFromSuperview()
        self.accessoryTimestamp = nil
    }
    
    
}

struct SectionHeaderLayoutModel {
    fileprivate (set) var size = CGSize.zero
    
    mutating func calculateLayout(parameters: SectionHeaderLayoutModelParameters) {
        let containerWidth = parameters.containerWidth
        let containerHeight = parameters.containerHeight
        let horizontalMargin = parameters.horizontalMargin

        let containerRect = CGRect(origin: CGPoint(x: horizontalMargin, y: 0), size: CGSize(width: containerWidth - horizontalMargin * 2, height: containerHeight))
        
        
        // Adjust horizontal positions
        
        self.size = containerRect.size

    }
}

struct SectionHeaderLayoutModelParameters {
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let horizontalMargin: CGFloat
    let horizontalInterspacing: CGFloat
}
