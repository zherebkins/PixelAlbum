//
//  ZoomPresentationDissmissDriver.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 24.10.2021.
//

import UIKit


final class ZoomPresentationDissmissDriver: NSObject {
    private let animator: ZoomAnimator
        
    private var transitionContext: UIViewControllerContextTransitioning?
    private var transitionImageView: UIImageView?
    private var anchorImageFrame: CGRect = .zero
    
    private let dismissAnimationDuration: CGFloat = 0.2
    init(animator: ZoomAnimator) {
        self.animator = animator
    }
    
    func didPan(with gestureRecognizer: UIPanGestureRecognizer) {
        guard
            let transitionContext = transitionContext,
            let fromView = transitionContext.view(forKey: .from),
            let fromReferenceImageView = animator.fromDelegate?.transitionImageView(),
            let fromReferenceImageViewFrame = animator.fromDelegate?.transitionReferenceImageViewFrame(),
            let toReferenceImageView = animator.toDelegate?.transitionImageView(),
            let toReferenceImageViewFrame = animator.toDelegate?.transitionReferenceImageViewFrame()
        else {
            return
        }
        
        toReferenceImageView.isHidden = true
        fromReferenceImageView.isHidden = true
        
        let transitionProgress = progress(for: gestureRecognizer, in: fromView)

        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            let shouldFinish = shouldFinish(with: transitionProgress)
            
            UIView.animate(withDuration: dismissAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                fromView.alpha = shouldFinish ? 0 : 1
                self.transitionImageView?.frame = shouldFinish ? toReferenceImageViewFrame : fromReferenceImageViewFrame
            }, completion: { _ in
                self.transitionImageView?.removeFromSuperview()
                self.transitionImageView = nil
                toReferenceImageView.isHidden = false
                fromReferenceImageView.isHidden = false
                
                if shouldFinish {
                    transitionContext.finishInteractiveTransition()
                } else {
                    transitionContext.cancelInteractiveTransition()
                }
                transitionContext.completeTransition(shouldFinish)
            })
            
        } else {
            fromView.alpha = alpha(for: transitionProgress)
            let scale = imageScale(for: transitionProgress)
            transitionImageView?.transform = CGAffineTransform(scaleX: scale, y: scale)
            transitionImageView?.center = imageCenter(with: gestureRecognizer, in: fromView)
            
            transitionContext.updateInteractiveTransition(transitionProgress)
        }
    }
    
    private func progress(for gesture: UIPanGestureRecognizer, in view: UIView) -> CGFloat {
        let fullDistance = view.bounds.height / 2
        let translation = gesture.translation(in: view).y
        let progressValue = translation / fullDistance
        return min(progressValue, 1.0)
    }
    
    private func imageScale(for progress: CGFloat) -> CGFloat {
        let maxScaleDelta = 0.2
        let scaleDelta = maxScaleDelta * progress
        let scaleValue = 1 - scaleDelta
        return min(scaleValue, 1.0)
    }
    
    private func imageCenter(with gesture: UIPanGestureRecognizer, in view: UIView) -> CGPoint {
        let translationPoint = gesture.translation(in: view)
        
        let maxXDelta = view.bounds.width / 3
        let xOffset = min(max(translationPoint.x, -maxXDelta), maxXDelta)
        let yOffset = max(translationPoint.y, -50)
        return CGPoint(x: anchorImageFrame.midX + xOffset,
                       y: anchorImageFrame.midY + yOffset)
    }
    
    private func alpha(for progress: CGFloat) -> CGFloat {
        return 1 - progress
    }
    
    private func shouldFinish(with progress: CGFloat) -> Bool {
        progress > 0.2
    }
}

extension ZoomPresentationDissmissDriver: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        
        guard
            let fromReferenceImage = animator.fromDelegate?.transitionImageView()?.image,
            let fromReferenceImageViewFrame = animator.fromDelegate?.transitionReferenceImageViewFrame(),
            let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from)
        else {
            return
        }
        
        let transitionImageView = UIImageView(image: fromReferenceImage)
        transitionImageView.contentMode = .scaleAspectFit
        transitionImageView.frame = fromReferenceImageViewFrame
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        // Trick to add image above navigation bar hierarchy
        containerView.superview?.superview?.addSubview(transitionImageView)
        
        self.transitionImageView = transitionImageView
        self.anchorImageFrame = fromReferenceImageViewFrame
    }
}
