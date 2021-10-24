//
//  ZoomTransitionController.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 20.10.2021.
//

import UIKit


final class ZoomTransitionController: NSObject {
    var isInteractive: Bool = false
    
    let interactionController: ZoomPresentationDissmissDriver
    private let animator: ZoomAnimator

    override init() {
        animator = ZoomAnimator()
        interactionController = ZoomPresentationDissmissDriver(animator: animator)
        super.init()
    }
    
    func didPan(with gestureRecognizer: UIPanGestureRecognizer) {
        interactionController.didPan(with: gestureRecognizer)
    }
}

// MARK: - UINavigationControllerDelegate
extension ZoomTransitionController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
            let from = fromVC as? ZoomAnimatorDelegate,
            let to = toVC as? ZoomAnimatorDelegate
        else {
            return nil
        }
        
        animator.fromDelegate = from
        animator.toDelegate = to
        animator.isPresenting = operation == .push
        return animator
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
        guard isInteractive, !animator.isPresenting else {
            return nil
        }
        
        return interactionController
    }
}
