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
import Chatto

class FakeDataSource: ChatDataSourceProtocol {
    
   
    var lastMessageId: Int = 0
    let preferredMaxWindowSize = 500

    var slidingWindow: SlidingDataSource!
    init(count: Int, pageSize: Int) {
        self.slidingWindow = SlidingDataSource(count: count, pageSize: pageSize) { () -> ChatItemProtocol in
            self.lastMessageId += 1;
            return FakeMessageFactory.createChatItem("\(self.lastMessageId)")
        }
    }

    init(messages: [ChatItemProtocol], pageSize: Int) {
        self.slidingWindow = SlidingDataSource(items: messages, pageSize: pageSize)
    }
    
    init(sections: [SectionItemProtocol], pageSize: Int) {
        self.slidingWindow = SlidingDataSource(sectionsItems: sections, pageSize: pageSize)
    }

    lazy var messageSender: FakeMessageSender = {
        let sender = FakeMessageSender()
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf, updateType: .Normal)
        }
        return sender
    }()

    var hasMoreNext: Bool {
        return self.slidingWindow.hasMore()
    }

    var hasMorePrevious: Bool {
        return self.slidingWindow.hasPrevious()
    }

    var sectionItems: [SectionItemProtocol] {
        return self.slidingWindow.itemsInWindow
    }

    weak var delegate: ChatDataSourceDelegateProtocol?

    func loadNext() {
        self.slidingWindow.loadNext()
        self.slidingWindow.adjustWindow(focusPosition: 1, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .Pagination)
        
    }

    func loadPrevious() {
        self.slidingWindow.loadPrevious()
        self.slidingWindow.adjustWindow(focusPosition: 0, maxWindowSize: self.preferredMaxWindowSize)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .Pagination)
    }

    func addTextMessage(text: String) {
        self.lastMessageId += 1;
        let uid = "\(self.lastMessageId)"
        let message = createTextMessageModel(uid, text: text, isIncoming: false)
        self.messageSender.sendMessage(message)
        self.slidingWindow.insertItem(message, position: .Bottom)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .Normal)
    }

    func addPhotoMessage(image: UIImage) {
        self.lastMessageId += 1;
        let uid = "\(self.lastMessageId)"
        let message = createPhotoMessageModel(uid, image: image, size: image.size, isIncoming: false)
        self.messageSender.sendMessage(message)
        self.slidingWindow.insertItem(message, position: .Bottom)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .Normal)
    }

    func addRandomIncomingMessage() {
        self.lastMessageId += 1;
        let message = FakeMessageFactory.createChatItem("\(self.lastMessageId)", isIncoming: true)
        self.slidingWindow.insertItem(message, position: .Bottom)
        self.delegate?.chatDataSourceDidUpdate(self, updateType: .Normal)
    }

    func adjustNumberOfMessages(preferredMaxCount preferredMaxCount: Int?, focusPosition: Double, completion:(didAdjust: Bool) -> Void) {
        let didAdjust = self.slidingWindow.adjustWindow(focusPosition: focusPosition, maxWindowSize: preferredMaxCount ?? self.preferredMaxWindowSize)
        completion(didAdjust: didAdjust)
    }
}
