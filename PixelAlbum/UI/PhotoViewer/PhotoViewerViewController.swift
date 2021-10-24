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
    var interactiveController: UIPercentDrivenInteractiveTransition!
    
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
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(with:)))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.onViewDissapeared()
    }
    
    @objc
    func didPan(with gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
//            // unhide the navigation bar if needed and turn background white
//            if let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ImagePagingViewCell {
//                cell.contentView.backgroundColor = .white
//                navigationController?.setNavigationBarHidden(false, animated: true)
//            }
//
//            transitionController.isInteractive = true
            interactiveController.pause()
            let _ = navigationController?.popViewController(animated: true)
        case .ended:
            interactiveController.finish()
//            if transitionController.isInteractive {
//                transitionController.isInteractive = false
//                transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
//            }
        default:
            let distance = view.bounds.height / 2
            
            let percent = (gestureRecognizer.translation(in: view).y / distance)
            
            interactiveController.update(min(percent, 1.0))
//            if transitionController.isInteractive {
//                transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
//            }
        }
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
