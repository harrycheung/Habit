//
//  CreateHabitTransition.swift
//  Habit
//
//  Created by harry on 9/12/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class CreateHabitTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
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
      let chvc = fromVC as! CreateHabitViewController
      let hsvc = toVC as! HabitSettingsViewController
      containerView.addSubview(hsvc.view)
      
      chvc.hideButtons()
      hsvc.view.alpha = 0
      UIView.animateWithDuration(TransitionDuration,
        animations: {
          hsvc.view.alpha = 1
          chvc.closeButton.transform = CGAffineTransformMakeRotation(0)
          chvc.closeButton.alpha = 0
          chvc.dailyButton!.alpha = 0
          chvc.weeklyButton!.alpha = 0
          chvc.monthlyButton!.alpha = 0
        }, completion: { finished in
          transitionContext.completeTransition(true)
      })
    } else {
      let hsvc = fromVC as! HabitSettingsViewController
      let chvc = toVC as! CreateHabitViewController
      let mvc = toVC.presentingViewController! as! MainViewController
      
      mvc.newButton.hidden = false
      mvc.newButton.alpha = 0
      hsvc.presentingViewController!.dismissViewControllerAnimated(false, completion: nil)
      UIView.animateWithDuration(TransitionDuration,
        animations: {
          hsvc.view.alpha = 0
          chvc.view.alpha = 0
          mvc.newButton.alpha = 1
        }, completion: { finished in
          transitionContext.completeTransition(true)
        })
    }
  }
}

