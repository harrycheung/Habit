//
//  NewHabitTransition.swift
//  Habit
//
//  Created by harry on 9/8/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class NewHabitTransition: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
  let TransitionDuration: NSTimeInterval = 0.4
  
  var presenting: Bool = false
  var dailyContainer: UIView?
  
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
    let radius: CGFloat = 100
    let shortDistance: CGFloat = radius * CGFloat(cos(M_PI_4))
    
    let curvedAnimation = { (button: UIButton, start: CGPoint, end: CGPoint, control: CGPoint) in
      let animation = CAKeyframeAnimation(keyPath: "position")
      animation.duration = self.TransitionDuration
      let path = UIBezierPath()
      path.moveToPoint(start)
      path.addQuadCurveToPoint(end, controlPoint: control)
      animation.path = path.CGPath
      button.layer.addAnimation(animation, forKey: nil)
    }
    
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let containerView = transitionContext.containerView()!
    
    if presenting {
      let roundifyButton = { (button: UIButton) in
        button.backgroundColor = HabitApp.color
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.shadowColor = UIColor.blackColor().CGColor
        button.layer.shadowOpacity = 0.6
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSizeMake(0, 1)
      }
      
      let createButton = { (text: String, frame: CGRect) -> UIButton in
        let button = UIButton(frame: frame)
        roundifyButton(button)
        button.setTitle(text, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 20)!
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        return button
      }
      
      let mvc = fromVC as! MainViewController
      mvc.newButton.hidden = true
      let nhvc = toVC as! NewHabitViewController
      roundifyButton(nhvc.closeButton)
      nhvc.blurView.alpha = 0
      let startFrame = CGRectMake(mvc.newButton.center.x - 23, mvc.newButton.center.y - 23, 46, 46)
      nhvc.dailyButton = createButton("D", startFrame)
      nhvc.view.addSubview(nhvc.dailyButton!)
      nhvc.weeklyButton = createButton("W", startFrame)
      nhvc.view.addSubview(nhvc.weeklyButton!)
      nhvc.monthlyButton = createButton("M", startFrame)
      nhvc.view.addSubview(nhvc.monthlyButton!)
      nhvc.view.bringSubviewToFront(nhvc.closeButton)
      containerView.addSubview(nhvc.view)

      curvedAnimation(nhvc.dailyButton!, mvc.newButton.center,
        CGPointMake(mvc.newButton.center.x, mvc.newButton.center.y - radius),
        CGPointMake(mvc.newButton.center.x - radius / 2, mvc.newButton.center.y - radius / 2))
      curvedAnimation(nhvc.weeklyButton!, mvc.newButton.center,
        CGPointMake(mvc.newButton.center.x - shortDistance, mvc.newButton.center.y - shortDistance),
        CGPointMake(mvc.newButton.center.x - shortDistance, mvc.newButton.center.y))
      curvedAnimation(nhvc.monthlyButton!, mvc.newButton.center,
        CGPointMake(mvc.newButton.center.x - radius, mvc.newButton.center.y),
        CGPointMake(mvc.newButton.center.x - radius / 2, mvc.newButton.center.y + radius / 2))
      
      UIView.animateWithDuration(TransitionDuration,
        animations: {
          nhvc.blurView.alpha = 1
          nhvc.closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 4))
        }, completion: { finished in
          transitionContext.completeTransition(true)
          nhvc.dailyButton!.center = CGPointMake(mvc.newButton.center.x, mvc.newButton.center.y - radius)
          nhvc.weeklyButton!.center = CGPointMake(mvc.newButton.center.x - shortDistance, mvc.newButton.center.y - shortDistance)
          nhvc.monthlyButton!.center = CGPointMake(mvc.newButton.center.x - radius, mvc.newButton.center.y)
        })
    } else {
      let mvc = toVC as! MainViewController
      let nhvc = fromVC as! NewHabitViewController
      
      curvedAnimation(nhvc.dailyButton!, nhvc.dailyButton!.center, mvc.newButton.center,
        CGPointMake(mvc.newButton.center.x - radius / 2, mvc.newButton.center.y - radius / 2))
      curvedAnimation(nhvc.weeklyButton!, nhvc.weeklyButton!.center, mvc.newButton.center,
        CGPointMake(mvc.newButton.center.x - shortDistance / 2, mvc.newButton.center.y))
      curvedAnimation(nhvc.monthlyButton!, nhvc.monthlyButton!.center, mvc.newButton.center,
        CGPointMake(mvc.newButton.center.x - radius / 2, mvc.newButton.center.y + radius / 2))
      
      UIView.animateWithDuration(TransitionDuration,
        animations: {
          nhvc.blurView.alpha = 0
          nhvc.closeButton.transform = CGAffineTransformMakeRotation(0)
        }, completion: { finished in
          mvc.newButton.hidden = false
          nhvc.dailyButton!.center = mvc.newButton.center
          nhvc.weeklyButton!.center = mvc.newButton.center
          nhvc.monthlyButton!.center = mvc.newButton.center
          transitionContext.completeTransition(true)
        })
    }
  }
}

