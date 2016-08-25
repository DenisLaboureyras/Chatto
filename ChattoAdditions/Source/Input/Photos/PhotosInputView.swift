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
import Photos

protocol PhotosInputViewProtocol {
    weak var delegate: PhotosInputViewDelegate? { get set }
    weak var presentingController: UIViewController? { get }
    func reload()
}

protocol PhotosInputViewDelegate: class {
    func inputView(_ inputView: PhotosInputViewProtocol, didSelectImage image: UIImage)
}

class PhotosInputView: UIView, PhotosInputViewProtocol {

    fileprivate struct Constants {
        static let liveCameraItemIndex = 0
    }

    fileprivate var collectionView: UICollectionView!
    fileprivate var collectionViewLayout: UICollectionViewFlowLayout!
    fileprivate var dataProvider: PhotosInputDataProviderProtocol!
    fileprivate var cellProvider: PhotosInputCellProviderProtocol!
    fileprivate var itemSizeCalculator: PhotosInputViewItemSizeCalculator!

    weak var delegate: PhotosInputViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    weak var presentingController: UIViewController?
    init(presentingController: UIViewController?) {
        super.init(frame: CGRect.zero)
        self.presentingController = presentingController
        self.commonInit()
    }

    deinit {
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil
    }

    fileprivate func commonInit() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.configureCollectionView()
        self.configureItemSizeCalculator()
        self.dataProvider = PhotosInputPlaceholderDataProvider()
        self.cellProvider = PhotosInputPlaceholderCellProvider(collectionView: self.collectionView)
        self.requestAccessToVideo()
        self.requestAccessToPhoto()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionViewLayout.invalidateLayout()
    }

    fileprivate func configureItemSizeCalculator() {
        self.itemSizeCalculator = PhotosInputViewItemSizeCalculator()
        self.itemSizeCalculator.itemsPerRow = 3
        self.itemSizeCalculator.interitemSpace = 1
    }

    fileprivate func requestAccessToVideo() {
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (success) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.reloadVideoItem()
            })
        }
    }

    fileprivate func reloadVideoItem() {
        self.collectionView.reloadItems(at: [IndexPath(item: Constants.liveCameraItemIndex, section: 0)])
    }

    fileprivate func requestAccessToPhoto() {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
            if status == PHAuthorizationStatus.authorized {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.replacePlaceholderItemsWithPhotoItems()
                })
            }
        }
    }

    fileprivate func replacePlaceholderItemsWithPhotoItems() {
        let newDataProvider = PhotosInputDataProvider()
        self.dataProvider = newDataProvider
        self.cellProvider = PhotosInputCellProvider(collectionView: self.collectionView, dataProvider: newDataProvider)
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }

    func reload() {
        self.collectionView.reloadData()
    }

    fileprivate lazy var cameraPicker: PhotosInputCameraPicker = {
        return PhotosInputCameraPicker(presentingController: self.presentingController)
    }()
}

extension PhotosInputView: UICollectionViewDataSource {

    func configureCollectionView() {
        self.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.register(LiveCameraCell.self, forCellWithReuseIdentifier: "bar")

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.addSubview(self.collectionView)
        self.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.collectionView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataProvider.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if (indexPath as NSIndexPath).item == Constants.liveCameraItemIndex {
            let liveCameraCell = collectionView.dequeueReusableCell(withReuseIdentifier: "bar", for: indexPath) as! LiveCameraCell
            liveCameraCell.updateWithAuthorizationStatus(AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo))
            cell = liveCameraCell
        } else {
            cell = self.cellProvider.cellForItemAtIndexPath(indexPath)
        }
        return cell
    }
}

extension PhotosInputView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).item == Constants.liveCameraItemIndex {
            self.cameraPicker.requestImage { image in
                if let image = image {
                    self.delegate?.inputView(self, didSelectImage: image)
                }
            }
        } else {
            self.dataProvider.requestFullImageAtIndex((indexPath as NSIndexPath).item - 1) { image in
                self.delegate?.inputView(self, didSelectImage: image)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSizeCalculator.itemSizeForWidth(collectionView.bounds.width, atIndex: (indexPath as NSIndexPath).item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.itemSizeCalculator.interitemSpace
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.itemSizeCalculator.interitemSpace
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).item == Constants.liveCameraItemIndex {
            (cell as! LiveCameraCell).startCapturing()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).item == Constants.liveCameraItemIndex {
            (cell as! LiveCameraCell).stopCapturing()
        }
    }
}
