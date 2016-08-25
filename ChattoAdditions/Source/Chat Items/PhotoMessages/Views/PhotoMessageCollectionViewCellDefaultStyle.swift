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

open class PhotoMessageCollectionViewCellDefaultStyle: PhotoMessageCollectionViewCellStyleProtocol {

    fileprivate struct Constants {
        let tailWidth: CGFloat = 6.0
        let aspectRatioIntervalForSquaredSize: ClosedRange<CGFloat> = 0.90...1.10
        let photoSizeLandscape = CGSize(width: 210, height: 136)
        let photoSizePortratit = CGSize(width: 136, height: 210)
        let photoSizeSquare = CGSize(width: 210, height: 210)
        let placeholderIconTintIncoming = UIColor.bma_color(rgb: 0xced6dc)
        let placeholderIconTintOugoing = UIColor.bma_color(rgb: 0x508dfc)
        let progressIndicatorColorIncoming = UIColor.bma_color(rgb: 0x98a3ab)
        let progressIndicatorColorOutgoing = UIColor.white
        let overlayColor = UIColor.black.withAlphaComponent(0.70)
    }

    lazy fileprivate var styleConstants = Constants()
    lazy fileprivate var baseStyle = BaseMessageCollectionViewCellDefaultSyle()

    lazy fileprivate var maskImageIncomingTail: UIImage = {
        return UIImage(named: "bubble-incoming-tail", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()

    lazy fileprivate var maskImageIncomingNoTail: UIImage = {
        return UIImage(named: "bubble-incoming", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()

    lazy fileprivate var maskImageOutgoingTail: UIImage = {
        return UIImage(named: "bubble-outgoing-tail", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()

    lazy fileprivate var maskImageOutgoingNoTail: UIImage = {
        return UIImage(named: "bubble-outgoing", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()

    lazy fileprivate var placeholderBackgroundIncoming: UIImage = {
        return UIImage.bma_imageWithColor(self.baseStyle.baseColorIncoming, size: CGSize(width: 1, height: 1))
    }()

    lazy fileprivate var placeholderBackgroundOutgoing: UIImage = {
        return UIImage.bma_imageWithColor(self.baseStyle.baseColorOutgoing, size: CGSize(width: 1, height: 1))
    }()

    lazy fileprivate var placeholderIcon: UIImage = {
        return UIImage(named: "photo-bubble-placeholder-icon", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()

    open func maskingImage(viewModel: PhotoMessageViewModelProtocol) -> UIImage {
        switch (viewModel.isIncoming, viewModel.showsTail) {
        case (true, true):
            return self.maskImageIncomingTail
        case (true, false):
            return self.maskImageIncomingNoTail
        case (false, true):
            return self.maskImageOutgoingTail
        case (false, false):
            return self.maskImageOutgoingNoTail
        }
    }

    open func borderImage(viewModel: PhotoMessageViewModelProtocol) -> UIImage? {
        return self.baseStyle.borderImage(viewModel: viewModel)
    }

    open func placeholderBackgroundImage(viewModel: PhotoMessageViewModelProtocol) -> UIImage {
        return viewModel.isIncoming ? self.placeholderBackgroundIncoming : self.placeholderBackgroundOutgoing
    }

    open func placeholderIconImage(viewModel: PhotoMessageViewModelProtocol) -> (icon: UIImage?, tintColor: UIColor?) {
        if viewModel.image.value == nil && viewModel.transferStatus.value == .failed {
            let tintColor = viewModel.isIncoming ? self.styleConstants.placeholderIconTintIncoming : self.styleConstants.placeholderIconTintOugoing
            return (self.placeholderIcon, tintColor)
        }
        return (nil, nil)
    }

    open func tailWidth(viewModel: PhotoMessageViewModelProtocol) -> CGFloat {
        return self.styleConstants.tailWidth
    }

    open func bubbleSize(viewModel: PhotoMessageViewModelProtocol) -> CGSize {
        let aspectRatio = viewModel.imageSize.height > 0 ? viewModel.imageSize.width / viewModel.imageSize.height : 0

        if aspectRatio == 0 || self.styleConstants.aspectRatioIntervalForSquaredSize.contains(aspectRatio) {
            return self.styleConstants.photoSizeSquare
        } else if aspectRatio < self.styleConstants.aspectRatioIntervalForSquaredSize.lowerBound {
            return self.styleConstants.photoSizePortratit
        } else {
            return self.styleConstants.photoSizeLandscape
        }
    }

    open func progressIndicatorColor(viewModel: PhotoMessageViewModelProtocol) -> UIColor {
        return viewModel.isIncoming ? self.styleConstants.progressIndicatorColorIncoming : self.styleConstants.progressIndicatorColorOutgoing
    }

    open func overlayColor(viewModel: PhotoMessageViewModelProtocol) -> UIColor? {
        let showsOverlay = viewModel.image.value != nil && (viewModel.transferStatus.value == .transfering || viewModel.status != MessageViewModelStatus.success)
        return showsOverlay ? self.styleConstants.overlayColor : nil
    }

}
