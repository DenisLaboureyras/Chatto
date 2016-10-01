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

typealias TaskClosure = (_ completion: @escaping () -> Void) -> Void

protocol SerialTaskQueueProtocol {
    func addTask(_ task: @escaping TaskClosure)
    func start()
    func stop()
    var isEmpty: Bool { get }
}

final class SerialTaskQueue: SerialTaskQueueProtocol {
    fileprivate var isBusy = false
    fileprivate var isStopped = true
    fileprivate var tasksQueue = [TaskClosure]()

    func addTask(_ task: @escaping TaskClosure) {
        self.tasksQueue.append(task)
        self.maybeExecuteNextTask()
    }

    func start() {
        self.isStopped = false
        self.maybeExecuteNextTask()
    }

    func stop() {
        self.isStopped = true
    }

    var isEmpty: Bool {
        return self.tasksQueue.isEmpty
    }

    fileprivate func maybeExecuteNextTask() {
        if !self.isStopped && !self.isBusy {
            if !self.isEmpty {
                let firstTask = self.tasksQueue.removeFirst()
                self.isBusy = true
                firstTask({ [weak self] () -> Void in
                    self?.isBusy = false
                    self?.maybeExecuteNextTask()
                })
            }
        }
    }
}
