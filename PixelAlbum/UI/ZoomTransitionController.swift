//
//  ZoomTransitionController.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 20.10.2021.
//

import UIKit


final class ZoomTransitionController: NSObject {
    let animator: ZoomAnimator
    
    /// The controller for the interactive transition during dismissal. Dragging up or down on the image
    /// initiates the interactive transition.
//    let interactionController: ZoomDismissalInteractionController
//    var isInteractive: Bool = false
    
    override init() {
        animator = ZoomAnimator()
//        interactionController = ZoomDismissalInteractionController()
        super.init()
    }
}

// MARK: - UINavigationControllerDelegate
extension ZoomTransitionController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let from = fromVC as? ZoomAnimatorDelegate,
              let to = toVC as? ZoomAnimatorDelegate else { return nil}
        
        animator.fromDelegate = from
        animator.toDelegate = to
        animator.isPresenting = operation == .push
        return animator
    }
    
    /// Update the transition controller for a presentation or dismissal.
    /// It decides hether or not to use the interactive controller.
    /// The interactive controller uses the same animator, though.
//    func navigationController(_ navigationController: UINavigationController,
//                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//
//        if !self.isInteractive {
//            return nil
//        }
//
//        self.interactionController.animator = animator
//        return self.interactionController
//    }
}
