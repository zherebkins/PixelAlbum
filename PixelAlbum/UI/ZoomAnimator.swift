//
//  ZoomAnimator.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 20.10.2021.
//

import UIKit
import os

protocol ZoomAnimatorDelegate: AnyObject {
    func transitionImageView() -> UIImageView?
    func transitionReferenceImageViewFrame() -> CGRect?
}

final class ZoomAnimator: NSObject {
    weak var fromDelegate: ZoomAnimatorDelegate?
    weak var toDelegate: ZoomAnimatorDelegate?
    
    var isPresenting = true
        
    private func animateZoomInTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard
            let fromReferenceImageView = fromDelegate?.transitionImageView(),
            let fromReferenceImageViewFrame = fromDelegate?.transitionReferenceImageViewFrame(),
            
            let toView = transitionContext.view(forKey: .to),
            let toReferenceImageView = toDelegate?.transitionImageView(),
            let toReferenceImageViewFrame = toDelegate?.transitionReferenceImageViewFrame()
        else {
            return
        }
        
        let transitionImageView = UIImageView(image: fromReferenceImageView.image!)
        transitionImageView.contentMode = .scaleAspectFit
        transitionImageView.frame = fromReferenceImageViewFrame
        
        containerView.addSubview(toView)
        containerView.addSubview(transitionImageView)

        toView.alpha = 0
        fromReferenceImageView.isHidden = true
        toReferenceImageView.isHidden = true
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.transitionCrossDissolve, .curveEaseOut],
            animations: {
                toView.alpha = 1
                transitionImageView.frame = toReferenceImageViewFrame
            },
            completion: { _ in
                toReferenceImageView.isHidden = false
                transitionImageView.removeFromSuperview()
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
    
    private func animateZoomOutTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard
            let fromView = transitionContext.view(forKey: .from),
            let fromReferenceImageView = fromDelegate?.transitionImageView(),
            let fromReferenceImageViewFrame = fromDelegate?.transitionReferenceImageViewFrame(),
            
            let toView = transitionContext.view(forKey: .to),
            let toReferenceImageView = toDelegate?.transitionImageView(),
            let toReferenceImageViewFrame = toDelegate?.transitionReferenceImageViewFrame()
        else {
            return
        }
        
        let transitionImageView = UIImageView(image: fromReferenceImageView.image!)
        transitionImageView.contentMode = .scaleAspectFit
        transitionImageView.frame = fromReferenceImageViewFrame
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        containerView.addSubview(transitionImageView)
        
        toReferenceImageView.isHidden = true
        fromReferenceImageView.isHidden = true
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                fromView.alpha = 0
                transitionImageView.frame = toReferenceImageViewFrame
            },
            completion: { _ in
                toReferenceImageView.isHidden = false
                transitionImageView.removeFromSuperview()
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension ZoomAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPresenting ? 0.5 : 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animateZoomInTransition(using: transitionContext)
        } else {
            animateZoomOutTransition(using: transitionContext)
        }
    }
}
