//
//  PhotoViewerViewController.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 17.10.2021.
//

import UIKit
import Photos
import Combine

final class PhotoViewerViewModel {
    @Published var image: UIImage?

    private let asset: PHAsset
    private let thumbnailsProvider: ThumbnailsProvider
    private var runningImageRequestId: PHImageRequestID? = nil

    
    init(with asset: PHAsset, thumbnailsProvider: ThumbnailsProvider) {
        self.thumbnailsProvider = thumbnailsProvider
        self.asset = asset
        
        runningImageRequestId = thumbnailsProvider.fetchOriginalImage(for: asset, completion: { [weak self] img in
            self?.image = img
        })
    }
    
    func onViewDissapeared() {
        if let requestId = runningImageRequestId {
            thumbnailsProvider.cancelFetch(by: requestId)
            runningImageRequestId = nil
        }
    }
}

final class PhotoViewerViewController: UIViewController {
    static func instantiate(with viewModel: PhotoViewerViewModel) -> PhotoViewerViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewerViewController") as! PhotoViewerViewController
        vc.viewModel = viewModel
        return vc
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    private var viewModel: PhotoViewerViewModel!
    private var subscribtions = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        scrollView.maximumZoomScale = 5.0
        scrollView.bouncesZoom = true
        scrollView.isScrollEnabled = false
        
        viewModel.$image.sink { [unowned self] in
            imageView.image = $0
        }
        .store(in: &subscribtions)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onViewDissapeared()
    }
}

extension PhotoViewerViewController: UIScrollViewDelegate {
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.isScrollEnabled = scale != 1.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension PhotoViewerViewController: ZoomAnimatorDelegate {
    func transitionImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        imageView
    }
    
    func transitionReferenceImageViewFrame(for zoomAnimator: ZoomAnimator) -> CGRect? {
        return view.frame
    }
}
