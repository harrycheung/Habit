//
//  SelectFrequencyTransition.swift
//  Habit
//
//  Created by harry on 9/8/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class SelectFrequencyTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
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
      let sfvc = toVC as! SelectFrequencyViewController
      containerView.addSubview(sfvc.view)
      
      sfvc.showButtons()
      UIView.animateWithDuration(TransitionDuration,
        animations: {
          sfvc.blurView.alpha = self.BackgroundAlpha
          sfvc.closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 4))
        }, completion: { finished in
          transitionContext.completeTransition(true)
        })
    } else {
      let mvc = toVC as! MainViewController
      let sfvc = fromVC as! SelectFrequencyViewController
      
      sfvc.hideButtons()
      UIView.animateWithDuration(TransitionDuration,
        animations: {
          sfvc.blurView.alpha = 0
          sfvc.closeButton.transform = CGAffineTransformMakeRotation(0)
        }, completion: { finished in
          mvc.newButton.hidden = false
          transitionContext.completeTransition(true)
        })
    }
  }
}

