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
    return HabitApp.TransitionDuration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let containerView = transitionContext.containerView()!
    
    if presenting {
      let sfvc = fromVC as! SelectFrequencyViewController
      let ehvc = toVC as! EditHabitViewController
      containerView.addSubview(ehvc.view)
      
      sfvc.hideButtons()
      ehvc.view.alpha = 0
      UIView.animateWithDuration(HabitApp.TransitionDuration,
        animations: {
          ehvc.view.alpha = 1
          sfvc.closeButton.transform = CGAffineTransformMakeRotation(0)
          sfvc.closeButton.alpha = 0
          sfvc.dailyButton!.alpha = 0
          sfvc.weeklyButton!.alpha = 0
          sfvc.monthlyButton!.alpha = 0
        }, completion: { finished in
          transitionContext.completeTransition(true)
      })
    } else {
      let ehvc = fromVC as! EditHabitViewController
      let sfvc = toVC as! SelectFrequencyViewController
      let mvc = toVC.presentingViewController! as! MainViewController
      
      mvc.newButton.hidden = false
      mvc.newButton.alpha = 0
      ehvc.presentingViewController!.dismissViewControllerAnimated(false, completion: nil)
      UIView.animateWithDuration(HabitApp.TransitionDuration,
        animations: {
          ehvc.view.alpha = 0
          sfvc.view.alpha = 0
          mvc.newButton.alpha = 1
          mvc.transitionOverlay.alpha = 0
        }, completion: { finished in
          mvc.transitionOverlay.hidden = true
          transitionContext.completeTransition(true)
      })
    }
  }
}

