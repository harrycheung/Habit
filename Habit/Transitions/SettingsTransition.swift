//
//  SettingsTransition.swift
//  Habit
//
//  Created by harry on 7/18/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

class SettingsTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

  static let TransitionDuration: TimeInterval = 0.4
  static let SpringDamping: CGFloat = 0.6
  static let SpringVelocity: CGFloat = 1
  static let AnimationOptions: UIViewAnimationOptions = [.curveEaseOut]
  static let DarkenAlpha: CGFloat = 0.2
  static let InsetPixels: CGFloat = 20
  
  private var presenting: Bool = false
  
  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = true
    return self
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    self.presenting = false
    return self
  }
    
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return SettingsTransition.TransitionDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let containerView = transitionContext.containerView

    if self.presenting {
      let svc = toVC as! SettingsViewController
      svc.blurView.alpha = 0
      svc.slideConstraint.priority = Constants.LayoutPriorityHigh
      containerView.addSubview(toVC.view)
      
      UIView.animate(withDuration: SettingsTransition.TransitionDuration,
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
                     }
      )
    } else {
      let svc = fromVC as! SettingsViewController
      svc.slideConstraint.priority = Constants.LayoutPriorityLow
      
      UIView.animate(withDuration: SettingsTransition.TransitionDuration,
                     animations: {
                       svc.blurView.alpha = 0
                       svc.view.layoutIfNeeded()
                     },
                     completion: { finished in
                       transitionContext.completeTransition(true)
                     }
      )
    }
  }
}
