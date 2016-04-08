//
//  EditHabitTransition.swift
//  Habit
//
//  Created by harry on 8/15/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

class EditHabitTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
  private var presenting: Bool = false
  private var originalHeight: CGFloat!
  private var originalAlpha: CGFloat!
  
  func animationControllerForPresentedController(presented: UIViewController,
                                                 presentingController presenting: UIViewController,
                                                 sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = true
    return self
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presenting = false
    return self
  }
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return Constants.TransitionDuration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
    if presenting {
      let shvc = fromVC as! ShowHabitViewController
      let ehvc = toVC as! EditHabitViewController
      let startHeight = shvc.height.constant
      let endHeight = ehvc.height.constant
      originalHeight = startHeight
      originalAlpha = shvc.backgroundView.alpha
      let containerView = transitionContext.containerView()!
      
      containerView.addSubview(ehvc.view)
      ehvc.view.alpha = 0
      ehvc.height.constant = startHeight
      ehvc.view.layoutIfNeeded()
      ehvc.height.constant = endHeight
      shvc.height.constant = endHeight
      UIView.animateWithDuration(Constants.TransitionDuration,
                                 animations: {
                                  ehvc.view.alpha = 1
                                  ehvc.view.layoutIfNeeded()
                                  shvc.backgroundView.alpha = 0
                                  shvc.contentView.alpha = 0
                                  shvc.view.layoutIfNeeded()
                                 },
                                 completion: { finished in
                                  transitionContext.completeTransition(true)
                                 })
    } else {
      let ehvc = fromVC as! EditHabitViewController
      let shvc = toVC as! ShowHabitViewController
      let startHeight = ehvc.height.constant
      let endHeight = originalHeight
      
      shvc.height.constant = startHeight
      shvc.view.layoutIfNeeded()
      ehvc.height.constant = endHeight
      shvc.height.constant = endHeight
      shvc.backgroundView.alpha = 0
      UIView.animateWithDuration(Constants.TransitionDuration,
                                 animations: {
                                  ehvc.view.alpha = 0
                                  ehvc.view.layoutIfNeeded()
                                  shvc.backgroundView.alpha = self.originalAlpha
                                  shvc.contentView.alpha = 1
                                  shvc.view.layoutIfNeeded()
                                 },
                                 completion: { finished in
                                  transitionContext.completeTransition(true)
                                 })
    }
  }
  
}
