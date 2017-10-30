//
//  CreateHabitTransition.swift
//  Habit
//
//  Created by harry on 9/12/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

class CreateHabitTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
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
      let sfvc = fromVC as! SelectFrequencyViewController
      let ehvc = toVC as! EditHabitViewController
      containerView.addSubview(ehvc.view)
      
      sfvc.hideButtons()
      ehvc.view.alpha = 0
      UIView.animate(withDuration: Constants.TransitionDuration,
                     animations: {
                      ehvc.view.alpha = 1
                      sfvc.closeButton.transform = CGAffineTransform(rotationAngle: 0)
                      sfvc.closeButton.alpha = 0
                      sfvc.dailyButton.alpha = 0
                      sfvc.weeklyButton.alpha = 0
                      sfvc.monthlyButton.alpha = 0
      },
                     completion: { finished in
                      transitionContext.completeTransition(true)
      })
    } else {
      let ehvc = fromVC as! EditHabitViewController
      let sfvc = toVC as! SelectFrequencyViewController
      let mvc = toVC.presentingViewController! as! MainViewController
      
      mvc.newButton.isHidden = false
      mvc.newButton.alpha = 0
      UIView.animate(withDuration: Constants.TransitionDuration,
                     animations: {
                      ehvc.view.alpha = 0
                      sfvc.view.alpha = 0
                      mvc.newButton.alpha = 1
      },
                     completion: { finished in
                      transitionContext.completeTransition(true)
      })
    }
  }
}

