//
//  SettingsSegue.swift
//  Habit
//
//  Created by harry on 7/18/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class SettingsSegue: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
//  override func perform() {
//    /*
//    Because this class is used for a Present Modally segue, UIKit will
//    maintain a strong reference to this segue object for the duration of
//    the presentation. That way, this segue object will still be around to
//    provide an animation controller for the eventual dismissal, as well
//    as for the initial presentation.
//    */
//    destinationViewController.transitioningDelegate = self
//    
////    destinationViewController.modalPresentationStyle = .OverCurrentContext
////    sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
//    super.perform()
//  }
  
  var present: Bool = false
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    NSLog("for presented")
    present = true
    return self
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    NSLog("for dismissed")
    present = false
    return self
  }
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let destinationViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    let containerView = transitionContext.containerView()!

    //if transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) == destinationViewController {
    if present {
      let settingsHeight: CGFloat = (destinationViewController as! SettingsViewController).settingsHeight.constant
      // Presenting
      NSLog("presenting")
      destinationViewController.view.frame = CGRectMake(0, settingsHeight, screenWidth, screenHeight)
      containerView.addSubview(destinationViewController.view)
      
      UIView.animateWithDuration(transitionDuration(transitionContext),
        delay: 0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 1,
        options: [.CurveEaseOut],
        animations: {
          destinationViewController.view.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        }, completion: { finished in
          transitionContext.completeTransition(true)
        })
    } else {
      let sourceViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
      let settingsHeight: CGFloat = (sourceViewController as! SettingsViewController).settingsHeight.constant
      NSLog("dismissing")
      // Dismissing
      UIView.animateWithDuration(transitionDuration(transitionContext),
        animations: {
          sourceViewController.view.frame = CGRectMake(0, settingsHeight, screenWidth, screenHeight)
        }, completion: { finished in
          transitionContext.completeTransition(true)
        })
    }
  }
}
