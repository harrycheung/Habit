//
//  EditHabitTransition.swift
//  Habit
//
//  Created by harry on 8/15/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class EditHabitTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
  var presenting: Bool = false
  
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
    return 0.3
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    if presenting {
      let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! ShowHabitViewController
      let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! EditHabitViewController
      transitionContext.containerView()!.addSubview(toVC.view)
      toVC.view.alpha = 0
      let startHeight = fromVC.height.constant
      let endHeight = toVC.height.constant
      toVC.height.constant = startHeight
      toVC.view.layoutIfNeeded()
      fromVC.height.constant = endHeight
      toVC.height.constant = endHeight
      UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
        toVC.view.alpha = 1
        fromVC.view.layoutIfNeeded()
        toVC.view.layoutIfNeeded()
      }, completion: { (finished) in
        transitionContext.completeTransition(true)
        fromVC.height.constant = startHeight
        fromVC.view.layoutIfNeeded()
      })
    } else if !presenting {
      let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! EditHabitViewController
      let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ShowHabitViewController
      let startHeight = fromVC.height.constant
      let endHeight = toVC.height.constant
      toVC.height.constant = startHeight
      toVC.view.layoutIfNeeded()
      fromVC.height.constant = endHeight
      toVC.height.constant = endHeight
      UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
        fromVC.view.alpha = 0
        fromVC.view.layoutIfNeeded()
        toVC.view.layoutIfNeeded()
      }, completion: { (finished) in
        transitionContext.completeTransition(true)
        fromVC.height.constant = startHeight
        fromVC.view.layoutIfNeeded()
      })
    }
  }
  
}
