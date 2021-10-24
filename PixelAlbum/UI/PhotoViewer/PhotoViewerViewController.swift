//
//  PhotoViewerViewController.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 17.10.2021.
//

import UIKit
import Combine

final class PhotoViewerViewController: UIViewController {
    var transitionController: ZoomTransitionController?
    
    static func instantiate(with viewModel: PhotoViewerViewModel) -> PhotoViewerViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(
                withIdentifier: "PhotoViewerViewController"
            ) as! PhotoViewerViewController
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
    private func didPan(with gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            transitionController?.isInteractive = true
            let _ = navigationController?.popViewController(animated: true)

        case .changed:
            transitionController?.didPan(with: gestureRecognizer)
            
        default:
            transitionController?.isInteractive = false
            transitionController?.didPan(with: gestureRecognizer)
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
