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
    return SettingsTransition.TransitionDuration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let containerView = transitionContext.containerView()!

    if presenting {
      let asvc = toVC as! SettingsViewController
      asvc.darkenView = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
      asvc.darkenView.backgroundColor = UIColor.blackColor()
      asvc.darkenView.alpha = 0
      containerView.addSubview(asvc.darkenView)
      
      toVC.view.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight)
      containerView.addSubview(toVC.view)
      
      UIView.animateWithDuration(SettingsTransition.TransitionDuration,
                                 delay: 0,
                                 usingSpringWithDamping: SettingsTransition.SpringDamping,
                                 initialSpringVelocity: SettingsTransition.SpringVelocity,
                                 options: SettingsTransition.AnimationOptions,
                                 animations: {
                                   toVC.view.frame = CGRectMake(0, 0, screenWidth, screenHeight)
                                   asvc.darkenView.frame = CGRectMake(0, 0, screenWidth, asvc.paddingView.bounds.height)
                                   asvc.darkenView.alpha = SettingsTransition.DarkenAlpha
                                 },
                                 completion: { finished in
                                   transitionContext.completeTransition(true)
                                 })
    } else {
      let asvc = fromVC as! SettingsViewController
      
      UIView.animateWithDuration(SettingsTransition.TransitionDuration,
                                 animations: {
                                   fromVC.view.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight)
                                   asvc.darkenView.frame = CGRectMake(0, 0, screenWidth, screenHeight)
                                   asvc.darkenView.alpha = 0
                                 },
                                 completion: { finished in
                                   transitionContext.completeTransition(true)
                                 })
    }
  }
}
