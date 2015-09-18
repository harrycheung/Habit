//
//  SelectFrequencyViewController.swift
//  Habit
//
//  Created by harry on 9/8/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData
import FontAwesome_swift

class SelectFrequencyViewController: UIViewController {
  
  let ButtonRadius: CGFloat = 80
  let LabelDistance: CGFloat = 75
  
  @IBOutlet weak var closeButton: UIButton!
  
  var dailyButton: UIButton?
  var weeklyButton: UIButton?
  var monthlyButton: UIButton?
  var createHabitTransition: UIViewControllerTransitioningDelegate?
  var frequencyLabel: UIButton?
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidLoad() {
    let createButton = { (text: String, frame: CGRect) -> UIButton in
      let button = UIButton(type: .System)
      button.frame = frame
      button.setTitle(text, forState: .Normal)
      button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 20)!
      button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
      button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("button\(text)Tapped")))
      button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: Selector("button\(text)Pressed:")))
      button.roundify(button.frame.width / 2)
      button.backgroundColor = HabitApp.color
      self.view.addSubview(button)
      return button
    }
    
    let mvc = presentingViewController as! MainViewController
    closeButton.roundify(closeButton.frame.width / 2)
    closeButton.backgroundColor = HabitApp.color
    let startFrame = CGRectMake(mvc.newButton.center.x - 23, mvc.newButton.center.y - 23, 46, 46)
    dailyButton = createButton("D", startFrame)
    weeklyButton = createButton("W", startFrame)
    monthlyButton = createButton("M", startFrame)
    view.bringSubviewToFront(closeButton)
    
    createHabitTransition = CreateHabitTransition()
  }
  
  func curvedAnimation(button: UIButton, start: CGPoint, end: CGPoint, control: CGPoint) {
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.duration = 0.3
    let path = UIBezierPath()
    path.moveToPoint(start)
    path.addQuadCurveToPoint(end, controlPoint: control)
    animation.path = path.CGPath
    button.layer.addAnimation(animation, forKey: nil)
    button.center = end
  }
  
  func showButtons() {
    let shortSide: CGFloat = ButtonRadius * CGFloat(cos(M_PI_4))
    let mvc = presentingViewController as! MainViewController
    curvedAnimation(dailyButton!,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x, mvc.newButton.center.y - ButtonRadius),
      control: CGPointMake(mvc.newButton.center.x - ButtonRadius / 2, mvc.newButton.center.y - ButtonRadius / 2))
    curvedAnimation(weeklyButton!,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y - shortSide),
      control: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y))
    curvedAnimation(monthlyButton!,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x - ButtonRadius, mvc.newButton.center.y),
      control: CGPointMake(mvc.newButton.center.x - ButtonRadius / 2, mvc.newButton.center.y + ButtonRadius / 2))
  }
  
  func hideButtons() {
    let shortSide: CGFloat = ButtonRadius * CGFloat(cos(M_PI_4))
    let mvc = presentingViewController as! MainViewController
    curvedAnimation(dailyButton!, start: dailyButton!.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - ButtonRadius / 2, mvc.newButton.center.y - ButtonRadius / 2))
    curvedAnimation(weeklyButton!, start: weeklyButton!.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y))
    curvedAnimation(monthlyButton!, start: monthlyButton!.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - ButtonRadius / 2, mvc.newButton.center.y + ButtonRadius / 2))
  }
  
  func createHabit(frequency: Habit.Frequency) {
    let ehvc = self.storyboard!.instantiateViewControllerWithIdentifier("EditHabitViewController") as! EditHabitViewController
    ehvc.frequency = frequency
    ehvc.modalPresentationStyle = .Custom
    ehvc.transitioningDelegate = createHabitTransition
    presentViewController(ehvc, animated: true, completion: nil)
  }
  
  func buttonDTapped() { createHabit(.Daily) }
  func buttonWTapped() { createHabit(.Weekly) }
  func buttonMTapped() { createHabit(.Monthly) }
  
  func longPressBegan(text: String, start: CGPoint, end: CGPoint) {
    frequencyLabel = UIButton(frame: CGRectMake(0, 0, 70, 25))
    frequencyLabel!.setTitle(text, forState: .Normal)
    frequencyLabel!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    frequencyLabel!.titleLabel!.font = UIFont(name: "Bariol-Regular", size: 17)!
    frequencyLabel!.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
    frequencyLabel!.center = start
    frequencyLabel!.roundify(10)
    frequencyLabel!.backgroundColor = HabitApp.color
    frequencyLabel!.sizeToFit()
    view.addSubview(frequencyLabel!)
    frequencyLabel!.transform = CGAffineTransformMakeScale(0.01, 0.01)
    UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [],
      animations: {
        self.frequencyLabel!.center = end
        self.frequencyLabel!.transform = CGAffineTransformMakeScale(1, 1)
    }, completion: nil)
  }
  
  func longPressEnded(location: CGPoint) {
    UIView.animateWithDuration(0.2,
      animations: {
        self.frequencyLabel!.center = location
        self.frequencyLabel!.transform = CGAffineTransformMakeScale(0.01, 0.01)
      },
      completion: { finished in
        self.frequencyLabel!.removeFromSuperview()
    })
  }

  func buttonDPressed(recognizer: UILongPressGestureRecognizer) {
    switch recognizer.state {
    case .Began:
      longPressBegan("Daily", start: dailyButton!.center, end: CGPointMake(dailyButton!.center.x, dailyButton!.center.y - LabelDistance * 0.7))
    case .Ended:
      longPressEnded(dailyButton!.center)
    default: ()
    }
  }
  
  func buttonWPressed(recognizer: UILongPressGestureRecognizer) {
    switch recognizer.state {
    case .Began:
      let shortSide: CGFloat = LabelDistance * CGFloat(cos(M_PI_4))
      longPressBegan("Weekly", start: weeklyButton!.center, end: CGPointMake(weeklyButton!.center.x - shortSide * 0.9, weeklyButton!.center.y - shortSide * 0.9))
    case .Ended:
      longPressEnded(weeklyButton!.center)
    default: ()
    }
  }
  
  func buttonMPressed(recognizer: UILongPressGestureRecognizer) {
    switch recognizer.state {
    case .Began:
      longPressBegan("Monthly", start: monthlyButton!.center, end: CGPointMake(monthlyButton!.center.x - LabelDistance, monthlyButton!.center.y))
    case .Ended:
      longPressEnded(monthlyButton!.center)
    default: ()
    }
  }
  
}
