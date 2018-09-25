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

import AVFoundation
import Foundation
import UIKit
import Chatto

protocol LiveCameraCaptureSessionProtocol {
    var captureLayer: AVCaptureVideoPreviewLayer? { get }
    var isCapturing: Bool { get }
    func startCapturing(_ completion: @escaping () -> Void)
    func stopCapturing(_ completion: @escaping () -> Void)
}

class LiveCameraCell: UICollectionViewCell {

    fileprivate struct Constants {
        static let backgroundColor = UIColor(red: 24.0/255.0, green: 101.0/255.0, blue: 245.0/255.0, alpha: 1)
        static let cameraImageName = "camera"
        static let lockedCameraImageName = "camera_lock"
    }

    lazy var captureSession: LiveCameraCaptureSessionProtocol = {
        return LiveCameraCaptureSession()
    }()

    fileprivate var iconImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    deinit {
        self.unsubscribeFromAppNotifications()
    }

    fileprivate func commonInit() {
        self.configureIcon()
        self.contentView.backgroundColor = Constants.backgroundColor
    }

    fileprivate func configureIcon() {
        self.iconImageView = UIImageView()
        self.iconImageView.contentMode = .center
        self.contentView.addSubview(self.iconImageView)
    }

    fileprivate var authorizationStatus: AVAuthorizationStatus = .notDetermined
    func updateWithAuthorizationStatus(_ status: AVAuthorizationStatus) {
        self.authorizationStatus = status
        self.updateIcon()

        if self.isCaptureAvailable {
            self.subscribeToAppNotifications()
        } else {
            self.unsubscribeFromAppNotifications()
        }
    }

    fileprivate func updateIcon() {
        switch self.authorizationStatus {
        case .notDetermined, .authorized:
            self.iconImageView.image = UIImage(named: Constants.cameraImageName, in: Bundle(for: type(of: self)), compatibleWith: nil)
        case .restricted, .denied:
            self.iconImageView.image = UIImage(named: Constants.lockedCameraImageName, in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        self.setNeedsLayout()
    }

    fileprivate var isCaptureAvailable: Bool {
        switch self.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorized:
            return true
        }
    }

    func startCapturing() {
        guard self.isCaptureAvailable else { return }
        self.captureSession.startCapturing() { [weak self] in
            self?.addCaptureLayer()
        }
    }

    fileprivate func addCaptureLayer() {
        guard let captureLayer = self.captureSession.captureLayer else { return }
        self.contentView.layer.insertSublayer(captureLayer, below: self.iconImageView.layer)
        let animation = CABasicAnimation.bma_fadeInAnimationWithDuration(0.25)
        let animationKey = "fadeIn"
        captureLayer.removeAnimation(forKey: animationKey)
        captureLayer.add(animation, forKey: animationKey)
    }

    func stopCapturing() {
        guard self.isCaptureAvailable else { return }
        self.captureSession.stopCapturing() { [weak self] in
            self?.removeCaptureLayer()
        }
    }

    fileprivate func removeCaptureLayer() {
        self.captureSession.captureLayer?.removeFromSuperlayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.isCaptureAvailable {
            self.captureSession.captureLayer?.frame = self.contentView.bounds
        }

        self.iconImageView.sizeToFit()
        self.iconImageView.center = self.contentView.bounds.bma_center
    }

    override func didMoveToWindow() {
        if self.window == nil {
            self.stopCapturing()
        }
    }

    // MARK: - App Notifications
    lazy var notificationCenter = {
        return NotificationCenter.default
    }()

    fileprivate func subscribeToAppNotifications() {
        self.notificationCenter.addObserver(self, selector: #selector(LiveCameraCell.handleWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        self.notificationCenter.addObserver(self, selector: #selector(LiveCameraCell.handleDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    fileprivate func unsubscribeFromAppNotifications() {
        self.notificationCenter.removeObserver(self)
    }

    fileprivate var needsRestoreCaptureSession = false
    @objc func handleWillResignActiveNotification() {
        if self.captureSession.isCapturing {
            self.needsRestoreCaptureSession = true
            self.stopCapturing()
        }
    }

    @objc func handleDidBecomeActiveNotification() {
        if self.needsRestoreCaptureSession {
            self.needsRestoreCaptureSession = false
            self.startCapturing()
        }
    }
}

private class LiveCameraCaptureSession: LiveCameraCaptureSessionProtocol {
    init() {
        self.configureCaptureSession()
    }

    fileprivate var captureSession: AVCaptureSession!
    fileprivate (set) var captureLayer: AVCaptureVideoPreviewLayer?

    fileprivate func configureCaptureSession() {
        self.captureSession = AVCaptureSession()
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            self.captureSession.addInput(input)
        } catch {

        }

        self.captureLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.captureLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }

    fileprivate lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    func startCapturing(_ completion: @escaping () -> Void) {
        let operation = BlockOperation()
        operation.addExecutionBlock { [weak operation, weak self] in
            guard let strongSelf = self, let strongOperation = operation else { return }
            if !strongOperation.isCancelled && !strongSelf.captureSession.isRunning {
                strongSelf.captureSession.startRunning()
                OperationQueue.main.addOperation({
                    completion()
                })
            }
        }
        self.queue.addOperation(operation)
    }

    func stopCapturing(_ completion: @escaping () -> Void) {
        let operation = BlockOperation()
        operation.addExecutionBlock { [weak operation, weak self] in
            guard let strongSelf = self, let strongOperation = operation else { return }
            if !strongOperation.isCancelled && strongSelf.captureSession.isRunning {
                strongSelf.captureSession.stopRunning()
                OperationQueue.main.addOperation({
                    completion()
                })
            }
        }
        self.queue.addOperation(operation)
    }

    var isCapturing: Bool {
        return self.captureSession.isRunning
    }
}
