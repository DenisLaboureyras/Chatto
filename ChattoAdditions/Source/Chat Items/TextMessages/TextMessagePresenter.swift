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

open class TextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>
: BaseMessagePresenter<TextBubbleView, ViewModelBuilderT, InteractionHandlerT> where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ModelT: TextMessageModelProtocol,
    ViewModelBuilderT.ViewModelT: TextMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    public typealias ModelT = ViewModelBuilderT.ModelT
    public typealias ViewModelT = ViewModelBuilderT.ViewModelT

    public init (
        messageModel: ModelT,
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT?,
        sizingCell: TextMessageCollectionViewCell,
        baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
        textCellStyle: TextMessageCollectionViewCellStyleProtocol,
        layoutCache: NSCache<AnyObject, AnyObject>) {
            self.layoutCache = layoutCache
            self.textCellStyle = textCellStyle
            super.init(
                messageModel: messageModel,
                viewModelBuilder: viewModelBuilder,
                interactionHandler: interactionHandler,
                sizingCell: sizingCell,
                cellStyle: baseCellStyle
            )
    }

    let layoutCache: NSCache<AnyObject, AnyObject>
    let textCellStyle: TextMessageCollectionViewCellStyleProtocol

    open override class func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(TextMessageCollectionViewCell.self, forCellWithReuseIdentifier: "text-message-incoming")
        collectionView.register(TextMessageCollectionViewCell.self, forCellWithReuseIdentifier: "text-message-outcoming")
    }

    open override func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = self.messageViewModel.isIncoming ? "text-message-incoming" : "text-message-outcoming"
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    open override func configureCell(_ cell: BaseMessageCollectionViewCell<TextBubbleView>, decorationAttributes: ChatItemDecorationAttributes,  animated: Bool, additionalConfiguration: (() -> Void)?) {
        guard let cell = cell as? TextMessageCollectionViewCell else {
            assert(false, "Invalid cell received")
            return
        }

        super.configureCell(cell, decorationAttributes: decorationAttributes, animated: animated) { () -> Void in
            cell.layoutCache = self.layoutCache
            cell.textMessageViewModel = self.messageViewModel
            cell.textMessageStyle = self.textCellStyle
            additionalConfiguration?()
        }
    }

    open override func canShowMenu() -> Bool {
        return true
    }

    open override func canPerformMenuControllerAction(_ action: Selector) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy(_:))
    }

    open override func performMenuControllerAction(_ action: Selector) {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            UIPasteboard.general.string = self.messageViewModel.text
        } else {
            assert(false, "Unexpected action")
        }
    }
}
