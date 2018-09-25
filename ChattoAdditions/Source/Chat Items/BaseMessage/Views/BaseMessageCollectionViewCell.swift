/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit
import Chatto

public protocol BaseMessageCollectionViewCellStyleProtocol {
    var failedIcon: UIImage { get }
    var failedIconHighlighted: UIImage { get }
    func attributedStringForDate(_ date: String) -> NSAttributedString
}

public struct BaseMessageCollectionViewCellLayoutConstants {
    let horizontalMargin: CGFloat = 11
    let horizontalInterspacing: CGFloat = 4
    let maxContainerWidthPercentageForBubbleView: CGFloat = 0.68
}


/**
    Base class for message cells

    Provides:

        - Reveleable timestamp layout logic
        - Failed view
        - Incoming/outcoming layout

    Subclasses responsability
        - Implement createBubbleView
        - Have a BubbleViewType that responds properly to sizeThatFits:
*/

open class BaseMessageCollectionViewCell<BubbleViewType>: UICollectionViewCell, BackgroundSizingQueryable, AccessoryViewRevealable, UIGestureRecognizerDelegate where BubbleViewType:UIView, BubbleViewType:MaximumLayoutWidthSpecificable, BubbleViewType: BackgroundSizingQueryable {
    
    public var allowAccessoryViewRevealing: Bool = true


    open var animationDuration: CFTimeInterval = 0.33
    open var viewContext: ViewContext = .normal
    
    

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

    var messageViewModel: MessageViewModelProtocol! {
        didSet {
            updateViews()
        }
    }

