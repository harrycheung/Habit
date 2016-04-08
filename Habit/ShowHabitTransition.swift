//
//  ShowHabitTransition.swift
//  Habit
//
//  Created by harry on 9/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

class ShowHabitTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
  private var presenting: Bool = false
  
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
    let containerView = transitionContext.containerView()!
    
    if presenting {
      let mvc = fromVC as! MainViewController
      let shvc = toVC as! ShowHabitViewController
      
      shvc.view.alpha = 0
      containerView.addSubview(shvc.view)

      UIView.animateWithDuration(Constants.TransitionDuration,
                                 animations: {
                                  shvc.view.alpha = 1
                                  mvc.newButton.alpha = 0
                                 },
                                 completion: { finished in
                                  transitionContext.completeTransition(true)
                                 })
    } else {
      let shvc = fromVC as! ShowHabitViewController
      let mvc = toVC as! MainViewController
      
      UIView.animateWithDuration(Constants.TransitionDuration,
                                 animations: {
                                  shvc.view.alpha = 0
                                  if mvc.tabBar.isSelected(Constants.TabAll) {
                                    mvc.newButton.alpha = 1
                                  }
                                 },
                                 completion: { finished in
                                  transitionContext.completeTransition(true)
                                 })
    }
  }
}

