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

import Foundation

@objc open class PhotosChatInputItem: NSObject {
    open var photoInputHandler: ((UIImage) -> Void)?
    open weak var presentingController: UIViewController?
    public init(presentingController: UIViewController?) {
        self.presentingController = presentingController
    }

    lazy fileprivate var internalTabView: UIButton = {
        var button = UIButton(type: .custom)
        button.isExclusiveTouch = true
        button.setImage(UIImage(named: "camera-icon-unselected", in: Bundle(for: type(of: self)), compatibleWith: nil), for: UIControl.State())
        button.setImage(UIImage(named: "camera-icon-selected", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .highlighted)
        button.setImage(UIImage(named: "camera-icon-selected", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .selected)
        return button
    }()

    lazy var photosInputView: PhotosInputViewProtocol = {
        let photosInputView = PhotosInputView(presentingController: self.presentingController)
        photosInputView.delegate = self
        return photosInputView
    }()

    open var selected = false {
        didSet {
            self.internalTabView.isSelected = self.selected;
            if self.selected != oldValue {
                self.photosInputView.reload()
            }
        }
    }
}

// MARK: - ChatInputItemProtocol
extension PhotosChatInputItem : ChatInputItemProtocol {
    public var presentationMode: ChatInputItemPresentationMode {
        return .customView
    }

    public var showsSendButton: Bool {
        return false
    }

    public var inputView: UIView? {
        return self.photosInputView as? UIView
    }

    public var tabView: UIView {
        return self.internalTabView
    }

    public func handleInput(_ input: AnyObject) {
        if let image = input as? UIImage {
            self.photoInputHandler?(image)
        }
    }
}

// MARK: - PhotosChatInputCollectionViewWrapperDelegate
extension PhotosChatInputItem: PhotosInputViewDelegate {
    func inputView(_ inputView: PhotosInputViewProtocol, didSelectImage image: UIImage) {
        self.photoInputHandler?(image)
    }
}
