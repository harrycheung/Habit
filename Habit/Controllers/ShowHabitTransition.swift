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
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Constants.TransitionDuration
  }
  
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let containerView = transitionContext.containerView
    
    if presenting {
      let mvc = fromVC as! MainViewController
      let shvc = toVC as! ShowHabitViewController
      
      shvc.view.alpha = 0
      containerView.addSubview(shvc.view)

      UIView.animate(withDuration: Constants.TransitionDuration,
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
      
      UIView.animate(withDuration: Constants.TransitionDuration,
                                 animations: {
                                  shvc.view.alpha = 0
                                  mvc.newButton.alpha = 1
                                 },
                                 completion: { finished in
                                  transitionContext.completeTransition(true)
                                 })
    }
  }
}

