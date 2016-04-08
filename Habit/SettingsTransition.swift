//
//  SettingsTransition.swift
//  Habit
//
//  Created by harry on 7/18/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

class SettingsTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

  static let TransitionDuration: NSTimeInterval = 0.4
  static let SpringDamping: CGFloat = 0.6
  static let SpringVelocity: CGFloat = 1
  static let AnimationOptions: UIViewAnimationOptions = [.CurveEaseOut]
  static let DarkenAlpha: CGFloat = 0.2
  static let InsetPixels: CGFloat = 20
  
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
    return SettingsTransition.TransitionDuration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let containerView = transitionContext.containerView()!

    if presenting {
      let svc = toVC as! SettingsViewController
      
      svc.blurView.alpha = 0
      svc.slideConstraint.priority = Constants.LayoutPriorityHigh
      containerView.addSubview(toVC.view)
      
      UIView.animateWithDuration(SettingsTransition.TransitionDuration,
                                 delay: 0,
                                 usingSpringWithDamping: SettingsTransition.SpringDamping,
                                 initialSpringVelocity: SettingsTransition.SpringVelocity,
                                 options: SettingsTransition.AnimationOptions,
                                 animations: {
                                  svc.blurView.alpha = 1
                                  svc.view.layoutIfNeeded()
                                 },
                                 completion: { finished in
                                  transitionContext.completeTransition(true)
      })
    } else {
      let svc = fromVC as! SettingsViewController
      svc.slideConstraint.priority = Constants.LayoutPriorityLow
      
      UIView.animateWithDuration(SettingsTransition.TransitionDuration,
                                 animations: {
                                  svc.blurView.alpha = 0
                                  svc.view.layoutIfNeeded()
                                 },
                                 completion: { finished in
                                  transitionContext.completeTransition(true)
                                 })
    }
  }
}
