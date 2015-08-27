//
//  AppSettingsTransition.swift
//  Habit
//
//  Created by harry on 7/18/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class AppSettingsTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
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
    return 0.4
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let containerView = transitionContext.containerView()!

    if presenting {
      let settingsHeight = toVC.view.frame.height
      toVC.view.frame = CGRectMake(0, settingsHeight, screenWidth, screenHeight)
      containerView.addSubview(toVC.view)
      
      UIView.animateWithDuration(transitionDuration(transitionContext),
        delay: 0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 1,
        options: [.CurveEaseOut],
        animations: {
          toVC.view.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        }, completion: { finished in
          transitionContext.completeTransition(true)
        })
    } else {
      let settingsHeight = toVC.view.frame.height
      
      UIView.animateWithDuration(transitionDuration(transitionContext),
        animations: {
          fromVC.view.frame = CGRectMake(0, settingsHeight, screenWidth, screenHeight)
        }, completion: { finished in
          transitionContext.completeTransition(true)
        })
    }
  }
}