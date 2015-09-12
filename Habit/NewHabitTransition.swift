//
//  NewHabitTransition.swift
//  Habit
//
//  Created by harry on 9/8/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class NewHabitTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
  let TransitionDuration: NSTimeInterval = 0.25
  let BackgroundAlpha: CGFloat = 0.4
  
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
    return TransitionDuration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let containerView = transitionContext.containerView()!
    
    if presenting {
      let mvc = fromVC as! MainViewController
      mvc.newButton.hidden = true
      let chvc = toVC as! CreateHabitViewController
      containerView.addSubview(chvc.view)
      
      chvc.showButtons()
      UIView.animateWithDuration(TransitionDuration,
        animations: {
          chvc.blurView.alpha = self.BackgroundAlpha
          chvc.closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 4))
        }, completion: { finished in
          transitionContext.completeTransition(true)
        })
    } else {
      print("new transition")
      let mvc = toVC as! MainViewController
      let chvc = fromVC as! CreateHabitViewController
      
      chvc.hideButtons()
      UIView.animateWithDuration(TransitionDuration,
        animations: {
          chvc.blurView.alpha = 0
          chvc.closeButton.transform = CGAffineTransformMakeRotation(0)
        }, completion: { finished in
          mvc.newButton.hidden = false
          transitionContext.completeTransition(true)
        })
    }
  }
}