    var failedIcon: UIImage!
    var failedIconHighlighted: UIImage!
    open var baseStyle: BaseMessageCollectionViewCellStyleProtocol! {
        didSet {
            self.failedIcon = self.baseStyle.failedIcon
            self.failedIconHighlighted = self.baseStyle.failedIconHighlighted
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

    var layoutConstants = BaseMessageCollectionViewCellLayoutConstants() {
        didSet {
            self.setNeedsLayout()
        }
    }

    open var canCalculateSizeInBackground: Bool {
        return self.bubbleView.canCalculateSizeInBackground
    }

    open fileprivate(set) var bubbleView: BubbleViewType!
    func createBubbleView() -> BubbleViewType! {
        assert(false, "Override in subclass")
        return nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    open fileprivate(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BaseMessageCollectionViewCell.bubbleTapped(_:)))
        return tapGestureRecognizer
    }()

    open fileprivate (set) lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let longpressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(BaseMessageCollectionViewCell.bubbleLongPressed(_:)))
        longpressGestureRecognizer.delegate = self
        return longpressGestureRecognizer
    }()

    fileprivate func commonInit() {
        self.bubbleView = self.createBubbleView()
        self.bubbleView.addGestureRecognizer(self.tapGestureRecognizer)
        self.bubbleView.addGestureRecognizer(self.longPressGestureRecognizer)
        self.contentView.addSubview(self.bubbleView)
        self.contentView.addSubview(self.failedButton)
        self.contentView.isExclusiveTouch = true
        self.isExclusiveTouch = true
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return self.bubbleView.bounds.contains(touch.location(in: self.bubbleView))
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer === self.longPressGestureRecognizer
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.removeAccessoryView()
    }

    fileprivate lazy var failedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(BaseMessageCollectionViewCell.failedButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: View model binding

    final fileprivate func updateViews() {
        if self.viewContext == .sizing { return }
        if self.isUpdating { return }
        guard let viewModel = self.messageViewModel, let style = self.baseStyle else { return }
        if viewModel.showsFailedIcon {
            self.failedButton.setImage(self.failedIcon, for: UIControl.State())
            self.failedButton.setImage(self.failedIconHighlighted, for: .highlighted)
            self.failedButton.alpha = 1
        } else {
            self.failedButton.alpha = 0
        }
        self.accessoryTimestamp?.attributedText = style.attributedStringForDate(viewModel.date)
        self.setNeedsLayout()
    }

    // MARK: layout
    open override func layoutSubviews() {
        super.layoutSubviews()

        let layoutModel = self.calculateLayout(availableWidth: self.contentView.bounds.width)
        self.failedButton.bma_rect = layoutModel.failedViewFrame
        self.bubbleView.bma_rect = layoutModel.bubbleViewFrame
        self.bubbleView.preferredMaxLayoutWidth = layoutModel.preferredMaxWidthForBubble
        self.bubbleView.layoutIfNeeded()

        // TODO: refactor accessorView?

        if let accessoryView = self.accessoryTimestamp {
            accessoryView.bounds = CGRect(origin: CGPoint.zero, size: accessoryView.intrinsicContentSize)
            let accessoryViewWidth = accessoryView.bounds.width
            let accessoryViewMargin: CGFloat = 10
            let leftDisplacement = max(0, min(self.timestampMaxVisibleOffset, accessoryViewWidth + accessoryViewMargin))
            var contentViewframe = self.contentView.frame
            if self.messageViewModel.isIncoming {
                contentViewframe.origin = CGPoint.zero
            } else {
                contentViewframe.origin.x = -leftDisplacement
            }
            self.contentView.frame = contentViewframe
            accessoryView.center = CGPoint(x: self.bounds.width - leftDisplacement + accessoryViewWidth / 2, y: self.contentView.center.y)
        }
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.calculateLayout(availableWidth: size.width).size
    }

    fileprivate func calculateLayout(availableWidth: CGFloat) -> BaseMessageLayoutModel {
        let parameters = BaseMessageLayoutModelParameters(
            containerWidth: availableWidth,
            horizontalMargin: self.layoutConstants.horizontalMargin,
            horizontalInterspacing: self.layoutConstants.horizontalInterspacing,
            failedButtonSize: self.failedIcon.size,
            maxContainerWidthPercentageForBubbleView: self.layoutConstants.maxContainerWidthPercentageForBubbleView,
            bubbleView: self.bubbleView,
            isIncoming: self.messageViewModel.isIncoming,
            isFailed: self.messageViewModel.showsFailedIcon
        )
        var layoutModel = BaseMessageLayoutModel()
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
    open func revealAccessoryView(withOffset offset: CGFloat, animated: Bool) {
        if self.accessoryTimestamp == nil {
            if offset > 0 {
                let accessoryTimestamp = UILabel()
                accessoryTimestamp.attributedText = self.baseStyle?.attributedStringForDate(self.messageViewModel.date)
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
    
    open func preferredOffsetToRevealAccessoryView() -> CGFloat? {
        return nil
    }

    func removeAccessoryView() {
        self.accessoryTimestamp?.removeFromSuperview()
        self.accessoryTimestamp = nil
    }


    // MARK: User interaction
    open var onFailedButtonTapped: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
    @objc
    func failedButtonTapped() {
        self.onFailedButtonTapped?(self)
    }

    open var onBubbleTapped: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
    @objc
    func bubbleTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        self.onBubbleTapped?(self)
    }

    open var onBubbleLongPressed: ((_ cell: BaseMessageCollectionViewCell) -> Void)?
    @objc
    fileprivate func bubbleLongPressed(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            self.bubbleLongPressed()
        }
    }

    func bubbleLongPressed() {
        self.onBubbleLongPressed?(self)
    }
}

struct BaseMessageLayoutModel {
    fileprivate (set) var size = CGSize.zero
    fileprivate (set) var failedViewFrame = CGRect.zero
    fileprivate (set) var bubbleViewFrame = CGRect.zero
    fileprivate (set) var preferredMaxWidthForBubble: CGFloat = 0

    mutating func calculateLayout(parameters: BaseMessageLayoutModelParameters) {
        let containerWidth = parameters.containerWidth
        let isIncoming = parameters.isIncoming
        let isFailed = parameters.isFailed
        let failedButtonSize = parameters.failedButtonSize
        let bubbleView = parameters.bubbleView
        let horizontalMargin = parameters.horizontalMargin
        let horizontalInterspacing = parameters.horizontalInterspacing

        let preferredWidthForBubble = containerWidth * parameters.maxContainerWidthPercentageForBubbleView
        let bubbleSize = bubbleView.sizeThatFits(CGSize(width: preferredWidthForBubble, height: CGFloat.greatestFiniteMagnitude))
        let containerRect = CGRect(origin: CGPoint.zero, size: CGSize(width: containerWidth, height: bubbleSize.height))


        self.bubbleViewFrame = bubbleSize.bma_rect(inContainer: containerRect, xAlignament: .center, yAlignment: .center, dx: 0, dy: 0)
        self.failedViewFrame = failedButtonSize.bma_rect(inContainer: containerRect, xAlignament: .center, yAlignment: .center, dx: 0, dy: 0)

        // Adjust horizontal positions

        var currentX: CGFloat = 0
        if isIncoming {
            currentX = horizontalMargin
            if isFailed {
                self.failedViewFrame.origin.x = currentX
                currentX += failedButtonSize.width
                currentX += horizontalInterspacing
            } else {
                self.failedViewFrame.origin.x = -failedButtonSize.width
            }
            self.bubbleViewFrame.origin.x = currentX
        } else {
            currentX = containerRect.maxX - horizontalMargin
            if isFailed {
                currentX -= failedButtonSize.width
                self.failedViewFrame.origin.x = currentX
                currentX -= horizontalInterspacing
            } else {
                self.failedViewFrame.origin.x = containerRect.width - -failedButtonSize.width
            }
            currentX -= bubbleSize.width
            self.bubbleViewFrame.origin.x = currentX
        }

        self.size = containerRect.size
        self.preferredMaxWidthForBubble = preferredWidthForBubble
    }
}

struct BaseMessageLayoutModelParameters {
    let containerWidth: CGFloat
    let horizontalMargin: CGFloat
    let horizontalInterspacing: CGFloat
    let failedButtonSize: CGSize
    let maxContainerWidthPercentageForBubbleView: CGFloat // in [0, 1]
    let bubbleView: UIView
    let isIncoming: Bool
    let isFailed: Bool
}
