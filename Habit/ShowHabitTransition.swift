//
//  ShowHabitTransition.swift
//  Habit
//
//  Created by harry on 9/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

class ShowHabitTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
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
    return Constants.TransitionDuration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let containerView = transitionContext.containerView()!
    
    if presenting {
      let mvc = fromVC as! MainViewController
      let shvc = toVC as! ShowHabitViewController
      
      shvc.view.layoutIfNeeded()
      mvc.transitionOverlay.hidden = false
      mvc.transitionOverlay.alpha = 0
      let mask = CAShapeLayer()
      let path = CGPathCreateMutable()
      CGPathAddRect(path, nil, shvc.contentView.frame)
      CGPathAddRect(path, nil, shvc.view.frame)
      mask.path = path
      mask.fillRule = kCAFillRuleEvenOdd
      mvc.transitionOverlay.layer.mask = mask
      mvc.view.addSubview(mvc.transitionOverlay!)
      shvc.view.alpha = 0
      containerView.addSubview(shvc.view)

      UIView.animateWithDuration(Constants.TransitionDuration,
                                 animations: {
                                   toVC.view.alpha = 1
                                   mvc.transitionOverlay.alpha = Constants.TransitionOverlayAlpha
                                   mvc.newButton.alpha = 0
                                 },
                                 completion: { finished in
                                   transitionContext.completeTransition(true)
                                 })
    } else {
      let mvc = toVC as! MainViewController
      
      UIView.animateWithDuration(Constants.TransitionDuration,
                                 animations: {
                                   fromVC.view.alpha = 0
                                   mvc.transitionOverlay.alpha = 0
                                   mvc.newButton.alpha = 1
                                 },
                                 completion: { finished in
                                   mvc.transitionOverlay.hidden = true
                                   mvc.transitionOverlay.layer.mask = nil
                                   transitionContext.completeTransition(true)
                                 })
    }
  }
}

