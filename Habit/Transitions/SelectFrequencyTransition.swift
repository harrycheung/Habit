//
//  SelectFrequencyTransition.swift
//  Habit
//
//  Created by harry on 9/8/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

class SelectFrequencyTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
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
    return Constants.TransitionDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let containerView = transitionContext.containerView
    
    if presenting {
      let mvc = fromVC as! MainViewController
      mvc.newButton.isHidden = true
      let sfvc = toVC as! SelectFrequencyViewController
      containerView.addSubview(sfvc.view)
      
      sfvc.showButtons()
      sfvc.backgroundView.alpha = 0
      UIView.animate(withDuration: Constants.TransitionDuration,
                     animations: {
                       sfvc.backgroundView.alpha = 1
                       sfvc.closeButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
                     },
                     completion: { finished in
                       transitionContext.completeTransition(true)
                     })
    } else {
      let mvc = toVC as! MainViewController
      let sfvc = fromVC as! SelectFrequencyViewController
      
      sfvc.hideButtons()
      UIView.animate(withDuration: Constants.TransitionDuration,
                     animations: {
                       sfvc.backgroundView.alpha = 0
                       sfvc.closeButton.transform = CGAffineTransform(rotationAngle: 0)
                     },
                     completion: { finished in
                       mvc.newButton.isHidden = false
                       transitionContext.completeTransition(true)
                     })
    }
  }
}

