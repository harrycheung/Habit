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
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
    if presenting {
      let shvc = fromVC as! ShowHabitViewController
      let ehvc = toVC as! EditHabitViewController
      let mvc = shvc.presentingViewController as! MainViewController
      let startHeight = shvc.height.constant
      let endHeight = ehvc.height.constant
      let containerView = transitionContext.containerView()!
      
      containerView.addSubview(ehvc.view)
      ehvc.view.alpha = 0
      ehvc.height.constant = startHeight
      ehvc.view.layoutIfNeeded()
      UIView.animateWithDuration(HabitApp.TransitionDuration,
        animations: {
          ehvc.view.alpha = 1
          ehvc.height.constant = endHeight
          ehvc.view.layoutIfNeeded()
          shvc.view.alpha = 0
          shvc.height.constant = endHeight
          shvc.view.layoutIfNeeded()
          mvc.transitionOverlay.transform = CGAffineTransformMakeScale(1, 1 + (endHeight - startHeight) / startHeight)
        }, completion: { finished in
          transitionContext.completeTransition(true)
          shvc.height.constant = startHeight
          shvc.view.layoutIfNeeded()
        })
    } else {
      let ehvc = fromVC as! EditHabitViewController
      let shvc = toVC as! ShowHabitViewController
      let mvc = shvc.presentingViewController as! MainViewController
      let startHeight = ehvc.height.constant
      let endHeight = shvc.height.constant
      
      if ehvc.habit == nil {
        UIView.animateWithDuration(HabitApp.TransitionDuration,
          animations: {
            ehvc.view.alpha = 0
            mvc.transitionOverlay.alpha = 0
            mvc.newButton.alpha = 1
          }, completion: { finished in
            mvc.transitionOverlay.layer.mask = nil
            mvc.transitionOverlay.transform = CGAffineTransformMakeScale(1, 1)
            transitionContext.completeTransition(true)
        })
      } else {
        shvc.height.constant = startHeight
        shvc.view.layoutIfNeeded()
        UIView.animateWithDuration(HabitApp.TransitionDuration,
          animations: {
            ehvc.view.alpha = 0
            ehvc.height.constant = endHeight
            ehvc.view.layoutIfNeeded()
            shvc.view.alpha = 1
            shvc.height.constant = endHeight
            shvc.view.layoutIfNeeded()
            mvc.transitionOverlay.transform = CGAffineTransformMakeScale(1, 1)
          }, completion: { finished in
            transitionContext.completeTransition(true)
        })
      }
    }
  }
  
}
