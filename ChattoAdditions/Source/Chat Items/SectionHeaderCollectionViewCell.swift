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
    func attributedStringForDate(date: String) -> NSAttributedString
    func textFont(viewModel viewModel: SectionHeaderViewModelProtocol) -> UIFont
    func textColor(viewModel viewModel: SectionHeaderViewModelProtocol) -> UIColor
    func backgroundColor(viewModel viewModel: SectionHeaderViewModelProtocol) -> UIColor
    
}

public struct SectionHeaderCollectionViewCellLayoutConstants {
    let horizontalMargin: CGFloat = 11
    let horizontalInterspacing: CGFloat = 4
}


/**
 Base class for section headers
 
 */

public class SectionHeaderCollectionViewCell: UICollectionViewCell {
    
    public var animationDuration: CFTimeInterval = 0.33
    public var viewContext: ViewContext = .Normal
    
    public static func sizingCell() -> SectionHeaderCollectionViewCell {
        let cell = SectionHeaderCollectionViewCell(frame: CGRectZero)
        cell.viewContext = .Sizing
        return cell
    }
    
    public private(set) var isUpdating: Bool = false
    public func performBatchUpdates(updateClosure: () -> Void, animated: Bool, completion: (() ->())?) {
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
            UIView.animateWithDuration(self.animationDuration, animations: updateAndRefreshViews, completion: { (finished) -> Void in
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
    
    public var baseStyle: SectionHeaderCollectionViewCellStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }
    
    override public var selected: Bool {
        didSet {
            if oldValue != self.selected {
                self.updateViews()
            }
        }
    }
    
    var layoutConstants = SectionHeaderCollectionViewCellLayoutConstants() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.whiteColor();
        label.backgroundColor = UIColor.darkGrayColor()
        label.layer.cornerRadius = 8;
        label.layer.masksToBounds = false;
        label.clipsToBounds = true;
        label.textAlignment = .Center;
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
    
    public private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "bubbleTapped:")
        return tapGestureRecognizer
    }()
    
    
    private func commonInit() {
        self.backgroundColor = UIColor.clearColor();
        self.contentView.exclusiveTouch = true
        self.exclusiveTouch = true
        let boundsLabel = CGRectMake(10, 5, self.bounds.width - 20, self.bounds.height - 10)
        self.label.frame = boundsLabel;
        self.addSubview(self.label);
    }
    
    
    public override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    // MARK: View model binding
    
    final private func updateViews() {
        if self.viewContext == .Sizing { return }
        if self.isUpdating { return }
        guard let viewModel = self.sectionHeaderViewModel, style = self.baseStyle else { return }
        self.accessoryTimestamp?.attributedText = style.attributedStringForDate(viewModel.date)
        
        self.label.textColor = style.textColor(viewModel: viewModel)
        self.label.backgroundColor = style.backgroundColor(viewModel: viewModel)
        self.label.font = style.textFont(viewModel: viewModel)
        
        if self.label.text != viewModel.text {self.label.text = viewModel.text}
        
        self.setNeedsLayout()
    }
    
    // MARK: layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        //let layoutModel = self.calculateLayout(availableWidth: self.contentView.bounds.width)
        
        // TODO: refactor accessorView?
        
        if let accessoryView = self.accessoryTimestamp {
            accessoryView.bounds = CGRect(origin: CGPointZero, size: accessoryView.intrinsicContentSize())
            let accessoryViewWidth = CGRectGetWidth(accessoryView.bounds)
            let accessoryViewMargin: CGFloat = 10
            let leftDisplacement = max(0, min(self.timestampMaxVisibleOffset, accessoryViewWidth + accessoryViewMargin))
            var contentViewframe = self.contentView.frame
            
            contentViewframe.origin.x = -leftDisplacement
            
            self.contentView.frame = contentViewframe
            accessoryView.center = CGPoint(x: CGRectGetWidth(self.bounds) - leftDisplacement + accessoryViewWidth / 2, y: self.contentView.center.y)
        }
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        return self.calculateLayout(availableWidth: size.width).size
    }
    
    private func calculateLayout(availableWidth availableWidth: CGFloat) -> SectionHeaderLayoutModel {
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
    public func revealAccessoryView(maximumOffset offset: CGFloat, animated: Bool) {
        if self.accessoryTimestamp == nil {
            if offset > 0 {
                let accessoryTimestamp = UILabel()
                accessoryTimestamp.attributedText = self.baseStyle?.attributedStringForDate(self.sectionHeaderViewModel.date)
                self.addSubview(accessoryTimestamp)
                self.accessoryTimestamp = accessoryTimestamp
                self.layoutIfNeeded()
            }
            
            if animated {
                UIView.animateWithDuration(self.animationDuration, animations: { () -> Void in
                    self.timestampMaxVisibleOffset = offset
                    self.layoutIfNeeded()
                })
            } else {
                self.timestampMaxVisibleOffset = offset
            }
        } else {
            if animated {
                UIView.animateWithDuration(self.animationDuration, animations: { () -> Void in
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
    private (set) var size = CGSizeZero
    
    mutating func calculateLayout(parameters parameters: SectionHeaderLayoutModelParameters) {
        let containerWidth = parameters.containerWidth
        let containerHeight = parameters.containerHeight
        let horizontalMargin = parameters.horizontalMargin

        let containerRect = CGRect(origin: CGPointMake(horizontalMargin, 0), size: CGSize(width: containerWidth - horizontalMargin * 2, height: containerHeight))
        
        
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